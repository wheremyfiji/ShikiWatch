import 'package:flutter/material.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/enums/anime_source.dart';
import '../../domain/enums/library_layout_mode.dart';
import '../../domain/enums/library_state.dart';

part 'settings_state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required ThemeMode theme,
    required NavigationDestinationLabelBehavior navDestLabelBehavior,
    required bool dynamicColors,
    required bool oledMode,
    required LibraryFragmentMode libraryFragment,
    required bool playerDiscordRpc,
    required LibraryLayoutMode libraryLayout,
    required AnimeSource animeSource,
    required double playerSpeed,
  }) = _SettingsState;
}
