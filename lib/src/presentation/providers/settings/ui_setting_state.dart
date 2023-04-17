// import 'package:flutter/material.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'ui_setting_state.g.dart';

// @riverpod
// class UiSettingState extends _$UiSettingState {
//   @override
//   UiSetting build() {
//     final repo = ref.read(settingRepoProvider);
//     return UiSetting(
//       blur: repo.get(Setting.uiBlur, or: true),
//       grid: repo.get(Setting.uiTimelineGrid, or: 1),
//       locale: localeFromStr(repo.get(Setting.uiLanguage, or: '')),
//       themeMode: ThemeMode
//           .values[repo.get(Setting.uiThemeMode, or: ThemeMode.system.index)],
//       midnightMode: repo.get(Setting.uiMidnightMode, or: false),
//       imeIncognito: repo.get(Setting.imeIncognito, or: false),
//     );
//   }


//   Future<ThemeMode> setThemeMode(ThemeMode mode) async {
//     final repo = ref.read(settingRepoProvider);

//     state = state.copyWith(themeMode: mode);
//     await repo.put(Setting.uiThemeMode, mode.index);
//     return state.themeMode;
//   }

//   Future<ThemeMode> cycleThemeMode() async {
//     switch (state.themeMode) {
//       case ThemeMode.dark:
//         await setThemeMode(ThemeMode.light);
//         break;
//       case ThemeMode.light:
//         await setThemeMode(ThemeMode.system);
//         break;
//       default:
//         await setThemeMode(ThemeMode.dark);
//         break;
//     }
//     return state.themeMode;
//   }

//   Future<bool> setMidnightMode(bool value) async {
//     final repo = ref.read(settingRepoProvider);
//     state = state.copyWith(midnightMode: value);
//     await repo.put(Setting.uiMidnightMode, value);
//     return state.midnightMode;
//   }

//   Future<bool> setDynamicColors(bool value) async {
//     final repo = ref.read(settingRepoProvider);
//     state = state.copyWith(imeIncognito: value);
//     await repo.put(Setting.imeIncognito, value);
//     return state.imeIncognito;
//   }
// }
