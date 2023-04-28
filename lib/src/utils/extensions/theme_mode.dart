import 'package:flutter/material.dart';

extension ThemeModeName on ThemeMode {
  String get themeName {
    switch (this) {
      case ThemeMode.system:
        return 'Как в системе';
      case ThemeMode.light:
        return 'Светлая';
      case ThemeMode.dark:
        return 'Тёмная';
    }
  }
}
