import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_utils.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../utils/player/player_utils.dart';
import '../player/player_provider.dart';

final _dateFormat = DateFormat.Hms();

class PlayerDebugPage extends StatefulWidget {
  const PlayerDebugPage({super.key});

  @override
  State<PlayerDebugPage> createState() => _PlayerDebugPageState();
}

class _PlayerDebugPageState extends State<PlayerDebugPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final logs = PlayerLogger().logs.reversed.toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // pizdec
          setState(() {});
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text('Player Debug Page (${logs.length})'),
              actions: [
                IconButton(
                  onPressed: () async {
                    if (AppUtils.instance.isDesktop) {
                      final ts =
                          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

                      final file = File(join(
                          PlayerUtils.instance.appDocumentsPath,
                          'player-logs-$ts.log'));

                      await file
                          .writeAsString(PlayerLogger().logs.join('\n'))
                          .then((value) async {
                        await launchUrl(
                            Uri.parse(PlayerUtils.instance.appDocumentsPath));
                        //return true;
                      });
                    } else {
                      await Share.shareXFiles([
                        XFile.fromData(
                          utf8.encode(PlayerLogger().logs.join('\n')),
                          name: 'player-logs.log',
                          mimeType: 'text/plain',
                        )
                      ]);
                    }
                  },
                  icon: const Icon(Icons.share),
                ),
                IconButton(
                  onPressed: () => PlayerLogger().clear(),
                  icon: const Icon(Icons.clear_all),
                ),
              ],
            ),
            SliverList.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SelectableText(
                    //'[${_dateFormat.format(log.timestamp)}] ${log.log}',
                    log.toString(),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: log.level == 'error'
                          ? context.colorScheme.error
                          : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
