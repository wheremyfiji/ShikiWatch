import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AsyncValueSliverWidget<T> extends StatelessWidget {
  const AsyncValueSliverWidget({
    Key? key,
    required this.value,
    required this.data,
  }) : super(key: key);

  // input async value
  final AsyncValue<T> value;
  // output builder function
  final Widget Function(T) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) {
        return SliverToBoxAdapter(
          child: Center(
            child: Text(
              error.toString(),
            ),
          ),
        );
      },
    );
  }
}
