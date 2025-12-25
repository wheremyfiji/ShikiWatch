import 'dart:io';

import 'package:flutter/material.dart';
import 'extensions/buildcontext.dart';

class AppUtils {
  AppUtils._();

  static final AppUtils _instance = AppUtils._();

  static AppUtils get instance => _instance;

  late bool isDesktop;
  late String userAgent;
  late String appCachePath;

  static init(Directory appCacheDir) {
    _instance.appCachePath = appCacheDir.path;

    _instance.isDesktop =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    _instance.userAgent =
        _instance.isDesktop ? 'Shikimori Flutter Windows App' : 'ShikiWatch';
  }
}

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

Future<bool> openUrlLinux(String url) async {
  if (!Platform.isLinux) {
    throw UnsupportedError('This method is only supported on Linux.');
  }

  try {
    ProcessResult result = await Process.run('xdg-open', [url]);

    if (result.exitCode != 0) {
      result = await Process.run('/usr/bin/xdg-open', [url]);
    }

    if (result.exitCode != 0) {
      return false;
      // throw Exception('Could not launch URL: ${result.stderr}');
    }

    return true;
  } catch (e) {
    debugPrint('Error launching URL: $e');
    return false;
  }
}
