import 'package:flutter/material.dart';

enum ExplorePageLayout {
  auto,
  grid,
  list;

  String get label {
    return switch (this) {
      ExplorePageLayout.auto => 'Авто',
      ExplorePageLayout.grid => 'Сетка',
      ExplorePageLayout.list => 'Список',
    };
  }

  IconData get icon {
    return switch (this) {
      ExplorePageLayout.auto => Icons.auto_awesome_rounded,
      ExplorePageLayout.grid => Icons.grid_view_rounded,
      ExplorePageLayout.list => Icons.view_list_rounded,
    };
  }
}

enum ExplorePageSort {
  ranked('ranked'),
  popularity('popularity'),
  airedOn('aired_on');

  final String value;

  const ExplorePageSort(this.value);

  String get label {
    return switch (this) {
      ExplorePageSort.ranked => 'Оценка',
      ExplorePageSort.popularity => 'Популярность',
      ExplorePageSort.airedOn => 'Дата начала показа',
    };
  }
}
