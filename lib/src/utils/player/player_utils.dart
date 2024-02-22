import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../app_utils.dart';

import 'font_base64.dart';

class PlayerUtils {
  PlayerUtils._();

  static final PlayerUtils _instance = PlayerUtils._();

  static PlayerUtils get instance => _instance;

  late String appDocumentsPath;
  late String fontsDirPath;

  static Future<void> init(String appDocumentsPath) async {
    _instance.appDocumentsPath = appDocumentsPath;

    await _instance._prepareFont();
  }

  Future<void> _prepareFont() async {
    final fontFilePath = path.join(appDocumentsPath, 'fonts', 'font.ttf');

    _instance.fontsDirPath = path.join(appDocumentsPath, 'fonts');

    if (AppUtils.instance.isDesktop) {
      return;
    }

    if (File(fontFilePath).existsSync()) {
      return;
    }

    final fontBytes = base64.decode(fontBase64);

    final fontFile = await File(
      fontFilePath,
    ).create(recursive: true);

    await fontFile.writeAsBytes(fontBytes);
  }
}
