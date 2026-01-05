import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import '../../../utils/app_utils.dart';
import '../../../utils/player/player_shaders.dart';
import '../../../utils/player/player_utils.dart';

import 'player_provider.dart';

final availableShadersProvider = Provider<List<PlayerShader>>((ref) {
  if (AppUtils.instance.isDesktop) {
    return kPlayerShaders;
  }

  const b = ['4k-a', '4k-a+a'];

  return kPlayerShaders.where((e) => !b.contains(e.id)).toList();
}, name: 'availableShadersProvider');

final activeShadersProvider =
    NotifierProvider<ActiveShadersNotifier, List<PlayerShader>>(
  () => ActiveShadersNotifier(),
  name: 'activeShadersProvider',
);

class ActiveShadersNotifier extends Notifier<List<PlayerShader>> {
  @override
  List<PlayerShader> build() {
    return [];
  }

  void toggle(PlayerShader shader) {
    if (state.contains(shader)) {
      state = state.where((s) => s.id != shader.id).toList();
      return;
    }

    if (shader.isExclusive) {
      state = [shader];
      return;
    }

    final hasExclusiveActive = state.any((s) => s.isExclusive);

    if (hasExclusiveActive) {
      state = [shader];
    } else {
      state = [...state, shader];
    }
  }

  void clearAll() {
    state = [];
  }
}

final shaderApplicatorProvider = FutureProvider.autoDispose<void>((ref) async {
  final playerLogger = PlayerLogger();

  final player = ref.watch(playerStateProvider.select((s) => (s.player)));
  final activeShaders = ref.watch(activeShadersProvider);

  await player.stream.buffer.first;

  final separator = Platform.isWindows ? ';' : ':';

  final String targetValue = activeShaders.isEmpty
      ? ''
      : activeShaders
          .map((shader) => PlayerUtils.instance.shadersDir + shader.filePath)
          .join(separator);

  final nativePlayer = player.platform as NativePlayer;

  playerLogger.addLog(
    '[shaders] targetValue: $targetValue',
  );

  try {
    final String currentValue = await nativePlayer.getProperty('glsl-shaders');

    playerLogger.addLog(
      '[shaders] currentValue: $currentValue',
    );

    if (currentValue == targetValue) {
      return;
    }
  } catch (e) {
    playerLogger.addLog(
      '[shaders] error getting glsl-shaders property: $e',
    );
  }

  playerLogger.addLog(
    '[shaders] set: $targetValue',
  );

  await nativePlayer.setProperty('glsl-shaders', targetValue);
}, name: 'shaderApplicatorProvider');
