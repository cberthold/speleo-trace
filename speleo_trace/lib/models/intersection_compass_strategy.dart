import 'package:latlong2/latlong.dart';

import '../utils/geometry.dart';

/// Selects which intersection point the compass should use.
abstract class IntersectionCompassStrategy {
  const IntersectionCompassStrategy();

  LatLng? resolve(List<LatLng> intersections);

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}

/// Always uses the first intersection in [pairwiseIntersections] order.
class FirstIntersectionStrategy extends IntersectionCompassStrategy {
  const FirstIntersectionStrategy();

  @override
  LatLng? resolve(List<LatLng> intersections) {
    if (intersections.isEmpty) {
      return null;
    }
    return intersections.first;
  }

  @override
  bool operator ==(Object other) => other is FirstIntersectionStrategy;

  @override
  int get hashCode => 1;
}

/// Always uses the last intersection in [pairwiseIntersections] order.
class LastIntersectionStrategy extends IntersectionCompassStrategy {
  const LastIntersectionStrategy();

  @override
  LatLng? resolve(List<LatLng> intersections) {
    if (intersections.isEmpty) {
      return null;
    }
    return intersections.last;
  }

  @override
  bool operator ==(Object other) => other is LastIntersectionStrategy;

  @override
  int get hashCode => 2;
}

/// Uses the centroid of all intersections (local tangent plane).
class AverageIntersectionStrategy extends IntersectionCompassStrategy {
  const AverageIntersectionStrategy();

  @override
  LatLng? resolve(List<LatLng> intersections) {
    if (intersections.isEmpty) {
      return null;
    }
    return centroidLatLng(intersections);
  }

  @override
  bool operator ==(Object other) => other is AverageIntersectionStrategy;

  @override
  int get hashCode => 3;
}

/// Uses the intersection at [index] in the current intersection list.
class IndexedIntersectionStrategy extends IntersectionCompassStrategy {
  const IndexedIntersectionStrategy(this.index);

  final int index;

  @override
  LatLng? resolve(List<LatLng> intersections) {
    if (index < 0 || index >= intersections.length) {
      return null;
    }
    return intersections[index];
  }

  @override
  bool operator ==(Object other) =>
      other is IndexedIntersectionStrategy && other.index == index;

  @override
  int get hashCode => Object.hash(4, index);
}
