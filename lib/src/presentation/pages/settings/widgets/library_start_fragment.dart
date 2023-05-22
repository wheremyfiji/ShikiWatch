import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../constants/box_types.dart';
import '../../../../constants/hive_keys.dart';
import '../../../../domain/enums/library_state.dart';

class LibraryStartFragment extends StatefulWidget {
  final LibraryState fragment;

  const LibraryStartFragment({super.key, required this.fragment});

  @override
  State<LibraryStartFragment> createState() => _LibraryStartFragmentState();
}

class _LibraryStartFragmentState extends State<LibraryStartFragment> {
  late LibraryState selectedFragment = widget.fragment;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ListTile(
            title: Text(
              'Выбор раздела библиотеки по умолчанию', //Выбор раздела при запуске приложения
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...LibraryState.values
              .map(
                (e) => RadioListTile(
                  value: e,
                  activeColor: Theme.of(context).colorScheme.primary,
                  groupValue: selectedFragment,
                  onChanged: (value) {
                    selectedFragment = value!;

                    setState(() {});

                    Hive.box(BoxType.settings.name).put(
                      libraryStartFragmentKey,
                      value.index,
                    );

                    Navigator.pop(context);
                  },
                  title: Text(
                    e.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
