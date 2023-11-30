import 'dart:async';

import 'package:flutter/material.dart';

class AutoHideController extends ChangeNotifier {
  bool _disposed = false;
  bool _isVisible;
  final Duration _duration;

  Timer? timer;

  AutoHideController({required Duration duration, bool initialValue = false})
      : _duration = duration,
        _isVisible = initialValue;

  bool get isVisible => _isVisible;

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();

    timer?.cancel();
    timer = Timer(_duration, () {
      _isVisible = false;

      notifyListeners();
    });
  }

  void show() {
    _isVisible = true;
    notifyListeners();

    timer?.cancel();
    timer = Timer(_duration, () {
      _isVisible = false;

      notifyListeners();
    });
  }

  void hide() {
    //timer?.cancel();
    _isVisible = false;
    notifyListeners();
  }

  void cancel() {
    timer?.cancel();
  }

  void permShow() {
    //timer?.cancel();
    _isVisible = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;

    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}

class AutoHide extends StatelessWidget {
  final Widget? child;
  final AutoHideController controller;
  final Duration switchDuration;

  const AutoHide({
    super.key,
    this.child,
    required this.controller,
    required this.switchDuration,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return IgnorePointer(
          ignoring: !controller.isVisible,
          child: AnimatedOpacity(
            curve: Curves.easeInOut,
            duration: switchDuration,
            opacity: controller.isVisible ? 1.0 : 0.0,
            child: child,
          ),
        );
      },
    );
  }
}
