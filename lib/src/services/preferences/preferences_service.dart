import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';

import '../../domain/enums/color_scheme_variant.dart';
import '../../domain/enums/explore_ongoing_now.dart';
import '../../domain/enums/library_layout_mode.dart';
import '../../domain/enums/library_state.dart';
import '../../domain/enums/anime_source.dart';

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
const _playerOrientationLock = 'playerOrientationLockKey';
const _colorSchemeVariantKey = 'colorSchemeVariant';
const _playerObserveAudioSession = 'playerObserveAudioSession';
const _shikiAllowExpContent = 'shikiAllowExpContent';
const _playerAndroidNewAudioBackend = 'playerAndroidNewAudioBackend';
const _explorePageLayout = 'explorePageLayout';
const _explorePageSort = 'explorePageSort';

// appLaunchCount
const _appLaunchCountKey = 'app_launch_count_key';

final preferencesProvider = Provider<PreferencesService>((ref) {
  throw Exception('preferencesProvider not initialized');
}, name: 'preferencesProvider');

class PreferencesService {
  final SharedPreferences _preferences;

  PreferencesService(this._preferences);

  static Future<PreferencesService> initialize() async {
    final sp = await SharedPreferences.getInstance();

    // try {
    //   final value = sp.getInt(_appLaunchCountKey);
    //   await sp.setInt(_appLaunchCountKey, (value ?? 0) + 1);
    // } catch (e) {
    //   // ignore
    // }

    return PreferencesService(sp);
    //return PreferencesService(await SharedPreferences.getInstance());
  }

  SharedPreferences get sharedPreferences => _preferences;

  Future<void> resetAppLaunchCount() async {
    await _preferences.setInt(_appLaunchCountKey, 1);
  }

  int getAppLaunchCount() {
    final value = _preferences.getInt(_appLaunchCountKey);

    if (value == null) {
      return 0;
    }

    return value;
  }

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
      return true;
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

  bool getPlayerOrientationLock() {
    final value = _preferences.getBool(_playerOrientationLock);

    return value ?? false;
  }

  Future<void> setPlayerOrientationLock(bool v) async {
    await _preferences.setBool(_playerOrientationLock, v);
  }

  // ----------------------

  ColorSchemeVariant getSchemeVariant() {
    final value = _preferences.getString(_colorSchemeVariantKey);
    if (value == null) {
      return ColorSchemeVariant.system;
    }
    return ColorSchemeVariant.values
            .firstWhereOrNull((variant) => variant.name == value) ??
        ColorSchemeVariant.system;
  }

  Future<void> setSchemeVariant(ColorSchemeVariant variant) async {
    await _preferences.setString(_colorSchemeVariantKey, variant.name);
  }

  bool getPlayerObserveAudioSession() {
    final value = _preferences.getBool(_playerObserveAudioSession);

    return value ?? true;
  }

  Future<void> setPlayerObserveAudioSession(bool v) async {
    await _preferences.setBool(_playerObserveAudioSession, v);
  }

  bool getShikiAllowExpContent() {
    final value = _preferences.getBool(_shikiAllowExpContent);

    return value ?? false;
  }

  Future<void> setShikiAllowExpContent(bool v) async {
    await _preferences.setBool(_shikiAllowExpContent, v);
  }

  bool getPlayerAndroidNewAudioBackend() {
    final value = _preferences.getBool(_playerAndroidNewAudioBackend);

    return value ?? false;
  }

  Future<void> setPlayerAndroidNewAudioBackend(bool v) async {
    await _preferences.setBool(_playerAndroidNewAudioBackend, v);
  }

  ExplorePageLayout getExplorePageLayout() {
    final value = _preferences.getString(_explorePageLayout);
    if (value == null) {
      return ExplorePageLayout.auto;
    }
    return ExplorePageLayout.values.firstWhereOrNull((v) => v.name == value) ??
        ExplorePageLayout.auto;
  }

  Future<void> setExplorePageLayout(ExplorePageLayout v) async {
    await _preferences.setString(_explorePageLayout, v.name);
  }

  ExplorePageSort getExplorePageSort() {
    final value = _preferences.getString(_explorePageSort);
    if (value == null) {
      return ExplorePageSort.airedOn;
    }
    return ExplorePageSort.values.firstWhereOrNull((v) => v.name == value) ??
        ExplorePageSort.airedOn;
  }

  Future<void> setExplorePageSort(ExplorePageSort v) async {
    await _preferences.setString(_explorePageSort, v.name);
  }
}
