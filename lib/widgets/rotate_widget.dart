import 'dart:math' as math;

import 'package:flutter/material.dart';

class RotatedWidget extends StatefulWidget {
  final Widget child;
  final double angle;
  final Duration duration;

  RotatedWidget({
    required this.child,
    required this.angle,
    this.duration = const Duration(milliseconds: 5000),
  });

  @override
  _RotatedWidgetState createState() => _RotatedWidgetState();
}

class _RotatedWidgetState extends State<RotatedWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: widget.duration);

    _animation =
        Tween<double>(begin: 0, end: widget.angle).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RotatedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.angle != oldWidget.angle) {
      _animation = Tween<double>(begin: 0, end: widget.angle)
          .animate(_controller)
            ..addListener(() {
              setState(() {});
            });

      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 180 * _animation.value, // convert degree to radian
      child: widget.child,
    );
  }
}
