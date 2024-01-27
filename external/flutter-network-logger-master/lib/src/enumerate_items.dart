import 'package:flutter/widgets.dart';

typedef IndexBuilder = Widget Function(BuildContext context, int index);
typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);

IndexBuilder enumerateItems<T>(List<T> items, ItemBuilder<T> builder) {
  return (BuildContext context, int index) => builder(context, items[index]);
}
