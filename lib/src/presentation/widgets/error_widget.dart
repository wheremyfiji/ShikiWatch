import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget(this.errorString, this.buttonOnPressed, {Key? key})
      : super(key: key);
  final String errorString;
  final Function()? buttonOnPressed;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ой, ошибка..',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(errorString),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
              onPressed: buttonOnPressed,
              label: const Text(
                'Повторить попытку',
              ),
              icon: const Icon(Icons.refresh_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
