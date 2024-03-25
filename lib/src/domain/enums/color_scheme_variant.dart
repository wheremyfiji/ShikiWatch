enum ColorSchemeVariant {
  system,
  vibrant,
  expressive,
  rainbow,
  fruitSalad,
  neutral,
  monochrome;

  String get label {
    return switch (this) {
      ColorSchemeVariant.system => 'Как в системе',
      ColorSchemeVariant.vibrant => 'Яркая',
      ColorSchemeVariant.expressive => 'Выразительная',
      ColorSchemeVariant.rainbow => 'Разноцветная',
      ColorSchemeVariant.fruitSalad => 'Фруктовый салат',
      ColorSchemeVariant.neutral => 'Нейтральная',
      ColorSchemeVariant.monochrome => 'Монохромная',
    };
  }
}
