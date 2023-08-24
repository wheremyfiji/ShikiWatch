import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<File> createLogFile(bool static) async {
  final dir = await getApplicationSupportDirectory();
  final path = p.join(dir.path, 'logs');
  bool exists = await Directory(path).exists();

  if (!exists) {
    await Directory(path).create(recursive: true);
  }

  final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final fileName = static ? 'static_$ts.txt' : 'cache_$ts.txt';

  final file = File(p.join(path, fileName));
  return file;
}

void logToFile({required File file, required String value}) {
  return file.writeAsStringSync(
    '$value\n',
    mode: FileMode.writeOnlyAppend,
  );
}
