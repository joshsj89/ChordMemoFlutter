import 'package:flutter/material.dart';

/// A widget that wraps an expandable tile.
class ExpandableTileWrapper extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    bool isExpanded,
    void Function(bool) onExpansionChanged,
  ) builder;
  final void Function(bool isExpanded)? onExpansionChanged;
  final void Function()? onExpansionComplete;
  final Key? tileKey;

  const ExpandableTileWrapper({
    Key? key,
    required this.builder,
    this.onExpansionChanged,
    required this.onExpansionComplete,
    this.tileKey,
  }) : super(key: key);

  @override
  State<ExpandableTileWrapper> createState() => _ExpandableTileWrapperState();
}

class _ExpandableTileWrapperState extends State<ExpandableTileWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        widget.onExpansionComplete?.call();
      }
    });

    // Initially expanded
    _controller.value = 1.0;
  }

  void _handleExpansionChanged(bool expanded) {
    setState(() {
      _isExpanded = expanded;
    });

    if (expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    widget.onExpansionChanged?.call(expanded);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _isExpanded, _handleExpansionChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    
    super.dispose();
  }
}