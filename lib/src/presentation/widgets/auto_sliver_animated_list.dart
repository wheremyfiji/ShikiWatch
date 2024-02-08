import 'package:flutter/material.dart';

import 'package:diffutil_dart/diffutil.dart' as diffutil;

class AutoAnimatedSliverList<T> extends StatefulWidget {
  const AutoAnimatedSliverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.useAnimationRemove = false,
  });

  /// List of items that the [itemBuilder] should animate widgets for.
  final List<T> items;

  /// Called, as needed, to build list item widgets.
  final Widget Function(BuildContext, T, int, Animation<double>) itemBuilder;

  final bool useAnimationRemove;

  @override
  State<AutoAnimatedSliverList<T>> createState() =>
      _AutoAnimatedSliverListState<T>();
}

class _AutoAnimatedSliverListState<T> extends State<AutoAnimatedSliverList<T>> {
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();

  List<T> get _items => widget.items;

  @override
  void didUpdateWidget(covariant AutoAnimatedSliverList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleListUpdated(oldWidget.items);
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: _listKey,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) => widget.itemBuilder(
        context,
        _items[index],
        index,
        animation,
      ),
    );
  }

  void _handleListUpdated(List<T> oldList) {
    final listState = _listKey.currentState;

    if (listState == null) return;

    final newList = widget.items;
    final diffResult = diffutil.calculateListDiff<T>(oldList, newList);
    final updates = diffResult.getUpdates(batch: false);

    if (updates.isEmpty) return;

    for (final update in updates) {
      update.when(
        move: (from, to) {
          _handleRemoveItem(from);
          _handleInsertItem(to);
        },
        insert: (to, _) => _handleInsertItem(to),
        remove: (from, _) => _handleRemoveItem(
          from,
          useAnimation: widget.useAnimationRemove,
        ),
        change: (_, __) {},
      );
    }
  }

  void _handleInsertItem(int to) => _listKey.currentState?.insertItem(to);

  void _handleRemoveItem(
    int from, {
    bool useAnimation = true,
  }) =>
      _listKey.currentState?.removeItem(from, (context, animation) {
        final item = _items.elementAtOrNull(from);
        if (item == null || !useAnimation) return Container();
        return widget.itemBuilder(context, item, from, animation);
      });
}

/// Transition that animates the size and the opacity of a widget.
class SizeFadeTransition extends StatefulWidget {
  /// Creates transition that animates the size and the opacity of a widget.
  const SizeFadeTransition({
    Key? key,
    required this.animation,
    required this.child,
    this.sizeFraction = 0.7,
    this.sizeAxisAlignment = -1.0,
  }) : super(key: key);

  /// The animation that controls the transition.
  final Animation<double> animation;

  /// The widget to animate.
  final Widget child;

  /// How long the [Interval] for the [SizeTransition] should be.
  ///
  /// The value must be between 0 and 1. Defaults to 0.7.
  ///
  /// For example a `sizeFraction` of `0.7` would result in `Interval(0.0, 0.7)`
  /// for the size animation and `Interval(0.7, 1.0)` for the opacity animation.
  final double sizeFraction;

  /// Describes how to align the child along the axis that [sizeFactor] is
  /// modifying.
  ///
  /// A value of -1.0 indicates the top when [axis] is [Axis.vertical], and the
  /// start when [axis] is [Axis.horizontal]. The start is on the left when the
  /// text direction in effect is [TextDirection.ltr] and on the right when it
  /// is [TextDirection.rtl].
  ///
  /// A value of 1.0 indicates the bottom or end, depending upon the [axis].
  ///
  /// A value of 0.0 (the default) indicates the center for either [axis] value.
  final double sizeAxisAlignment;

  @override
  State<SizeFadeTransition> createState() => _SizeFadeTransitionState();
}

class _SizeFadeTransitionState extends State<SizeFadeTransition> {
  late Animation<double> _size;
  late Animation<double> _opacity;
  @override
  void initState() {
    super.initState();
    _handleAnimationUpdated();
  }

  @override
  void didUpdateWidget(SizeFadeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleAnimationUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _size,
      axisAlignment: widget.sizeAxisAlignment,
      child: FadeTransition(
        opacity: _opacity,
        child: widget.child,
      ),
    );
  }

  void _handleAnimationUpdated() {
    final curvedAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeInOut,
    );
    _size = CurvedAnimation(
      curve: Interval(0, widget.sizeFraction),
      parent: curvedAnimation,
    );
    _opacity = CurvedAnimation(
      curve: Interval(widget.sizeFraction, 1),
      parent: curvedAnimation,
    );
  }
}
