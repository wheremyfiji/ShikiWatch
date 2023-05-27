import 'package:flutter/material.dart';

Future<T?> showSlideUp<T>(
  BuildContext context,
  Widget child, {
  bool root = true,
}) =>
    showDialog<T>(
      context: context,
      builder: (context) => SlideUpAnimation(child),
      useRootNavigator: root,
      barrierColor:
          Theme.of(context).colorScheme.background.withAlpha(230), //170
      //barrierColor: Colors.black,
    );

class SlideUpAnimation extends StatefulWidget {
  const SlideUpAnimation(this.child, {super.key});

  final Widget child;

  @override
  SlideUpAnimationState createState() => SlideUpAnimationState();
}

class SlideUpAnimationState extends State<SlideUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _offsetFloat;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      value: 0.5,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _offsetFloat =
        Tween(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeInOutExpo,
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      SlideTransition(position: _offsetFloat, child: widget.child);
}
