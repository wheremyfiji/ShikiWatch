import 'dart:io';

import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart' as path_prov;
import 'package:path/path.dart' as p;

import '../../../../utils/target_platform.dart';
import '../../../../utils/utils.dart';
import '../../../widgets/cached_image.dart';
import 'setting_option.dart';

final cacheSizeProvider = FutureProvider.autoDispose<double>((ref) async {
  final dir = await path_prov.getTemporaryDirectory();

  final path = p.join(dir.path, 'imageCache');

  debugPrint(path);

  final directory = Directory(path);

  final exists = await directory.exists();

  if (!exists) {
    debugPrint('!exists');
    return 0;
  }

  int totalSize = 0;

  final entityList = await directory.list(recursive: false).toList();

  await Future.forEach(entityList, (entity) async {
    if (entity is File) {
      final fileBytes = await File(entity.path).readAsBytes();
      totalSize += fileBytes.lengthInBytes;
    }
  });

  // await Directory(path)
  //     .list(recursive: true, followLinks: false)
  //     .forEach((FileSystemEntity entity) async {
  //   if (entity is File) {
  //     final length = await entity.length();
  //     totalSize += length;
  //   }
  // });

  return totalSize / (1024 * 1024);
}, name: 'cacheSizeProvider');

class ClearCacheWidget extends ConsumerWidget {
  const ClearCacheWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(cacheSizeProvider);

    clearCache() async {
      showSnackBar(
        ctx: context,
        msg: 'Очистка..',
        dur: const Duration(milliseconds: 800),
      );

      await clearImageCache();

      //final dir = await path_prov.getTemporaryDirectory();
      //final path = p.join(dir.path, 'imageCache');
      //await Directory(path).delete(recursive: true);

      if (!TargetP.instance.isDesktop) {
        ref.invalidate(cacheSizeProvider);
      }

      if (context.mounted) {
        showSnackBar(
          ctx: context,
          msg: 'Кэш успешно очищен',
          dur: const Duration(milliseconds: 1200),
        );
      }
    }

    return provider.when(
      data: (data) => SettingsOption(
        title: 'Очистить кэш изображений',
        subtitle: 'Размер кэша: ${data.toStringAsFixed(2)} MB',
        onTap: () => clearCache(),
      ),
      error: (error, stackTrace) => SettingsOption(
        title: 'Очистить кэш изображений',
        subtitle: 'Ошибка вычисления размера кеша',
        onTap: () => clearCache(),
      ),
      loading: () => const SettingsOption(
        title: 'Очистить кэш изображений',
        subtitle: '...',
      ),
    );

    // return SettingsOption(
    //   title: 'Очистить кэш изображений', //Очистить кэш
    //   // subtitle:
    //   //     'Удалить кэшированные изображения', //Удалить кэш API и изображений
    //   subtitle: '',
    //   onTap: () async {
    //     showSnackBar(
    //       ctx: context,
    //       msg: 'Очистка..',
    //       dur: const Duration(milliseconds: 800),
    //     );
    //     // await extended_image.clearDiskCachedImages();
    //     // extended_image.clearMemoryImageCache();

    //     await clearImageCache();

    //     ref.invalidate(cacheSizeProvider);

    //     if (context.mounted) {
    //       showSnackBar(
    //         ctx: context,
    //         msg: 'Кэш успешно очищен',
    //         dur: const Duration(milliseconds: 1200),
    //       );
    //     }
    //   },
    // );
  }
}

// class CacheSize extends ConsumerWidget {
//   const CacheSize({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final provider = ref.watch(cacheSizeProvider);

//     return provider.when(
//       data: (data) => SettingsOption(
//         title: 'Размер кэша изображений',
//         subtitle: '${data.toStringAsFixed(2)} MB',
//       ),
//       error: (error, stackTrace) => SettingsOption(
//         title: 'Ошибка вычисления размера кэша',
//         subtitle: error.toString(),
//       ),
//       loading: () => const SettingsOption(
//         title: 'Размер кэша изображений',
//         subtitle: '...',
//       ),
//     );
//   }
// }
