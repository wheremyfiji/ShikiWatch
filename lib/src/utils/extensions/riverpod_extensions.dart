import 'dart:async';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

extension CancelTokenExtension on AutoDisposeRef {
  /// creates a token to cancel API requests
  CancelToken cancelToken() {
    var token = CancelToken();
    onCancel(token.cancel);
    return token;
  }
}

// extension CacheExtension on AutoDisposeRef {
//   KeepAliveLink cacheFor([Duration duration = const Duration(seconds: 4)]) {
//     Timer? timer;
//     // prevents being disposed
//     final link = keepAlive();

//     // when the provider is no longer used (removed all listeners)
//     // the timer will be started with the given cache duration
//     // when the time expires, the link will be closed,
//     // and the provider will dispose itself
//     onCancel(() => timer = Timer(duration, link.close));

//     // when we recall the provider again
//     // the timer will be canceled and the link will no longer close.
//     onResume(() => timer?.cancel());

//     /// if the link is closed, [onDispose] will be called
//     /// and if there's a timer it will be canceled
//     onDispose(() => timer?.cancel());

//     return link;
//   }
// }

extension DebounceExtension on Ref {
  /// delays the execution of the code for the given duration,
  /// if any dependency changes during the period,
  /// the timer will reset and restart
  /// if nothing changes, the rest of the code will be executed.
  Future<void> debounce([
    Duration duration = const Duration(milliseconds: 350),
  ]) {
    final completer = Completer<void>();

    /// creates a timer with the given duration
    /// when the time expires, and the completer hasn't completed yet, complete it.
    /// and the debounce function lets the rest of the code executed
    final timer = Timer(duration, () {
      if (!completer.isCompleted) completer.complete();
    });

    /// if provider disposed and the completer hasn't completed yet
    /// cancel the timer and throw canceled error
    onDispose(() {
      timer.cancel();
      if (!completer.isCompleted) {
        completer.completeError(StateError('Canceled'));
      }
    });

    return completer.future;
  }
}
