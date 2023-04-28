import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'error_widget.dart';

class AsyncValueSliverWidget<T> extends StatelessWidget {
  const AsyncValueSliverWidget({
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
      loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) {
        return SliverFillRemaining(
          child: CustomErrorWidget(error.toString(), retry),
        );
      },
    );
  }
}
