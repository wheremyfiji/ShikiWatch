import 'dart:io';

import 'package:flutter/material.dart';
import 'package:git_info/git_info.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:extended_image/extended_image.dart' as extended_image;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../services/anime_database/anime_database_provider.dart';
import '../../../services/http/cache_storage/cache_storage_provider.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../constants/box_types.dart';
import '../../../constants/hive_keys.dart';
import '../../../utils/target_platform.dart';
import '../../providers/environment_provider.dart';
import 'widgets/setting_option.dart';
import 'widgets/settings_group.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    clearIsar() async {
      await ref.read(animeDatabaseProvider).clearDatabase();
      if (context.mounted) {
        context.scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Успешно!'),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    }

    export() async {
      bool t = await ref.read(animeDatabaseProvider).export(path: '');
      if (t && context.mounted) {
        context.scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Успешно!'),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    }

    return Scaffold(
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverAppBar.large(
            stretch: true,
            title: const Text('Настройки'),
          ),
          // const SliverToBoxAdapter(
          //   child: SettingsGroup(
          //     title: 'Профиль',
          //     options: [ExitProfileWidget()],
          //   ),
          // ),
          const SliverToBoxAdapter(
            child: SettingsGroup(
              title: 'Внешний вид',
              options: [
                //SettingsOption(title: ''),
                DynamicColorsWidget(),
                OledModeWidget(),
              ],
            ),
          ),
          if (TargetP.instance.isDesktop)
            const SliverToBoxAdapter(
              child: SettingsGroup(
                title: 'Плеер',
                options: [
                  PlayerDiscordRpc(),
                ],
              ),
            ),
          SliverToBoxAdapter(
            child: SettingsGroup(
              // Хранилище
              title: 'Данные', // импорт/экспорт локальных отметок
              options: [
                if (TargetP.instance.isDesktop)
                  SettingsOption(
                    title: 'Экспорт отметок',
                    subtitle:
                        'Экспортировать локальные отметки просмотра в json файл',
                    onTap: () {
                      export();
                    },
                  ),
                const ClearCacheWidget(),
                SettingsOption(
                  title: 'Очистить БД',
                  subtitle: 'Удалить все локальные отметки просмотра',
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Вы уверены?'),
                        content: const Text(
                            'Внимание!\nЭто удалит все локальные отметки просмотра'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Отмена")),
                          TextButton(
                              onPressed: () => clearIsar()
                                  .then((_) => Navigator.pop(context)),
                              child: const Text("Удалить")),
                        ],
                      ),
                    );
                  },
                ),
                SettingsOption(
                  title: 'Сброс настроек',
                  subtitle:
                      'Сброс настроек приложения до значений по умолчанию',
                  onTap: () async {
                    var box = Hive.box(BoxType.settings.name);
                    await box.clear();
                    if (context.mounted) {
                      context.scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Успешно!'),
                          duration: Duration(milliseconds: 1500),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsGroup(
              title: 'Ссылки',
              options: [
                SettingsOption(
                  title: 'Github',
                  subtitle: 'Ссылка на гитхаб приложения',
                  onTap: () => launchUrlString(
                    'https://github.com/wheremyfiji/ShikiWatch',
                    //'https://github.com/NozhkiBaal',
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                //const Divider(),
                SettingsOption(
                  title: 'Telegram',
                  subtitle: 'Связь с разработчиком', //Автор приложения
                  onTap: () => launchUrlString(
                    'https://t.me/wheremyfiji',
                    mode: LaunchMode.externalApplication,
                  ),
                ),

                SettingsOption(
                  title: 'Shikimori',
                  subtitle: 'Энциклопедия аниме и манги',
                  onTap: () => launchUrlString(
                    'https://shikimori.me',
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                if (TargetP.instance.isDesktop)
                  SettingsOption(
                    title: 'Anime4K',
                    subtitle:
                        'Набор высококачественных алгоритмов масштабирования / шумоподавления аниме в реальном времени с открытым исходным кодом',
                    onTap: () => launchUrlString(
                      'https://bloc97.github.io/Anime4K/',
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsGroup(
              title: 'О приложении',
              options: [
                const SettingsOption(
                  title: 'ShikiWatch',
                  subtitle:
                      'Неофициальное приложения для сайта shikimori.me с возможностью онлайн просмотра anime',
                  onTap: null,
                ),
                const VersionWidget(),
                // SettingsOption(
                //   title: 'Проверить обновления',
                //   subtitle: 'Проверить наличие обновлений приложения',
                //   onTap: () {
                //     showSnackBar(context, 'Обновлений не найдено');
                //   },
                // ),
                const GitCommitWidget(),
                SettingsOption(
                  title: 'Лицензии',
                  subtitle: 'Лицензии с открытым исходным кодом',
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'ShikiWatch',
                      applicationVersion: 'v1.3.3.7',
                      useRootNavigator: true,
                    );
                  },
                ),
                if (TargetP.instance.isDesktop)
                  SettingsOption(
                    title: 'распаковать pedals',
                    onTap: () async {
                      Directory app = await getApplicationSupportDirectory();
                      await launchUrl(Uri.parse(app.path));
                      //setRpc();
                    },
                  ),
              ],
            ),
          ),
          // SliverToBoxAdapter(
          //   child: SettingsGroup(
          //     title: '',
          //     options: [
          //       SettingsOption(title: ''),
          //     ],
          //   ),
          // ),

          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }
}

class ClearCacheWidget extends ConsumerWidget {
  const ClearCacheWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(cacheStorageServiceProvider);
    return SettingsOption(
      title: 'Очистить кэш',
      subtitle:
          'Удалить кэшированные изображения', //Удалить кэш API и изображений
      onTap: () async {
        context.scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Очистка..'),
          duration: Duration(milliseconds: 800),
        ));
        await storage.clear();
        await extended_image.clearDiskCachedImages();
        extended_image.clearMemoryImageCache();
        if (context.mounted) {
          context.scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Кэш очищен!'),
              duration: Duration(milliseconds: 1200),
            ),
          );
        }
      },
    );
  }
}

// class ExitProfileWidget extends ConsumerWidget {
//   const ExitProfileWidget({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final storage = ref.read(cacheStorageServiceProvider);

//     //deleteDB() async {}

//     logout() async {
//       var box = Hive.box(BoxType.settings.name);
//       await box.clear();
//       await storage.clear();
//       SecureStorageService.instance.deleteAll();
//       await extended_image.clearDiskCachedImages();
//       extended_image.clearMemoryImageCache();
//     }

//     return SettingsOption(
//       title: 'Выход',
//       subtitle: 'Выйти из учётной записи',
//       onTap: () async {
//         showDialog<String>(
//           context: context,
//           builder: (BuildContext context) => AlertDialog(
//             title: const Text('Выход'),
//             content: const Text('Вы точно хотите выйти из учётной записи?'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Нет'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // await deleteDB();
//                   // SecureStorageService.instance.deleteAll();
//                   // await extended_image.clearDiskCachedImages();
//                   // extended_image.clearMemoryImageCache();
//                   logout().then((value) => Phoenix.rebirth(context));

//                   //Phoenix.rebirth(context);

//                   //Navigator.pop(context);
//                   //ref.refresh(loginControllerProvider);
//                   //context.go('/login');
//                 },
//                 child: const Text('Да'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

class PlayerDiscordRpc extends StatelessWidget {
  const PlayerDiscordRpc({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: Hive.box(BoxType.settings.name).listenable(
        keys: [playerDiscordRpc],
      ),
      builder: (context, value, child) {
        final bool b = value.get(
          playerDiscordRpc,
          defaultValue: false,
        );
        return SwitchListTile(
          title: const Text('Discord RPC'),
          subtitle: const Text('Отображать текущую активность в Discord'),
          value: b,
          onChanged: (value) {
            Hive.box(BoxType.settings.name).put(playerDiscordRpc, value);
          },
        );
      },
    );
  }
}

class OledModeWidget extends StatelessWidget {
  const OledModeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: Hive.box(BoxType.settings.name).listenable(
        keys: [oledModeKey],
      ),
      builder: (context, value, child) {
        final bool isOled = value.get(
          oledModeKey,
          defaultValue: false,
        );
        return SwitchListTile(
          title: const Text('AMOLED-тема'),
          subtitle: const Text('Полносью чёрная тема'),
          value: isOled,
          onChanged: (value) {
            Hive.box(BoxType.settings.name).put(oledModeKey, value);
          },
        );
      },
    );
  }
}

class DynamicColorsWidget extends ConsumerWidget {
  const DynamicColorsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentProvider);

    if ((environment.sdkVersion ?? 0) < 31 && !TargetP.instance.isDesktop) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: Hive.box(BoxType.settings.name).listenable(
        keys: [dynamicThemeKey],
      ),
      builder: (context, value, child) {
        final bool isDynamic = value.get(
          dynamicThemeKey,
          defaultValue: true,
        );
        return SwitchListTile(
          title: const Text('Динамические цвета'),
          subtitle: TargetP.instance.isDesktop
              ? null
              : const Text('Динамические цвета на основе обоев телефона'),
          value: isDynamic,
          onChanged: (value) {
            Hive.box(BoxType.settings.name).put(dynamicThemeKey, value);
          },
        );
      },
    );
  }
}

class VersionWidget extends ConsumerWidget {
  const VersionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentProvider);

    final version = environment.packageInfo.version;
    final build = environment.packageInfo.buildNumber;
    final appname = environment.packageInfo.packageName;

    return SettingsOption(
      title: 'Версия: $version ($build)',
      subtitle: appname,
      onTap: null,
      // () {
      //   Clipboard.setData(
      //     ClipboardData(text: 'Версия: $version ($build)'),
      //   ).then(
      //     (_) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(
      //           content: Text('Версия приложения скопирована в буфер обмена'),
      //         ),
      //       );
      //     },
      //   );
      // },
    );
  }
}

class GitCommitWidget extends StatelessWidget {
  const GitCommitWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GitInformation>(
      future: GitInfo.get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final commitBranch = snapshot.data?.branch ?? '';
          final commitHash = snapshot.data?.hash;

          if (commitHash == null) {
            return const SizedBox.shrink();
          }

          return SettingsOption(
            title: 'Открыть коммит',
            subtitle: '$commitBranch | ${commitHash.substring(0, 7)}',
            onTap: commitHash == ''
                ? null
                : () {
                    launchUrlString(
                      'https://github.com/wheremyfiji/ShikiWatch/commit/$commitHash',
                      //mode: LaunchMode.externalApplication,
                    );
                  },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
