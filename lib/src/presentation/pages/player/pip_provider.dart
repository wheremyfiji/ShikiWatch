import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:floating/floating.dart';

import 'player_provider.dart';

final floatingProvider = Provider<Floating>(
  (ref) => Floating(),
  name: 'floatingProvider',
);

final pipAvailabilityProvider =
    NotifierProvider.autoDispose<PipAvailabilityNotifier, bool>(
  () => PipAvailabilityNotifier(),
  name: 'pipAvailabilityProvider',
);

class PipAvailabilityNotifier extends AutoDisposeNotifier<bool> {
  @override
  bool build() {
    _checkAvailability();
    return false;
  }

  Future<void> _checkAvailability() async {
    final player = ref.read(playerStateProvider.select((s) => (s.player)));
    await player.stream.buffer.first;

    try {
      final floating = ref.read(floatingProvider);
      final isAvailable = await floating.isPipAvailable;
      state = isAvailable;
    } catch (_, __) {
      state = false;
    }
  }
}
