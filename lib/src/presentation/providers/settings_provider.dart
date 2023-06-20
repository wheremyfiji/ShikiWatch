import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/enums/library_layout_mode.dart';
import '../../domain/enums/library_state.dart';
import '../../services/preferences/preferences_service.dart';
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
      dynamicColors: _preferencesService.getDynamicColors(),
      oledMode: _preferencesService.getOledMode(),
      libraryFragment: _preferencesService.getLibraryStartFragment(),
      playerDiscordRpc: _preferencesService.getPlayerDiscordRpc(),
      libraryLayout: _preferencesService.getLibraryLayout(),
    );
  }

  Future<void> setTheme(ThemeMode theme) async {
    await _preferencesService.setTheme(theme);
    state = state.copyWith(
      theme: theme,
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
}
