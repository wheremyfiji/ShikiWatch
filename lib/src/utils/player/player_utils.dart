import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../assets_helper.dart';
import '../app_utils.dart';

import 'player_shaders.dart';
import 'font_base64.dart';

class PlayerUtils {
  PlayerUtils._();

  static final PlayerUtils _instance = PlayerUtils._();

  static PlayerUtils get instance => _instance;

  late String appDocumentsPath;
  late String fontsDirPath;

  late String shadersDir;

  static Future<void> init(String appDocumentsPath) async {
    _instance.appDocumentsPath = appDocumentsPath;

    await _instance._prepareFont();
    await _instance._prepareShaders();

    _instance.shadersDir = '${path.join(appDocumentsPath, 'shaders')}/';
  }

  Future<void> _prepareShaders() async {
    for (final s in kPlayerShaders) {
      await AssetsHelper.copyAssetToAppDir(
        'assets/shaders/${s.filePath}',
        targetDir: 'shaders',
      );
    }
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
