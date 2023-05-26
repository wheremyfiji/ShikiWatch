import 'dart:io';

import 'package:path/path.dart' as path;

void main(List<String> args) async {
  final fileDir = path.normalize(path.join(Directory.current.path, 'lib'));

  final file = File(path.join(fileDir, 'build_date_time.dart'));

  if (await file.exists()) {
    await file.delete();
  }

  final buildDateTime = DateTime.now();

  await file.writeAsString(
      "const String appBuildDateTime = '${buildDateTime.toString()}';");
}
