import 'dart:io';

import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../services/anime_database/anime_database_provider.dart';
import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../../providers/environment_provider.dart';
import '../../../../../build_date_time.dart';
import 'setting_option.dart';

final dbSizeProvider = FutureProvider.autoDispose<double>((ref) async {
  final dbSize = await ref.read(animeDatabaseProvider).getDatabaseSize();
  return dbSize;
}, name: 'dbSizeProvider');

class VersionWidget extends ConsumerWidget {
  const VersionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentProvider);

    final version = environment.packageInfo.version;
    final build = environment.packageInfo.buildNumber;
    //final appname = environment.packageInfo.packageName;

    DateTime appBuildTime = DateTime.parse(appBuildDateTime);
    final dateString = DateFormat.yMMMMd().format(appBuildTime);
    final timeString = DateFormat.Hm().format(appBuildTime);

    return Pashalka(
      callback: () async {
        showModalBottomSheet<void>(
          showDragHandle: true,
          useRootNavigator: true,
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width >= 700
                ? 700
                : double.infinity,
          ),
          builder: (context) {
            return const DebugInfo();
          },
        );
      },
      child: SettingsOption(
        title: 'Версия: $version ($build)',
        //subtitle: appname,
        subtitle: 'от $dateString ($timeString)',
        onTap: null,
      ),
    );
  }
}

class DebugInfo extends ConsumerWidget {
  const DebugInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentProvider);
    final db = ref.watch(dbSizeProvider);

    final buildSignature = environment.packageInfo.buildSignature.isEmpty
        ? ''
        : environment.packageInfo.buildSignature
            .substring(environment.packageInfo.buildSignature.length - 6);

    return db.when(
      data: (data) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Debug info',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text('appBuildDateTime: $appBuildDateTime'),
                // const SizedBox(
                //   height: 8,
                // ),
                // Text('dart: ${Platform.version}'),
                // const SizedBox(
                //   height: 4,
                // ),
                Text('operatingSystem: ${Platform.operatingSystemVersion}'),
                const SizedBox(
                  height: 8,
                ),
                Text('appName: ${environment.packageInfo.appName}'),
                Text('packageName: ${environment.packageInfo.packageName}'),
                Text('version: ${environment.packageInfo.version}'),
                Text('build: ${environment.packageInfo.buildNumber}'),
                Text(
                  'buildSignature: $buildSignature (${environment.packageInfo.buildSignature.length})',
                ),
                if (environment.packageInfo.installerStore != null)
                  Text(
                    'installerStore: ${environment.packageInfo.installerStore}',
                  ),
                const SizedBox(
                  height: 8,
                ),
                Text('userId: ${SecureStorageService.instance.userId}'),
                Text(
                  'userProfileImage: ${SecureStorageService.instance.userProfileImage}',
                ),
                const SizedBox(
                  height: 8,
                ),
                Text('anime db size: $data Kb'),
                // const SizedBox(
                //   height: 8,
                // ),
                // const FilledButton(
                //   onPressed: null,
                //   child: Text('copy'),
                // ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class Pashalka extends StatefulWidget {
  final Widget child;
  final VoidCallback callback;

  const Pashalka({
    super.key,
    required this.child,
    required this.callback,
  });

  @override
  State<Pashalka> createState() => _PashalkaState();
}

class _PashalkaState extends State<Pashalka> {
  int tapCounter = 0;
  int oldTimestamp = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child,
      onTap: () {
        tapCounter = 0;
        oldTimestamp = 0;
      },
      onDoubleTap: () => widget.callback(),
      // onDoubleTap: () {
      //   int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      //   if (tapCounter == 0) {
      //     oldTimestamp = 0;
      //   }
      //   if (oldTimestamp == 0 || currentTimestamp - oldTimestamp < 450) {
      //     tapCounter += 2;
      //     oldTimestamp = currentTimestamp;
      //     if (tapCounter == 6) {
      //       tapCounter = 0;
      //       oldTimestamp = 0;

      //       widget.callback();
      //     }
      //   } else {
      //     tapCounter = 0;
      //   }
      // },
    );
  }
}
