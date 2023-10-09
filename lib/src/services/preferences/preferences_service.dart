import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';

import '../../domain/enums/anime_source.dart';
import '../../domain/enums/library_layout_mode.dart';
import '../../domain/enums/library_state.dart';

const _themeModeKey = 'themeModeKey';
const _getNavDestLabelBehaviorKey = 'getNavDestLabelBehaviorKey';
const _dynamicColorsKey = 'dynamicColorsKey';
const _oledModeKey = 'oledModeKey';
const _libraryStartFragmentKey = 'libraryStartFragmentKey';
const _playerDiscordRpcKey = 'playerDiscordRpcKey';
const _libraryLayoutModeKey = 'libraryLayoutModeKey';
const _animeSource = 'animeSourceKey';
const _playerSpeedKey = 'playerSpeedKey';
const _playerLongPressSeek = 'playerLongPressSeekKey';

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

  NavigationDestinationLabelBehavior getNavDestLabelBehavior() {
    final value = _preferences.getString(_getNavDestLabelBehaviorKey);
    if (value == null) {
      return NavigationDestinationLabelBehavior.alwaysShow;
    }
    return NavigationDestinationLabelBehavior.values
            .firstWhereOrNull((theme) => theme.name == value) ??
        NavigationDestinationLabelBehavior.alwaysShow;
  }

  Future<void> setNavDestLabelBehavior(
      NavigationDestinationLabelBehavior mode) async {
    await _preferences.setString(_getNavDestLabelBehaviorKey, mode.name);
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

  AnimeSource getAnimeSource() {
    final value = _preferences.getString(_animeSource);
    if (value == null) {
      return AnimeSource.alwaysAsk;
    }
    return AnimeSource.values
            .firstWhereOrNull((source) => source.name == value) ??
        AnimeSource.alwaysAsk;
  }

  Future<void> setAnimeSource(AnimeSource layout) async {
    await _preferences.setString(_animeSource, layout.name);
  }

  double getPlayerSpeed() {
    final value = _preferences.getDouble(_playerSpeedKey);

    if (value == null) {
      return 1.0;
    }

    return value.clamp(0.25, 2.0);
  }

  Future<void> setPlayerSpeed(double speed) async {
    await _preferences.setDouble(_playerSpeedKey, speed);
  }

  bool getPlayerLongPressSeek() {
    final value = _preferences.getBool(_playerLongPressSeek);

    if (value == null) {
      return false;
    }

    return value;
  }

  Future<void> setPlayerLongPressSeek(bool v) async {
    await _preferences.setBool(_playerLongPressSeek, v);
  }
}
