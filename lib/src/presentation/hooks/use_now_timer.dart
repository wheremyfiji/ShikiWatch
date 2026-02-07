import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';

DateTime useNowTimer({Duration updateInterval = const Duration(seconds: 1)}) {
  final state = useState(DateTime.now());

  useEffect(() {
    final timer = Timer.periodic(updateInterval, (_) {
      state.value = DateTime.now();
    });

    return timer.cancel;
  }, [updateInterval]);

  return state.value;
}
