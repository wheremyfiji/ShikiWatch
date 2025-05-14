import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../utils/app_utils.dart';

class MouseBackButtonWrapper extends StatelessWidget {
  const MouseBackButtonWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => AppUtils.instance.isDesktop
      ? RawGestureDetector(
          gestures: <Type, GestureRecognizerFactory>{
            _MouseBackButtonRecognizer: GestureRecognizerFactoryWithHandlers<
                _MouseBackButtonRecognizer>(
              () => _MouseBackButtonRecognizer(),
              (instance) => instance.onTapDown =
                  (details) => context.canPop() ? context.pop() : null,
            ),
          },
          child: child,
        )
      : child;
}

class _MouseBackButtonRecognizer extends BaseTapGestureRecognizer {
  GestureTapDownCallback? onTapDown;

  @override
  void handleTapCancel({
    required PointerDownEvent down,
    PointerCancelEvent? cancel,
    required String reason,
  }) {}

  @override
  void handleTapDown({required PointerDownEvent down}) {
    final TapDownDetails details = TapDownDetails(
      globalPosition: down.position,
      localPosition: down.localPosition,
      kind: getKindForPointer(down.pointer),
    );

    if (down.buttons == kBackMouseButton && onTapDown != null) {
      invokeCallback<void>('onTapDown', () => onTapDown!(details));
    }
  }

  @override
  void handleTapUp({
    required PointerDownEvent down,
    required PointerUpEvent up,
  }) {}
}
