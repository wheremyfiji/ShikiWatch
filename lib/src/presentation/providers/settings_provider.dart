import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/preferences/preferences_service.dart';
import '../../domain/enums/color_scheme_variant.dart';
import '../../domain/enums/library_layout_mode.dart';
import '../../domain/enums/library_state.dart';
import '../../domain/enums/anime_source.dart';
import '../state/settings_state.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
}, name: 'settingsProvider');

class SettingsNotifier extends Notifier<SettingsState> {
  late PreferencesService _preferencesService;

  SettingsNotifier();

  @override
  SettingsState build() {
    _preferencesService = ref.watch(preferencesProvider);

    return SettingsState(
      theme: _preferencesService.getTheme(),
      navDestLabelBehavior: _preferencesService.getNavDestLabelBehavior(),
      dynamicColors: _preferencesService.getDynamicColors(),
      oledMode: _preferencesService.getOledMode(),
      libraryFragment: _preferencesService.getLibraryStartFragment(),
      playerDiscordRpc: _preferencesService.getPlayerDiscordRpc(),
      libraryLayout: _preferencesService.getLibraryLayout(),
      animeSource: _preferencesService.getAnimeSource(),
      playerSpeed: _preferencesService.getPlayerSpeed(),
      playerLongPressSeek: _preferencesService.getPlayerLongPressSeek(),
      playerOrientationLock: _preferencesService.getPlayerOrientationLock(),
      colorSchemeVariant: _preferencesService.getSchemeVariant(),
    );
  }

  Future<void> setTheme(ThemeMode theme) async {
    await _preferencesService.setTheme(theme);
    state = state.copyWith(
      theme: theme,
    );
  }

  Future<void> setColorSchemeVariant(ColorSchemeVariant variant) async {
    await _preferencesService.setSchemeVariant(variant);
    state = state.copyWith(
      colorSchemeVariant: variant,
    );
  }

  Future<void> setNavDestLabelBehavior(
      NavigationDestinationLabelBehavior mode) async {
    await _preferencesService.setNavDestLabelBehavior(mode);
    state = state.copyWith(
      navDestLabelBehavior: mode,
    );
  }

  Future<void> setDynamicColors(bool newValue) async {
    await _preferencesService.setDynamicColors(newValue);
    state = state.copyWith(
      dynamicColors: newValue,
    );
  }

  Future<void> setOledMode(bool newValue) async {
    await _preferencesService.setOledMode(newValue);
    state = state.copyWith(
      oledMode: newValue,
    );
  }

  Future<void> setLibraryStartFragment(LibraryFragmentMode fragment) async {
    await _preferencesService.setLibraryStartFragment(fragment);
    state = state.copyWith(
      libraryFragment: fragment,
    );
  }

  Future<void> setPlayerDiscordRpc(bool newValue) async {
    await _preferencesService.setPlayerDiscordRpc(newValue);
    state = state.copyWith(
      playerDiscordRpc: newValue,
    );
  }

  Future<void> setLibraryLayout(LibraryLayoutMode layout) async {
    await _preferencesService.setLibraryLayout(layout);
    state = state.copyWith(
      libraryLayout: layout,
    );
  }

  Future<void> setAnimeSource(AnimeSource source) async {
    await _preferencesService.setAnimeSource(source);
    state = state.copyWith(
      animeSource: source,
    );
  }

  Future<void> setPlayerSpeed(double speed) async {
    await _preferencesService.setPlayerSpeed(speed);
    state = state.copyWith(
      playerSpeed: speed,
    );
  }

  Future<void> setPlayerLongPressSeek(bool newValue) async {
    await _preferencesService.setPlayerLongPressSeek(newValue);
    state = state.copyWith(
      playerLongPressSeek: newValue,
    );
  }

  Future<void> setPlayerOrientationLock(bool newValue) async {
    await _preferencesService.setPlayerOrientationLock(newValue);
    state = state.copyWith(
      playerOrientationLock: newValue,
    );
  }
}
