import 'package:flutter/material.dart';

import '../../utils/extensions/buildcontext.dart';

class FlexibleSliverAppBar extends StatelessWidget {
  const FlexibleSliverAppBar({
    super.key,
    required this.title,
    required this.bottomContent,
    this.automaticallyImplyLeading = true,
    this.floating = false,
    this.pinned = true,
    this.leading,
    this.actions,
  });

  final Widget title;
  final Widget? leading;
  final Widget bottomContent;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final bool floating;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      pinned: pinned,
      floating: floating,
      leading: leading,
      title: title,
      actions: actions,
      expandedHeight: kToolbarHeight * 2,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: kToolbarHeight + context.padding.top,
            ),
            bottomContent,
          ],
        ),
      ),
    );
  }
}
