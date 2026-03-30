import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/intersection_compass_strategy.dart';
import '../utils/geometry.dart';
import '../viewmodels/triangulation_viewmodel.dart';
import 'intersection_compass.dart';
import 'path_tile.dart';

class TriangulationHomePage extends StatefulWidget {
  const TriangulationHomePage({super.key});

  @override
  State<TriangulationHomePage> createState() => _TriangulationHomePageState();
}

class _TriangulationHomePageState extends State<TriangulationHomePage> {
  late final TriangulationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TriangulationViewModel();
    _viewModel.initLocationAndCompass();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _viewModel,
      child: Consumer<TriangulationViewModel>(
        builder: (context, viewModel, child) {
          final xs = viewModel.intersections;
          final compassTarget = viewModel.compassTarget;
          final highlightIdx = viewModel.highlightIndex;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Speleo Trace'),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (viewModel.locationError != null)
                  MaterialBanner(
                    content: Text(viewModel.locationError!),
                    actions: [
                      TextButton(
                        onPressed: () => openAppSettings(),
                        child: const Text('Settings'),
                      ),
                    ],
                  ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: viewModel.center == null
                          ? const Center(child: CircularProgressIndicator())
                          : Stack(
                              children: [
                                FlutterMap(
                                  mapController: viewModel.mapController,
                                  options: MapOptions(
                                    initialCenter: viewModel.center!,
                                    initialZoom: 17,
                                    initialRotation: viewModel.headingDeg ?? 0,
                                    interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.all &
                                          ~InteractiveFlag.rotate,
                                    ),
                                    onMapReady: viewModel.onMapReady,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.example.speleo_trace',
                                    ),
                                    PolylineLayer(
                                      polylines: [
                                        for (final p in viewModel.paths)
                                          Polyline(
                                            points: [
                                              pointAhead(
                                                p.point,
                                                p.headingDeg + 180,
                                                kHalfLineM,
                                              ),
                                              pointAhead(
                                                p.point,
                                                p.headingDeg,
                                                kHalfLineM,
                                              ),
                                            ],
                                            color: p.color,
                                            strokeWidth: 3,
                                          ),
                                      ],
                                    ),
                                    CircleLayer(
                                      circles: [
                                        for (final p in viewModel.paths)
                                          CircleMarker(
                                            point: p.point,
                                            radius: 8,
                                            color: p.color.withOpacity(0.35),
                                            borderStrokeWidth: 2,
                                            borderColor: p.color,
                                          ),
                                      ],
                                    ),
                                    if (xs.isNotEmpty)
                                      CircleLayer(
                                        circles: [
                                          for (var i = 0; i < xs.length; i++)
                                            CircleMarker(
                                              point: xs[i],
                                              radius: i == highlightIdx ? 10 : 7,
                                              color: Colors.black.withOpacity(0.25),
                                              borderStrokeWidth: 2,
                                              borderColor: i == highlightIdx
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                        ],
                                      ),
                                    if (compassTarget != null &&
                                        viewModel.compassStrategy is AverageIntersectionStrategy)
                                      CircleLayer(
                                        circles: [
                                          CircleMarker(
                                            point: compassTarget,
                                            radius: 11,
                                            color: Colors.amber.withOpacity(0.4),
                                            borderStrokeWidth: 2,
                                            borderColor: Colors.black87,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                Positioned(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                  child: Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            viewModel.center == null
                                                ? 'GPS: …'
                                                : 'GPS: ${viewModel.center!.latitude.toStringAsFixed(6)}, '
                                                    '${viewModel.center!.longitude.toStringAsFixed(6)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            viewModel.headingDeg == null
                                                ? 'Heading: …'
                                                : 'Heading: ${viewModel.headingDeg!.toStringAsFixed(1)}°',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (compassTarget != null &&
                                    viewModel.center != null &&
                                    viewModel.headingDeg != null)
                                  Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: IntersectionCompass(
                                      user: viewModel.center!,
                                      headingDeg: viewModel.headingDeg!,
                                      target: compassTarget,
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            FilledButton(
                              onPressed: viewModel.paths.length >= kMaxPaths
                                  ? null
                                  : () => viewModel.onSetPath(context),
                              child: const Text('Set Path'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: viewModel.paths.isEmpty
                                  ? null
                                  : viewModel.onClear,
                              child: const Text('Clear'),
                            ),
                            const Spacer(),
                            Text(
                              '${viewModel.paths.length}/$kMaxPaths paths',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                        if (viewModel.paths.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Recorded paths',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: viewModel.paths.length,
                            itemBuilder: (context, index) {
                              final p = viewModel.paths[index];
                              return PathTile(
                                entry: p,
                                onHeadingChanged: viewModel.updatePathHeading,
                              );
                            },
                          ),
                        ],
                        if (xs.length >= 2) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Intersections (${xs.length})',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: xs.length,
                            itemBuilder: (context, i) {
                              final p = xs[i];
                              final d = viewModel.center == null
                                  ? null
                                  : distanceMeters(viewModel.center!, p);
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(
                                  '${p.latitude.toStringAsFixed(5)}, '
                                  '${p.longitude.toStringAsFixed(5)}',
                                ),
                                subtitle: d == null
                                    ? null
                                    : Text('${d.toStringAsFixed(1)} m from you'),
                              );
                            },
                          ),
                        ] else if (xs.length == 1) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Intersection: '
                            '${xs.first.latitude.toStringAsFixed(5)}, '
                            '${xs.first.longitude.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (xs.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Compass target',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<IntersectionCompassStrategy>(
                            initialValue: viewModel.compassStrategy,
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem(
                                value: FirstIntersectionStrategy(),
                                child: Text('First always'),
                              ),
                              const DropdownMenuItem(
                                value: LastIntersectionStrategy(),
                                child: Text('Last always'),
                              ),
                              const DropdownMenuItem(
                                value: AverageIntersectionStrategy(),
                                child: Text('Average'),
                              ),
                              for (var i = 0; i < xs.length; i++)
                                DropdownMenuItem(
                                  value: IndexedIntersectionStrategy(i),
                                  child: Text('Intersection ${i + 1}'),
                                ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                viewModel.setCompassStrategy(v);
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}