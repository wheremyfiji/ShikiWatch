import 'package:flutter/material.dart';

class AutoKeepAlive extends StatefulWidget {
  final Widget child;

  const AutoKeepAlive({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AutoKeepAlive> createState() => _AutomaticKeepAliveState();
}

class _AutomaticKeepAliveState extends State<AutoKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
