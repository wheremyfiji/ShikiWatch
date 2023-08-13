import 'package:flutter/material.dart';

extension NavDestLabelBehaviorExt on NavigationDestinationLabelBehavior {
  String get labelBehName {
    // подписи в баре навигации
    switch (this) {
      case NavigationDestinationLabelBehavior.alwaysShow:
        return 'Всегда видны'; // показывать
      case NavigationDestinationLabelBehavior.alwaysHide:
        return 'Скрыты';
      case NavigationDestinationLabelBehavior.onlyShowSelected:
        return 'Показывать, если выбрано';
    }
  }
}
