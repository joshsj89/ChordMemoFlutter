import 'package:flutter/material.dart';

/// A widget that reports its size to the parent widget.
class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final void Function(double size) onSizeChanged;

  const SizeReportingWidget({
    Key? key,
    required this.child,
    required this.onSizeChanged,
  }) : super(key: key);

  @override
  State<SizeReportingWidget> createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  final GlobalKey _key = GlobalKey();
  double? oldHeight;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) { // Ensure the size is reported after the widget is built
      _reportSize();
    });
  }

  @override
  void didUpdateWidget(SizeReportingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((_) { // Ensure the size is reported after the widget rebuilds
      _reportSize();
    });
  }

  void _reportSize() {
    final context = _key.currentContext;

    if (context == null) return;

    final newHeight = context.size?.height ?? 0;
    if (oldHeight != newHeight) {
      oldHeight = newHeight;
      widget.onSizeChanged(newHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(key: _key, child: widget.child);
  }
}