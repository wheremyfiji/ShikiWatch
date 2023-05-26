import 'package:flutter/material.dart';

Future<T?> showSlideUp<T>(
  BuildContext context,
  Widget child, {
  bool root = true,
}) =>
    showDialog<T>(
      context: context,
      builder: (context) => PopUpAnimation(child),
      useRootNavigator: root,
      barrierColor: Theme.of(context).colorScheme.background.withAlpha(170),
      //barrierColor: Colors.black.withOpacity(0.8),
    );

class PopUpAnimation extends StatefulWidget {
  const PopUpAnimation(this.child, {super.key});

  final Widget child;

  @override
  PopUpAnimationState createState() => PopUpAnimationState();
}

class PopUpAnimationState extends State<PopUpAnimation>
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
