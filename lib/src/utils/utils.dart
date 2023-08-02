import 'package:flutter/material.dart';

import 'extensions/buildcontext.dart';

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
  var sm = ScaffoldMessenger.of(ctx);
  SnackBar snackBar = SnackBar(
    content: Text(
      msg,
      style: TextStyle(
        color: ctx.colorScheme.onSurfaceVariant,
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: ctx.colorScheme.surfaceVariant,
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
  var sm = ScaffoldMessenger.of(ctx);
  SnackBar snackBar = SnackBar(
    content: Text(
      msg,
      style: TextStyle(
        color: ctx.colorScheme.onErrorContainer,
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: ctx.colorScheme.errorContainer,
    dismissDirection: DismissDirection.horizontal,
    duration: dur ?? const Duration(seconds: 3),
  );
  sm.clearSnackBars();
  sm.showSnackBar(snackBar);
}
