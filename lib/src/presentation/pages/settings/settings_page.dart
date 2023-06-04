import 'dart:io';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shikidev/src/services/secure_storage/secure_storage_service.dart';
import 'package:shikidev/src/utils/extensions/theme_mode.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../domain/enums/library_state.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../constants/box_types.dart';
import '../../../constants/hive_keys.dart';
import '../../../utils/target_platform.dart';
import '../../providers/environment_provider.dart';
import 'widgets/cache_option.dart';
import 'widgets/current_theme.dart';
import 'widgets/library_start_fragment.dart';
import 'widgets/setting_option.dart';
import 'widgets/settings_group.dart';
import 'widgets/version_option.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          const SliverAppBar.large(
            title: Text('Настройки'),
          ),
          if (SecureStorageService.instance.token != '')
            SliverToBoxAdapter(
              child: SettingsGroup(
                title: 'Аккаунт',
                options: [
                  SettingsOption(
                    title: 'Выйти из аккаунта',
                    subtitle: 'Очистить текущую авторизацию',
                    onTap: () async {
                      bool? dialogValue = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Выйти из аккаунта?'),
                          //content: const Text(''),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Отмена'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Выйти'),
                            ),
                          ],
                        ),
                      );

                      if (dialogValue == null || !dialogValue) {
                        return;
                      }

                      // await extended_image.clearDiskCachedImages();
                      // extended_image.clearMemoryImageCache();
                      await SecureStorageService.instance.deleteAll();
                      if (context.mounted) {
                        context.scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Перезапустите приложение'),
                            duration: Duration(seconds: 5),
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
              title: 'Внешний вид',
              options: [
                //SettingsOption(title: ''),
                ValueListenableBuilder(
                  valueListenable: Hive.box(BoxType.settings.name).listenable(
                    keys: [themeModeKey],
                  ),
                  builder: (context, value, child) {
                    final currentTheme = ThemeMode
                        .values[value.get(themeModeKey, defaultValue: 0)];

                    return SettingsOption(
                      title: 'Тема приложения',
                      subtitle: currentTheme.themeName,
                      onTap: () {
                        showModalBottomSheet(
                          useRootNavigator: true,
                          showDragHandle: true,
                          context: context,
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width >= 700
                                ? 700
                                : double.infinity,
                          ),
                          builder: (context) => CurrentThemeWidget(
                            currentTheme: currentTheme,
                          ),
                        );
                      },
                    );
                  },
                ),
                const DynamicColorsWidget(),
                const OledModeWidget(),
                // if (!TargetP.instance.isDesktop)
                //   SwitchListTile(
                //     value: false,
                //     onChanged: (value) {},
                //     title: const Text(
                //       'Прозрачный бар навигации',
                //     ),
                //     subtitle: const Text(
                //       'Если поддерживается системой (необходим перезапуск)',
                //     ),
                //   ),
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
              title: 'Приложение', // Библиотека
              options: [
                ValueListenableBuilder(
                  valueListenable: Hive.box(BoxType.settings.name).listenable(
                    keys: [libraryStartFragmentKey],
                  ),
                  builder: (context, value, child) {
                    final currentFragment = LibraryState.values[
                        value.get(libraryStartFragmentKey, defaultValue: 0)];
                    return SettingsOption(
                      title: 'Раздел по умолчанию', // кого раздел то..
                      subtitle: currentFragment.name,
                      onTap: () {
                        showModalBottomSheet(
                          useRootNavigator: true,
                          showDragHandle: true,
                          context: context,
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width >= 700
                                ? 700
                                : double.infinity,
                          ),
                          builder: (context) => LibraryStartFragment(
                            fragment: currentFragment,
                          ),
                        );
                      },
                    );
                  },
                ),
                // SwitchListTile(
                //   value: false,
                //   onChanged: (value) {},
                //   title: const Text('NSFW-контент'),
                //   subtitle: const Text('Искать и показывать NSFW-контент'),
                // ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsGroup(
              // Хранилище
              title: 'Данные', // импорт/экспорт локальных отметок
              options: [
                const ClearCacheWidget(),
                SettingsOption(
                  title: 'Резервное копирование',
                  subtitle:
                      'Импорт/экспорт/удаление локальных отметок просмотра аниме',
                  onTap: () => context.pushNamed('backup'),
                ),
                // SettingsOption(
                //   title: 'Сброс настроек',
                //   subtitle:
                //       'Сброс настроек приложения до значений по умолчанию',
                //   onTap: () async {
                //     var box = Hive.box(BoxType.settings.name);
                //     await box.clear();
                //     if (context.mounted) {
                //       context.scaffoldMessenger.showSnackBar(
                //         const SnackBar(
                //           content: Text('Настройки сброшены'),
                //           duration: Duration(milliseconds: 1500),
                //         ),
                //       );
                //     }
                //   },
                // ),
                // if (TargetP.instance.isDesktop)
                //   SettingsOption(
                //     title: 'Экспорт отметок',
                //     subtitle:
                //         'Экспортировать локальные отметки просмотра в json файл',
                //     onTap: () {
                //       export();
                //     },
                //   ),
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
                      'Неофициальное приложение для сайта shikimori.me с возможностью онлайн просмотра anime',
                  onTap: null,
                ),
                const VersionWidget(),
                if (TargetP.instance.isDesktop) const WindowsDeviceInfoWidget(),
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

// class GitCommitWidget extends StatelessWidget {
//   const GitCommitWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<GitInformation>(
//       future: GitInfo.get(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           final commitBranch = snapshot.data?.branch ?? '';
//           final commitHash = snapshot.data?.hash;

//           if (commitHash == null) {
//             return const SizedBox.shrink();
//           }

//           return SettingsOption(
//             title: 'Открыть коммит',
//             subtitle: '$commitBranch | ${commitHash.substring(0, 7)}',
//             onTap: commitHash == ''
//                 ? null
//                 : () {
//                     launchUrlString(
//                       'https://github.com/wheremyfiji/ShikiWatch/commit/$commitHash',
//                       //mode: LaunchMode.externalApplication,
//                     );
//                   },
//           );
//         } else {
//           return const SizedBox.shrink();
//         }
//       },
//     );
//   }
// }

class WindowsDeviceInfoWidget extends ConsumerWidget {
  const WindowsDeviceInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentProvider);

    final productName = environment.windowsInfo?.productName.toString() ?? '';
    final buildNumber = environment.windowsInfo?.buildNumber.toString() ?? '';
    final displayVersion =
        environment.windowsInfo?.displayVersion.toString() ?? '';

    return SettingsOption(
      title: 'Информация об устройстве',
      subtitle: '$productName $displayVersion ($buildNumber)',
      onTap: null,
    );
  }
}
