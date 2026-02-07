extension DurationExt on Duration {
  String printDuration() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(inMinutes.abs().remainder(60));
    final twoDigitSeconds = twoDigits(inSeconds.abs().remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  Duration clampToRange(Duration maxDuration) {
    if (this < Duration.zero) {
      return Duration.zero;
    } else if (this > maxDuration) {
      return maxDuration;
    }
    return this;
  }
}

extension DurationFormatting on Duration {
  String get toHumanReadable {
    if (isNegative) return 'сейчас';

    final days = inDays;
    final hours = inHours % 24;
    final minutes = inMinutes % 60;
    final seconds = inSeconds % 60;

    if (days > 0) {
      return '$days дн. $hours ч. $minutes мин.';
    } else if (hours > 0) {
      return '$hours ч. $minutes мин. $seconds сек.';
    } else {
      return '$minutes мин. $seconds сек.';
    }
  }

  String get toDigitalFormat {
    if (isNegative) return '00:00:00';

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final days = inDays;
    final hours = twoDigits(inHours.remainder(24));
    final minutes = twoDigits(inMinutes.remainder(60));
    final seconds = twoDigits(inSeconds.remainder(60));

    if (days > 0) {
      return '$days дн. $hours:$minutes:$seconds';
    } else {
      return '$hours:$minutes:$seconds';
    }
  }
}
