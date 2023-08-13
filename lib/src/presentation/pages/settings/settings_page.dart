import 'dart:io';

import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../../services/secure_storage/secure_storage_service.dart';
import '../../providers/environment_provider.dart';
import '../../../utils/target_platform.dart';
import '../../../utils/router.dart';

import 'widgets/anime_source_option.dart';
import 'widgets/cache_option.dart';
import 'widgets/current_theme.dart';
import 'widgets/dynamic_colors.dart';
import 'widgets/library_layout.dart';
import 'widgets/library_start_fragment.dart';
import 'widgets/nav_dest_label_behavior_option.dart';
import 'widgets/oled_mode.dart';
import 'widgets/player_discord_rpc.dart';
import 'widgets/setting_option.dart';
import 'widgets/settings_group.dart';
import 'widgets/settings_header.dart';
import 'widgets/user_account_group.dart';
import 'widgets/version_option.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLogin = ref.watch(routerNotifierProvider.notifier).userLogin;

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar.medium(
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Настройки'),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  const SettingsHeader(),
                  if (SecureStorageService.instance.token != '' && userLogin)
                    const UserAccountGroup(),
                  SettingsGroup(
                    title: 'Внешний вид',
                    options: [
                      //SettingsOption(title: ''),
                      const CurrentThemeOption(),
                      const DynamicColorsOption(),
                      const OledModeOption(),
                      if (!TargetP.instance.isDesktop)
                        const NavDestLabelBehaviorOption(),
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
                  SettingsGroup(
                    title: 'Плеер',
                    options: [
                      const AnimeSourceOption(),
                      if (TargetP.instance.isDesktop)
                        const PlayerDiscordRpcOption(),
                    ],
                  ),
                  const SettingsGroup(
                    title: 'Библиотека', //   Приложение
                    options: [
                      LibraryStartFragmentOption(),
                      LibraryLayoutOption(),

                      // SwitchListTile(
                      //   value: false,
                      //   onChanged: (value) {},
                      //   title: const Text('NSFW-контент'),
                      //   subtitle: const Text('Искать и показывать NSFW-контент'),
                      // ),
                    ],
                  ),
                  SettingsGroup(
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
                  SettingsGroup(
                    title: 'Ссылки',
                    options: [
                      SettingsOption(
                        title: 'Github',
                        subtitle: 'Исходный код приложения',
                        onTap: () => launchUrlString(
                          'https://github.com/wheremyfiji/ShikiWatch',
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      //const Divider(),
                      SettingsOption(
                        title: 'Telegram',
                        subtitle:
                            'Новые версии, обсуждение и прочее', //Автор приложения
                        onTap: () => launchUrlString(
                          'https://t.me/shikiwatch',
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
                  SettingsGroup(
                    title: 'О приложении',
                    options: [
                      const SettingsOption(
                        title: 'ShikiWatch',
                        subtitle:
                            'Неофициальное приложение для сайта shikimori.me с возможностью онлайн просмотра аниме',
                        onTap: null,
                      ),
                      const VersionWidget(),
                      if (TargetP.instance.isDesktop)
                        const WindowsDeviceInfoWidget(),
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
                            Directory app =
                                await getApplicationSupportDirectory();
                            await launchUrl(Uri.parse(app.path));
                            //setRpc();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom),
            ),
          ],
        ),
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
