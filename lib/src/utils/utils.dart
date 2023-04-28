import 'package:flutter/material.dart';

Uri getUrl(Uri baseUrl, String path, [Map<String, String>? params]) {
  return Uri(
    scheme: baseUrl.scheme,
    host: baseUrl.host,
    port: baseUrl.port,
    path: baseUrl.path + path,
    queryParameters: params,
  );
}

void showSnackBar({
  required BuildContext ctx,
  required String msg,
  Duration? dur,
}) {
  var colors = Theme.of(ctx).colorScheme;
  var sm = ScaffoldMessenger.of(ctx);
  SnackBar snackBar = SnackBar(
    content: Text(
      msg,
      style: TextStyle(
        color: colors.onSurfaceVariant,
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: colors.surfaceVariant,
    dismissDirection: DismissDirection.horizontal,
    duration: dur ?? const Duration(seconds: 1),
  );
  sm.clearSnackBars();
  sm.showSnackBar(snackBar);
}

void showErrorSnackBar({
  required BuildContext ctx,
  required String msg,
  Duration? dur,
}) {
  var colors = Theme.of(ctx).colorScheme;
  var sm = ScaffoldMessenger.of(ctx);
  SnackBar snackBar = SnackBar(
    content: Text(
      msg,
      style: TextStyle(
        color: colors.onBackground,
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: colors.errorContainer,
    dismissDirection: DismissDirection.horizontal,
    duration: dur ?? const Duration(seconds: 3),
  );
  sm.clearSnackBars();
  sm.showSnackBar(snackBar);
}
