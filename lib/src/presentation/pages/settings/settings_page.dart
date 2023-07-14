import 'dart:io';

import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../../services/secure_storage/secure_storage_service.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../utils/router.dart';
import '../../providers/environment_provider.dart';
import '../../../utils/target_platform.dart';

import 'widgets/cache_option.dart';
import 'widgets/current_theme.dart';
import 'widgets/dynamic_colors.dart';
import 'widgets/library_layout.dart';
import 'widgets/library_start_fragment.dart';
import 'widgets/oled_mode.dart';
import 'widgets/player_discord_rpc.dart';
import 'widgets/setting_option.dart';
import 'widgets/settings_group.dart';
import 'widgets/settings_header.dart';
import 'widgets/version_option.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLogin = ref.watch(routerNotifierProvider.notifier).userLogin;

    return Scaffold(
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          const SliverAppBar.large(
            title: Text('Настройки'),
          ),
          const SliverToBoxAdapter(
            child: SettingsHeader(),
          ),
          if (SecureStorageService.instance.token != '' && userLogin)
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

                      await SecureStorageService.instance.deleteAll();

                      ref.read(routerNotifierProvider.notifier).userLogin =
                          false;

                      if (context.mounted) {
                        context.scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Перезапустите приложение'),
                            duration: Duration(seconds: 5),
                          ),
                        );
                        GoRouter.of(context).goNamed('login');
                      }
                    },
                  ),
                ],
              ),
            ),
          const SliverToBoxAdapter(
            child: SettingsGroup(
              title: 'Внешний вид',
              options: [
                //SettingsOption(title: ''),
                CurrentThemeOption(),
                DynamicColorsOption(),
                OledModeOption(),
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
                  PlayerDiscordRpcOption(),
                ],
              ),
            ),
          const SliverToBoxAdapter(
            child: SettingsGroup(
              title: 'Библиотека', //   Приложение
              options: [
                LibraryLayoutOption(),
                LibraryStartFragmentOption(),
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

                if (userLogin)
                  SettingsOption(
                    title: 'Резервное копирование',
                    subtitle:
                        'Импорт/экспорт/удаление локальных отметок просмотра аниме',
                    onTap: () => context.pushNamed('backup'),
                  ),
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
                  subtitle: 'Открыть репозиторий приложения',
                  onTap: () => launchUrlString(
                    'https://github.com/wheremyfiji/ShikiWatch',
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
        ],
      ),
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
