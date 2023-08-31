import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final GestureTapCallback onTap;
  final Widget? leading;
  final Iterable<Widget>? trailing;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final MaterialStatesController _internalStatesController;

  @override
  void initState() {
    super.initState();
    _internalStatesController = MaterialStatesController();
    _internalStatesController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _internalStatesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final IconThemeData iconTheme = IconTheme.of(context);
    final SearchBarThemeData searchBarTheme = SearchBarTheme.of(context);
    final SearchBarThemeData defaults = _SearchBarDefaultsM3(context);

    T? resolve<T>(
      MaterialStateProperty<T>? themeValue,
      MaterialStateProperty<T>? defaultValue,
    ) {
      final Set<MaterialState> states = _internalStatesController.value;
      return themeValue?.resolve(states) ?? defaultValue?.resolve(states);
    }

    final TextStyle? effectiveTextStyle =
        resolve<TextStyle?>(searchBarTheme.textStyle, defaults.textStyle);
    final double? effectiveElevation =
        resolve<double?>(searchBarTheme.elevation, defaults.elevation);
    final Color? effectiveBackgroundColor = resolve<Color?>(
        searchBarTheme.backgroundColor, defaults.backgroundColor);
    final Color? effectiveSurfaceTintColor = resolve<Color?>(
        searchBarTheme.surfaceTintColor, defaults.surfaceTintColor);
    final OutlinedBorder? effectiveShape =
        resolve<OutlinedBorder?>(searchBarTheme.shape, defaults.shape);
    final BorderSide? effectiveSide =
        resolve<BorderSide?>(searchBarTheme.side, defaults.side);
    final MaterialStateProperty<Color?>? effectiveOverlayColor =
        searchBarTheme.overlayColor ?? defaults.overlayColor;

    final Set<MaterialState> states = _internalStatesController.value;
    final TextStyle? effectiveHintStyle =
        searchBarTheme.hintStyle?.resolve(states) ??
            searchBarTheme.textStyle?.resolve(states) ??
            defaults.hintStyle?.resolve(states);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isIconThemeColorDefault(Color? color) {
      if (isDark) {
        return color == kDefaultIconLightColor;
      }
      return color == kDefaultIconDarkColor;
    }

    Widget? leading;
    if (widget.leading != null) {
      leading = IconTheme.merge(
        data: isIconThemeColorDefault(iconTheme.color)
            ? IconThemeData(color: colorScheme.onSurface)
            : iconTheme,
        child: widget.leading!,
      );
    }

    List<Widget>? trailing;
    if (widget.trailing != null) {
      trailing = widget.trailing
          ?.map((Widget trailing) => IconTheme.merge(
                data: isIconThemeColorDefault(iconTheme.color)
                    ? IconThemeData(color: colorScheme.onSurfaceVariant)
                    : iconTheme,
                child: trailing,
              ))
          .toList();
    }

    //  ConstrainedBox
    //  constraints: searchBarTheme.constraints ?? defaults.constraints!,

    return Material(
      elevation: effectiveElevation!,
      shadowColor: Colors.transparent,
      color: effectiveBackgroundColor,
      surfaceTintColor: effectiveSurfaceTintColor,
      shape: effectiveShape?.copyWith(side: effectiveSide),
      child: InkWell(
        onTap: () {
          widget.onTap.call();
        },
        overlayColor: effectiveOverlayColor,
        customBorder: effectiveShape?.copyWith(side: effectiveSide),
        statesController: _internalStatesController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              if (leading != null) leading,
              Expanded(
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      style: effectiveTextStyle,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.hintText,
                        hintStyle: effectiveHintStyle,
                      ),
                    ),
                  ),
                ),
              ),
              if (trailing != null) ...trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBarDefaultsM3 extends SearchBarThemeData {
  _SearchBarDefaultsM3(this.context);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  MaterialStateProperty<Color?>? get backgroundColor =>
      MaterialStatePropertyAll<Color>(_colors.surface);

  @override
  MaterialStateProperty<double>? get elevation =>
      const MaterialStatePropertyAll<double>(6.0);

  @override
  MaterialStateProperty<Color>? get shadowColor =>
      MaterialStatePropertyAll<Color>(_colors.shadow);

  @override
  MaterialStateProperty<Color>? get surfaceTintColor =>
      MaterialStatePropertyAll<Color>(_colors.surfaceTint);

  @override
  MaterialStateProperty<Color?>? get overlayColor =>
      MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return _colors.onSurface.withOpacity(0.12);
        }
        if (states.contains(MaterialState.hovered)) {
          return _colors.onSurface.withOpacity(0.08);
        }
        if (states.contains(MaterialState.focused)) {
          return Colors.transparent;
        }
        return Colors.transparent;
      });

  // No default side

  @override
  MaterialStateProperty<OutlinedBorder>? get shape =>
      const MaterialStatePropertyAll<OutlinedBorder>(StadiumBorder());

  @override
  MaterialStateProperty<EdgeInsetsGeometry>? get padding =>
      const MaterialStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 8.0));

  @override
  MaterialStateProperty<TextStyle?> get textStyle =>
      MaterialStatePropertyAll<TextStyle?>(
          _textTheme.bodyLarge?.copyWith(color: _colors.onSurface));

  @override
  MaterialStateProperty<TextStyle?> get hintStyle =>
      MaterialStatePropertyAll<TextStyle?>(
          _textTheme.bodyLarge?.copyWith(color: _colors.onSurfaceVariant));

  @override
  BoxConstraints get constraints =>
      const BoxConstraints(minWidth: 360.0, maxWidth: 800.0, minHeight: 56.0);
}
