import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

const double _earthRadiusM = 6371008.8;

/// Normalizes a compass-style heading to **0.0–359.9** (one decimal place).
double normalizeHeading0360(double deg) {
  var x = deg % 360;
  if (x < 0) {
    x += 360;
  }
  x = (x * 10).round() / 10;
  if (x >= 359.95) {
    return 0.0;
  }
  if (x > 359.9) {
    x = 359.9;
  }
  return x;
}

double distanceMeters(LatLng a, LatLng b) {
  const d = Distance();
  return d.as(LengthUnit.Meter, a, b);
}

/// Initial bearing from [from] to [to] in degrees, clockwise from true north (0–360).
double bearingDegrees(LatLng from, LatLng to) {
  final lat1 = from.latitude * math.pi / 180;
  final lat2 = to.latitude * math.pi / 180;
  final dLon = (to.longitude - from.longitude) * math.pi / 180;
  final y = math.sin(dLon) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  final brng = math.atan2(y, x) * 180 / math.pi;
  return (brng + 360) % 360;
}

/// Local ENU meters (east, north) relative to [origin].
({double east, double north}) toLocalMeters(LatLng origin, LatLng p) {
  final lat0 = origin.latitude * math.pi / 180;
  final dLat = (p.latitude - origin.latitude) * math.pi / 180;
  final dLon = (p.longitude - origin.longitude) * math.pi / 180;
  final north = _earthRadiusM * dLat;
  final east = _earthRadiusM * dLon * math.cos(lat0);
  return (east: east, north: north);
}

LatLng fromLocalMeters(LatLng origin, double east, double north) {
  final lat0 = origin.latitude * math.pi / 180;
  final dLat = north / _earthRadiusM;
  final dLon = east / (_earthRadiusM * math.cos(lat0));
  return LatLng(
    origin.latitude + dLat * 180 / math.pi,
    origin.longitude + dLon * 180 / math.pi,
  );
}

/// Unit direction (east, north) for a compass-style heading in degrees (0 = north, 90 = east).
({double east, double north}) headingToEnu(double headingDeg) {
  final r = normalizeHeading0360(headingDeg) * math.pi / 180;
  return (east: math.sin(r), north: math.cos(r));
}

/// Infinite line intersection in the local plane. Headings are compass degrees from north.
LatLng? intersectBearings(
  LatLng p1,
  double heading1Deg,
  LatLng p2,
  double heading2Deg,
) {
  final origin = LatLng(
    (p1.latitude + p2.latitude) / 2,
    (p1.longitude + p2.longitude) / 2,
  );
  final a = toLocalMeters(origin, p1);
  final b = toLocalMeters(origin, p2);
  final d1 = headingToEnu(heading1Deg);
  final d2 = headingToEnu(heading2Deg);

  final cross = d1.east * d2.north - d1.north * d2.east;
  if (cross.abs() < 1e-6) {
    return null;
  }

  final dx = b.east - a.east;
  final dy = b.north - a.north;
  final t = (dx * d2.north - dy * d2.east) / cross;

  final ix = a.east + t * d1.east;
  final iy = a.north + t * d1.north;
  return fromLocalMeters(origin, ix, iy);
}

/// Pairwise intersections of bearing lines; merges points closer than [mergeMeters].
List<LatLng> pairwiseIntersections(
  List<({LatLng point, double headingDeg})> paths, {
  double mergeMeters = 2.5,
}) {
  if (paths.length < 2) {
    return [];
  }
  final out = <LatLng>[];
  for (var i = 0; i < paths.length; i++) {
    for (var j = i + 1; j < paths.length; j++) {
      final p = paths[i];
      final q = paths[j];
      final x = intersectBearings(p.point, p.headingDeg, q.point, q.headingDeg);
      if (x == null) {
        continue;
      }
      final dup = out.any((e) => distanceMeters(e, x) < mergeMeters);
      if (!dup) {
        out.add(x);
      }
    }
  }
  return out;
}

/// End point [distanceM] ahead along [headingDeg] from [start] (tangent-plane approximation).
LatLng pointAhead(LatLng start, double headingDeg, double distanceM) {
  final r = normalizeHeading0360(headingDeg) * math.pi / 180;
  final north = distanceM * math.cos(r);
  final east = distanceM * math.sin(r);
  return fromLocalMeters(start, east, north);
}

/// Centroid of [points] in a local tangent plane (first point as origin).
LatLng centroidLatLng(List<LatLng> points) {
  if (points.isEmpty) {
    throw ArgumentError('points must not be empty');
  }
  if (points.length == 1) {
    return points.first;
  }
  final origin = points.first;
  var sumE = 0.0;
  var sumN = 0.0;
  for (final p in points) {
    final m = toLocalMeters(origin, p);
    sumE += m.east;
    sumN += m.north;
  }
  final n = points.length;
  return fromLocalMeters(origin, sumE / n, sumN / n);
}
