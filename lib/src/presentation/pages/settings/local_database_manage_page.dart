// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../services/anime_database/anime_database_provider.dart';
import '../../providers/environment_provider.dart';
import '../../../utils/target_platform.dart';
import '../../../utils/utils.dart';

class LocalDatabaseManage extends StatelessWidget {
  const LocalDatabaseManage({super.key});

  @override
  Widget build(BuildContext context) {
    if (TargetP.instance.isDesktop) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('W.I.P'),
        ),
      );
    }

    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text('Резервное копирование'),
          ),
          SliverToBoxAdapter(
            child: ExportDB(),
          ),
          SliverToBoxAdapter(
            child: ImportDB(),
          ),
          SliverToBoxAdapter(
            child: ClearDB(),
          ),
        ],
      ),
    );
  }
}

class ImportDB extends ConsumerStatefulWidget {
  const ImportDB({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImportDBState();
}

class _ImportDBState extends ConsumerState<ImportDB> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      //leading: const Icon(Icons.input_rounded),
      title: const Text('Восстановить'),
      subtitle: Text(
        'Импортировать из json-файла',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      onTap: () async {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: const Dialog(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            );
          },
        );

        final sdkVer = ref.read(environmentProvider).sdkVersion;

        if (sdkVer == null) {
          Navigator.of(context).pop();
          return;
        }

        await Permission.storage.request();

        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: sdkVer < 29 ? FileType.any : FileType.custom,
          allowedExtensions: sdkVer < 29 ? null : ['json'],
        );

        if (result == null || result.files.isEmpty) {
          Navigator.of(context).pop();
          return;
        }

        if (result.files.first.path == null) {
          Navigator.of(context).pop();
          return;
        }

        final t = await ref.read(animeDatabaseProvider).importJson(
              result.files.first.path!,
              clearDb: true,
            );

        if (!mounted) {
          return;
        }

        Navigator.of(context).pop();

        if (t) {
          showSnackBar(
            ctx: context,
            msg: 'Импортировано успешно',
            dur: const Duration(seconds: 3),
          );
        } else {
          showErrorSnackBar(
            ctx: context,
            msg: 'Ошибка',
            dur: const Duration(seconds: 5),
          );
        }
      },
    );
  }
}

class ExportDB extends ConsumerStatefulWidget {
  const ExportDB({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExportDBState();
}

class _ExportDBState extends ConsumerState<ExportDB> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      //leading: const Icon(Icons.backup),
      title: const Text('Создать'),
      subtitle: Text(
        'Экспортировать в json-файл',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      onTap: () async {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: const Dialog(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            );
          },
        );

        final sdkVer = ref.read(environmentProvider).sdkVersion;

        if (sdkVer == null) {
          Navigator.of(context).pop();
          return;
        }

        await Permission.storage.request();

        final path = await FilePicker.platform.getDirectoryPath();
        if (path == null) {
          Navigator.of(context).pop();
          return;
        }

        final t = await ref.read(animeDatabaseProvider).exportJson(path);

        if (!mounted) {
          return;
        }

        Navigator.of(context).pop();

        if (t) {
          showSnackBar(
            ctx: context,
            msg: 'Экспортировано успешно',
            dur: const Duration(seconds: 3),
          );
        } else {
          showErrorSnackBar(
            ctx: context,
            msg: 'Ошибка',
            dur: const Duration(seconds: 5),
          );
        }
      },
    );
  }
}

class ClearDB extends ConsumerWidget {
  const ClearDB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      //leading: const Icon(Icons.delete_rounded),
      title: const Text('Удалить'),
      subtitle: Text(
        'Удалить все локальные отметки просмотра',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Вы уверены?'),
            content: const Text(
              'Внимание! Это удалит все локальные отметки просмотра',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Отмена"),
              ),
              FilledButton(
                onPressed: () async {
                  await ref.read(animeDatabaseProvider).clearDatabase();
                  if (context.mounted) {
                    showSnackBar(
                      ctx: context,
                      msg: 'Локальные отметки удалены',
                      dur: const Duration(milliseconds: 1500),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Удалить"),
              ),
            ],
          ),
        );
      },
    );
  }
}
