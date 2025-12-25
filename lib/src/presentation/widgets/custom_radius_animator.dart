import 'package:flutter/material.dart';

class CustomRadiusAnimator extends StatefulWidget {
  final Widget Function(BuildContext context, double radius) builder;
  final double targetRadius;
  final Duration duration;

  const CustomRadiusAnimator({
    required this.builder,
    required this.targetRadius,
    this.duration = const Duration(milliseconds: 250),
    Key? key,
  }) : super(key: key);

  @override
  State<CustomRadiusAnimator> createState() => _CustomRadiusAnimatorState();
}

class _CustomRadiusAnimatorState extends State<CustomRadiusAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _radiusAnimation = Tween<double>(
      begin: widget.targetRadius,
      end: widget.targetRadius,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Easing.standard,
    ));

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(CustomRadiusAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetRadius != oldWidget.targetRadius) {
      _radiusAnimation = Tween<double>(
        begin: _radiusAnimation.value,
        end: widget.targetRadius,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Easing.standard,
      ));

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _radiusAnimation.value);
  }
}
