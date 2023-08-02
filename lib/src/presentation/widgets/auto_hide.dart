import 'dart:async';

import 'package:flutter/material.dart';

class AutoHideController extends ChangeNotifier {
  bool _disposed = false;
  bool _isMount = false;
  bool _isVisible;
  final Duration _duration;

  Timer? timer;

  AutoHideController({required Duration duration, bool initialValue = false})
      : _duration = duration,
        _isVisible = initialValue;

  bool get isVisible => _isVisible;
  bool get isMount => _isMount;

  void toggle() {
    _isMount = true;
    _isVisible = !_isVisible;
    notifyListeners();

    timer?.cancel();
    timer = Timer(_duration, () {
      _isVisible = false;

      notifyListeners();
    });
  }

  void show() {
    _isMount = true;
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

  void permShow() {
    _isMount = true;
    //timer?.cancel();
    _isVisible = true;
    notifyListeners();
  }

  void setMount() {
    if (_isVisible) {
      return;
    }

    _isMount = false;
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
    return AnimatedOpacity(
      curve: Curves.easeInOut,
      opacity: controller.isVisible ? 1.0 : 0.0,
      duration: switchDuration,
      onEnd: controller.setMount,
      child: controller.isMount ? child : null,
    );
  }
}
