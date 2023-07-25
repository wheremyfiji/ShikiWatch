import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension DateTimeExt on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  String convertToDaysAgo() {
    final now = DateTime.now();

    if (year != now.year) {
      return DateFormat.yMMMd().format(this);
    }

    Duration diff = now.difference(this);
    final time = DateFormat('HH:mm').format(this);

    if (diff.inDays < 1) {
      return timeago.format(this, locale: 'ru');
    } else {
      return '${DateFormat.MMMd().format(this)}, $time';
    }
  }
}
