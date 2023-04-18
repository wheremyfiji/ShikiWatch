import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:version/version.dart';

class Update {
  final String? version;
  final bool? critical;
  final String? description;
  final String? url;

  Update({
    required this.version,
    required this.critical,
    required this.description,
    required this.url,
  });

  Update.fromJson(Map<String, dynamic> json)
      : version = json['version'],
        critical = json['critical'],
        description = json['description'],
        url = json['url'];
}

class UpdaterWidget extends StatefulWidget {
  final Widget child;
  const UpdaterWidget({super.key, required this.child});

  @override
  State<UpdaterWidget> createState() => _UpdaterWidgetState();
}

class _UpdaterWidgetState extends State<UpdaterWidget> {
  bool d = false;

  checkLatestVersion() async {
    //await Future.delayed(const Duration(seconds: 5));

    if (d) {
      return;
    }

    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/wheremyfiji/ShikiDev/updater/updater.json'));

    if (response.statusCode != 200) {
      return;
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));

    final result = [for (final e in json) Update.fromJson(e)];

    final latest = result[0];

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    Version currentVersion = Version.parse(packageInfo.version);
    Version latestVersion = Version.parse(latest.version!);

    final crit = latest.critical!;

    if (crit && !d) {
      _showCriticalDialog(
        content: latest.description!,
      );

      return;
    }

    if (latestVersion > currentVersion && !d) {
      _showNormalDialog(
        content: latest.description!,
      );
    }
  }

  _showNormalDialog({required String content}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Доступна новая версия'),
          content: Text(content),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Позже'),
            ),
            ElevatedButton(
              onPressed: () {
                launchUrlString(
                  'https://github.com/wheremyfiji/ShikiDev/releases/latest',
                  mode: LaunchMode.externalApplication,
                );
              },
              child: const Text('Обновить'),
            ),
          ],
        );
      },
    );
  }

  _showCriticalDialog({required String content}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Критическое обновление'),
          content: Text(content),
          actions: [
            ElevatedButton(
              onPressed: () {
                launchUrlString(
                  'https://github.com/wheremyfiji/ShikiDev/releases/latest',
                  mode: LaunchMode.externalApplication,
                );
              },
              child: const Text('Обновить'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLatestVersion();
    });
  }

  @override
  void dispose() {
    d = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
