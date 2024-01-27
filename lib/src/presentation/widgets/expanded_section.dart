import 'package:flutter/material.dart';

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;

  const ExpandedSection({
    super.key,
    this.expand = false,
    required this.child,
  });

  @override
  State<ExpandedSection> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late CurvedAnimation curve;
  late Animation<double> animation;

  late CurvedAnimation shaderCurve;
  late Animation<double> shaderAnimation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    curve = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );

    animation = Tween(begin: 0.4, end: 1.0).animate(curve);

    // ---------------------------

    shaderCurve = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );

    shaderAnimation = Tween(begin: 0.0, end: 1.0).animate(curve);
  }

  void _runExpandCheck() {
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: -1.0,
      sizeFactor: animation,
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4],
            colors: [
              Colors.black,
              Colors.black.withOpacity(shaderAnimation.value),
            ],
          ).createShader(
            Rect.fromLTRB(0, 0, rect.width, rect.height),
          );
        },
        blendMode: BlendMode.dstIn,
        child: widget.child,
      ),
    );

    // return SizeTransition(
    //   axisAlignment: -1.0,
    //   sizeFactor: animation,
    //   child: widget.child,
    // );
  }
}
