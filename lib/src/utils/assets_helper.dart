import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

abstract class AssetsHelper {
  static Future<bool> copyAssetToAppDir(
    String assetPath, {
    String? targetDir,
  }) async {
    try {
      final Directory appDir = await _appDir();

      final String fileName = path.basename(assetPath);
      final String localFilePath = path.join(appDir.path, targetDir, fileName);

      final File file = File(localFilePath);

      final dirname = path.dirname(localFilePath);
      bool exists = await Directory(dirname).exists();
      if (!exists) {
        await Directory(dirname).create(recursive: true);
      }

      if (await file.exists()) {
        // debugPrint('Файл $fileName уже существует по пути: ${file.path}');
        return true;
      }

      final data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await file.writeAsBytes(bytes, flush: true);

      // debugPrint('Файл $fileName успешно сохранен по пути: ${file.path}');
      return true;
    } catch (e) {
      debugPrint(
          'Произошла ошибка при копировании файла $assetPath из assets: $e');
      return false;
    }
  }

  static Future<Directory> _appDir() async {
    return await getApplicationSupportDirectory();
  }
}
