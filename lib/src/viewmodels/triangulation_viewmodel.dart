import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/intersection_compass_strategy.dart';
import '../models/path_entry.dart';
import '../utils/geometry.dart';

const int kMaxPaths = 10;
const double kMapRadiusM = 33;
const double kHalfLineM = 80;

const List<Color> kPathColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.deepOrange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.amber,
  Colors.brown,
  Colors.cyan,
];

class TriangulationViewModel extends ChangeNotifier {
  final MapController _mapController = MapController();

  StreamSubscription<Position>? _posSub;
  StreamSubscription<CompassEvent>? _compassSub;

  LatLng? _center;
  double? _headingDeg;
  String? _locationError;

  final List<PathEntry> _paths = [];
  int _nextPathId = 1;

  IntersectionCompassStrategy _compassStrategy = const FirstIntersectionStrategy();
  bool _mapReady = false;
  bool _didInitialFit = false;

  MapController get mapController => _mapController;
  LatLng? get center => _center;
  double? get headingDeg => _headingDeg;
  String? get locationError => _locationError;
  List<PathEntry> get paths => _paths;
  IntersectionCompassStrategy get compassStrategy => _compassStrategy;
  bool get mapReady => _mapReady;

  List<LatLng> get intersections {
    if (_paths.length < 2) {
      return [];
    }
    final raw = _paths
        .map((e) => (point: e.point, headingDeg: e.headingDeg))
        .toList();
    return pairwiseIntersections(raw);
  }

  void initLocationAndCompass() async {
    final loc = await Permission.locationWhenInUse.request();
    if (!loc.isGranted) {
      _locationError = 'Location permission denied.';
      notifyListeners();
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationError = 'Location services are disabled.';
      notifyListeners();
      return;
    }

    try {
      final first = await Geolocator.getCurrentPosition();
      _applyPosition(first);
    } catch (e) {
      _locationError = 'Could not read GPS: $e';
      notifyListeners();
    }

    const settings = LocationSettings(
      distanceFilter: 2,
      accuracy: LocationAccuracy.best,
    );
    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
      _applyPosition,
      onError: (_) {},
    );

    _compassSub = FlutterCompass.events?.listen((event) {
      final h = event.heading;
      if (h == null) {
        return;
      }
      _headingDeg = normalizeHeading0360(h);
      notifyListeners();
      _syncMapCamera();
    });
  }

  void _applyPosition(Position p) {
    final ll = LatLng(p.latitude, p.longitude);
    _center = ll;
    _locationError = null;
    notifyListeners();
    _syncMapCamera();
    _maybeInitialFit();
  }

  void _maybeInitialFit() {
    if (!_mapReady || _didInitialFit || _center == null) {
      return;
    }
    _didInitialFit = true;
    final c = _center!;
    final dLat = kMapRadiusM / 111320.0;
    final dLon = kMapRadiusM / (111320.0 * math.cos(c.latitude * math.pi / 180.0));
    final bounds = LatLngBounds(
      LatLng(c.latitude - dLat, c.longitude - dLon),
      LatLng(c.latitude + dLat, c.longitude + dLon),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(28),
        ),
      );
      _syncMapCamera();
    });
  }

  void _syncMapCamera() {
    final c = _center;
    if (c == null || !_mapReady) {
      return;
    }
    final h = _headingDeg ?? 0;
    _mapController.moveAndRotate(c, _mapController.camera.zoom, h);
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _compassSub?.cancel();
    super.dispose();
  }

  void onMapReady() {
    _mapReady = true;
    notifyListeners();
    _maybeInitialFit();
    _syncMapCamera();
  }

  Future<void> onSetPath(BuildContext context) async {
    if (_paths.length >= kMaxPaths) {
      return;
    }
    final pos = _center;
    final head = _headingDeg;
    if (pos == null || head == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waiting for GPS and compass…'),
          ),
        );
      }
      return;
    }

    final edited = await showDialog<double>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(
          text: normalizeHeading0360(head).toStringAsFixed(1),
        );
        return AlertDialog(
          title: const Text('Set path'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Lat: ${pos.latitude.toStringAsFixed(6)}\n'
                'Lon: ${pos.longitude.toStringAsFixed(6)}',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Heading (° from north)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(controller.text.trim());
                if (v == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a numeric heading in degrees.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx, normalizeHeading0360(v));
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || edited == null) {
      return;
    }

    _paths.add(
      PathEntry(
        id: _nextPathId++,
        point: pos,
        headingDeg: edited,
        color: kPathColors[(_paths.length - 1) % kPathColors.length],
      ),
    );
    _clampCompassStrategy();
    notifyListeners();
  }

  void onClear() {
    _paths.clear();
    _compassStrategy = const FirstIntersectionStrategy();
    notifyListeners();
  }

  void _clampCompassStrategy() {
    final xs = intersections;
    if (_compassStrategy is IndexedIntersectionStrategy) {
      final idx = (_compassStrategy as IndexedIntersectionStrategy).index;
      if (xs.isEmpty) {
        return;
      }
      if (idx < 0 || idx >= xs.length) {
        _compassStrategy = IndexedIntersectionStrategy(xs.length - 1);
      }
    }
  }

  void updatePathHeading(PathEntry path, double heading) {
    final i = _paths.indexWhere((p) => p.id == path.id);
    if (i < 0) {
      return;
    }
    _paths[i] = PathEntry(
      id: path.id,
      point: path.point,
      headingDeg: normalizeHeading0360(heading),
      color: path.color,
    );
    _clampCompassStrategy();
    notifyListeners();
  }

  int? _intersectionHighlightIndex(
    List<LatLng> xs,
    IntersectionCompassStrategy strategy,
  ) {
    if (xs.isEmpty) {
      return null;
    }
    if (strategy is FirstIntersectionStrategy) {
      return 0;
    }
    if (strategy is LastIntersectionStrategy) {
      return xs.length - 1;
    }
    if (strategy is IndexedIntersectionStrategy) {
      final i = strategy.index;
      if (i < 0 || i >= xs.length) {
        return null;
      }
      return i;
    }
    return null;
  }

  IntersectionCompassStrategy _effectiveStrategy(List<LatLng> xs) {
    if (xs.isEmpty) {
      return _compassStrategy;
    }
    if (_compassStrategy is IndexedIntersectionStrategy) {
      final i = (_compassStrategy as IndexedIntersectionStrategy).index;
      if (i < 0 || i >= xs.length) {
        return IndexedIntersectionStrategy(xs.length - 1);
      }
    }
    return _compassStrategy;
  }

  LatLng? get compassTarget {
    final xs = intersections;
    final strat = _effectiveStrategy(xs);
    return strat.resolve(xs);
  }

  int? get highlightIndex {
    final xs = intersections;
    final strat = _effectiveStrategy(xs);
    return _intersectionHighlightIndex(xs, strat);
  }

  void setCompassStrategy(IntersectionCompassStrategy strategy) {
    _compassStrategy = strategy;
    notifyListeners();
  }
}