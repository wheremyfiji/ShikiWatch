import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';

import '../../domain/enums/library_layout_mode.dart';
import '../../domain/enums/library_state.dart';

const _themeModeKey = 'themeModeKey';
const _dynamicColorsKey = 'dynamicColorsKey';
const _oledModeKey = 'oledModeKey';
const _libraryStartFragmentKey = 'libraryStartFragmentKey';
const _playerDiscordRpcKey = 'playerDiscordRpcKey';
const _libraryLayoutModeKey = 'libraryLayoutModeKey';

final preferencesProvider = Provider<PreferencesService>((ref) {
  throw Exception('preferencesProvider not initialized');
}, name: 'preferencesProvider');

class PreferencesService {
  final SharedPreferences _preferences;

  PreferencesService(this._preferences);

  static Future<PreferencesService> initialize() async {
    return PreferencesService(await SharedPreferences.getInstance());
  }

  SharedPreferences get sharedPreferences => _preferences;

  ThemeMode getTheme() {
    final value = _preferences.getString(_themeModeKey);
    if (value == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values.firstWhereOrNull((theme) => theme.name == value) ??
        ThemeMode.system;
  }

  Future<void> setTheme(ThemeMode theme) async {
    await _preferences.setString(_themeModeKey, theme.name);
  }

  bool getDynamicColors() {
    final value = _preferences.getBool(_dynamicColorsKey);

    if (value == null) {
      return false;
    }

    return value;
  }

  Future<void> setDynamicColors(bool v) async {
    await _preferences.setBool(_dynamicColorsKey, v);
  }

  bool getOledMode() {
    final value = _preferences.getBool(_oledModeKey);

    if (value == null) {
      return false;
    }

    return value;
  }

  Future<void> setOledMode(bool v) async {
    await _preferences.setBool(_oledModeKey, v);
  }

  LibraryFragmentMode getLibraryStartFragment() {
    final value = _preferences.getString(_libraryStartFragmentKey);
    if (value == null) {
      return LibraryFragmentMode.anime;
    }
    return LibraryFragmentMode.values
            .firstWhereOrNull((fragment) => fragment.name == value) ??
        LibraryFragmentMode.anime;
  }

  Future<void> setLibraryStartFragment(LibraryFragmentMode fragment) async {
    await _preferences.setString(_libraryStartFragmentKey, fragment.name);
  }

  bool getPlayerDiscordRpc() {
    final value = _preferences.getBool(_playerDiscordRpcKey);

    if (value == null) {
      return false;
    }

    return value;
  }

  Future<void> setPlayerDiscordRpc(bool v) async {
    await _preferences.setBool(_playerDiscordRpcKey, v);
  }

  LibraryLayoutMode getLibraryLayout() {
    final value = _preferences.getString(_libraryLayoutModeKey);
    if (value == null) {
      return LibraryLayoutMode.list;
    }
    return LibraryLayoutMode.values
            .firstWhereOrNull((theme) => theme.name == value) ??
        LibraryLayoutMode.list;
  }

  Future<void> setLibraryLayout(LibraryLayoutMode layout) async {
    await _preferences.setString(_libraryLayoutModeKey, layout.name);
  }
}
