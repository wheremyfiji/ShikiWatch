class Toggles {
  static bool get showCalendarButton =>
      const bool.fromEnvironment('TOGGLE_CALENDAR', defaultValue: false);
}
