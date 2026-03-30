import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class PathEntry {
  PathEntry({
    required this.id,
    required this.point,
    required this.headingDeg,
    required this.color,
  });

  final int id;
  final LatLng point;
  final double headingDeg;
  final Color color;
}