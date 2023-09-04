import 'dart:io';

import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../../services/secure_storage/secure_storage_service.dart';
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
import 'widgets/player_playback_speed.dart';
import 'widgets/setting_option.dart';
import 'widgets/settings_group.dart';
import 'widgets/user_account_group.dart';

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
                  if (SecureStorageService.instance.token != '' && userLogin)
                    const UserAccountGroup(),
                  SettingsGroup(
                    title: 'Внешний вид',
                    options: [
                      const CurrentThemeOption(),
                      const DynamicColorsOption(),
                      const OledModeOption(),
                      if (!TargetP.instance.isDesktop)
                        const NavDestLabelBehaviorOption(),
                    ],
                  ),
                  SettingsGroup(
                    title: 'Плеер',
                    options: [
                      const AnimeSourceOption(),
                      if (!TargetP.instance.isDesktop)
                        const PlayerPlaybackSpeedOption(),
                      // if (!TargetP.instance.isDesktop)
                      //   const PlayerSwipeSeekOption(),
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

                      if (TargetP.instance.isDesktop)
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
