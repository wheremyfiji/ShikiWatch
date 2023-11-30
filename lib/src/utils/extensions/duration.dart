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
