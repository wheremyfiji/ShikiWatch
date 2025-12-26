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
  final player = ref.watch(playerStateProvider.select((s) => (s.player)));
  final activeShaders = ref.watch(activeShadersProvider);

  await player.stream.buffer.first;

  if (activeShaders.isEmpty) {
    await (player.platform as NativePlayer).setProperty('glsl-shaders', '');
    return;
  }

  final separator = Platform.isWindows ? ';' : ':';

  final List<String> shaderPaths = activeShaders
      .map((shader) => PlayerUtils.instance.shadersDir + shader.filePath)
      .toList();

  final joinedPaths = shaderPaths.join(separator);

  await (player.platform as NativePlayer)
      .setProperty('glsl-shaders', joinedPaths);
}, name: 'shaderApplicatorProvider');
