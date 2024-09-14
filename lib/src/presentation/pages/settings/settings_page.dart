import 'dart:io';

import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../../services/secure_storage/secure_storage_service.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../utils/router.dart';

import 'player_debug_page.dart';
import 'widgets/anime_365_option.dart';
import 'widgets/anime_source_option.dart';
import 'widgets/cache_option.dart';
import 'widgets/current_theme.dart';
import 'widgets/dynamic_colors.dart';
import 'widgets/library_layout.dart';
import 'widgets/library_start_fragment.dart';
import 'widgets/nav_dest_label_behavior_option.dart';
import 'widgets/oled_mode.dart';
import 'widgets/player_discord_rpc.dart';
import 'widgets/player_long_press_seek.dart';
import 'widgets/player_orientation_lock.dart';
import 'widgets/player_playback_speed.dart';
import 'widgets/scheme_variant_option.dart';
import 'widgets/setting_option.dart';
import 'widgets/settings_group.dart';
import 'widgets/user_account_group.dart';

// final _anime365Test = [
//   '384889',
//   '1161605',
//   '606442', // artim2
// ];

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListTile(
        onTap: () {},
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLogin = ref.watch(routerNotifierProvider.notifier).userLogin;

    // return Scaffold(
    //   body: SafeArea(
    //     top: false,
    //     bottom: false,
    //     child: CustomScrollView(
    //       slivers: [
    //         SliverAppBar.large(
    //           automaticallyImplyLeading: false,
    //           leading: IconButton(
    //             onPressed: () => context.pop(),
    //             icon: const Icon(Icons.arrow_back),
    //           ),
    //           title: const Text('Настройки'),
    //         ),
    //         const UserAccountTile(),
    //         const SettingTile(
    //           icon: Icons.palette_outlined,
    //           title: 'Внешний вид',
    //           subtitle: 'Внешний вид приложения',
    //         ),
    //         const SettingTile(
    //           icon: Icons.play_arrow_outlined,
    //           title: 'Плеер',
    //           subtitle: 'Кастомизация встроенного плеера',
    //         ),
    //         const SettingTile(
    //           icon: Icons.book_outlined,
    //           title: 'Библиотека',
    //           subtitle: 'Настройка поведения библиотеки',
    //         ),
    //         const SettingTile(
    //           icon: Icons.folder_open_outlined,
    //           title: 'Локальные данные',
    //           subtitle: 'Кэш и бекапы',
    //         ),
    //         SliverToBoxAdapter(
    //           child: SizedBox(height: MediaQuery.of(context).padding.bottom),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

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
                  if (SecureStorageService.instance.token != '' && userLogin)
                    const UserAccountGroup(),
                  SettingsGroup(
                    title: 'Внешний вид',
                    options: [
                      const CurrentThemeOption(),
                      const SchemeVariantOption(),
                      const DynamicColorsOption(),
                      const OledModeOption(),
                      if (!AppUtils.instance.isDesktop)
                        const NavDestLabelBehaviorOption(),
                    ],
                  ),
                  SettingsGroup(
                    title: 'Плеер',
                    options: [
                      const Anime365Option(),
                      const AnimeSourceOption(),
                      const PlayerPlaybackSpeedOption(),
                      if (!AppUtils.instance.isDesktop) ...[
                        const PlayerLongPressSeekOption(),
                        const PlayerOrientationLockOption(),
                      ],
                      // if (!TargetP.instance.isDesktop)
                      //   const PlayerSwipeSeekOption(),
                      if (Platform.isWindows || Platform.isLinux)
                        const PlayerDiscordRpcOption(),
                      SettingsOption(
                        title: 'Player logs',
                        onTap: () async {
                          context.navigator.push(PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                const PlayerDebugPage(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ));
                        },
                      ),
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
                              'Импорт/экспорт/удаление ЛОКАЛЬНЫХ отметок просмотра аниме',
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

                      if (Platform.isWindows)
                        SettingsOption(
                          title: 'распаковать pedals',
                          onTap: () async {
                            Directory app =
                                await getApplicationSupportDirectory();
                            await launchUrl(Uri.parse(app.path));
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
