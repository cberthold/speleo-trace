import 'package:flutter/material.dart';

import '../models/path_entry.dart';

class PathTile extends StatefulWidget {
  const PathTile({
    super.key,
    required this.entry,
    required this.onHeadingChanged,
  });

  final PathEntry entry;
  final void Function(PathEntry path, double heading) onHeadingChanged;

  @override
  State<PathTile> createState() => _PathTileState();
}

class _PathTileState extends State<PathTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.entry.headingDeg.toStringAsFixed(1),
    );
  }

  @override
  void didUpdateWidget(covariant PathTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.headingDeg != widget.entry.headingDeg &&
        oldWidget.entry.id == widget.entry.id) {
      _controller.text = widget.entry.headingDeg.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: widget.entry.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${widget.entry.point.latitude.toStringAsFixed(5)}, '
              '${widget.entry.point.longitude.toStringAsFixed(5)}',
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 88,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                isDense: true,
                labelText: '°',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (s) {
                final v = double.tryParse(s.trim());
                if (v != null) {
                  widget.onHeadingChanged(widget.entry, v);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}