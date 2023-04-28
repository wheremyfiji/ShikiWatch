import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shikidev/src/utils/extensions/theme_mode.dart';

import '../../../../constants/box_types.dart';
import '../../../../constants/hive_keys.dart';

class CurrentThemeWidget extends StatefulWidget {
  final ThemeMode currentTheme;

  const CurrentThemeWidget({super.key, required this.currentTheme});

  @override
  State<CurrentThemeWidget> createState() => _CurrentThemeWidgetState();
}

class _CurrentThemeWidgetState extends State<CurrentThemeWidget> {
  late ThemeMode selectedTheme = widget.currentTheme;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ListTile(
            title: Text(
              'Выбор темы приложения',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...ThemeMode.values
              .map(
                (e) => RadioListTile(
                  value: e,
                  activeColor: Theme.of(context).colorScheme.primary,
                  groupValue: selectedTheme,
                  onChanged: (value) {
                    selectedTheme = value!;

                    setState(() {});

                    Hive.box(BoxType.settings.name).put(
                      themeModeKey,
                      value.index,
                    );

                    Navigator.pop(context);
                  },
                  title: Text(
                    e.themeName,
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
