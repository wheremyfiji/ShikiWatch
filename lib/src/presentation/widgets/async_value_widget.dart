import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'error_widget.dart';

// https://codewithandrea.com/articles/async-value-widget-riverpod/

// Generic AsyncValueWidget to work with values of type T
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    Key? key,
    required this.value,
    required this.data,
    this.retry,
  }) : super(key: key);

  // input async value
  final AsyncValue<T> value;
  // output builder function
  final Widget Function(T) data;
  final Function()? retry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return CustomErrorWidget(error.toString(), retry);
      },
    );
  }
}
