import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../providers/user_profile_provider.dart';
import '../../../domain/models/user.dart';
import '../../widgets/error_widget.dart';

import 'widgets/user_anime_stats.dart';
import 'widgets/user_friends.dart';
import 'widgets/user_manga_stats.dart';
import 'widgets/user_profile_header.dart';

const double kDividerHeight = 16;

class UserProfilePage extends ConsumerWidget {
  final User data;

  const UserProfilePage({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(userProfileProvider(data.id.toString()));

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar.large(
              title: Text(data.nickname ?? ''),
              actions: [
                PopupMenuButton(
                  tooltip: '',
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text("Открыть в браузере"),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    if (value == 0) {
                      launchUrlString(
                        data.url!,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
              ],
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () async =>
              ref.refresh(userProfileProvider(data.id.toString())),
          child: CustomScrollView(
            slivers: [
              ...p.profile.when(
                error: (error, stackTrace) {
                  return [
                    SliverFillRemaining(
                      child: CustomErrorWidget(
                        error.toString(),
                        () => ref
                            .refresh(userProfileProvider(data.id.toString())),
                        //p.fetch(),
                      ),
                    ),
                  ];
                },
                loading: () {
                  return [
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  ];
                },
                data: (data) => [
                  SliverPadding(
                    // padding: const EdgeInsets.all(16),
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, kDividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: UserProfileHeader(data: data),
                    ),
                  ),
                  // SliverPadding(
                  //   padding:
                  //       const EdgeInsets.fromLTRB(16, 0, 16, kDividerHeight),
                  //   sliver: SliverToBoxAdapter(
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //       children: [
                  //         Tooltip(
                  //           message: 'Отправить сообщение',
                  //           child: IconButton(
                  //             onPressed: () {
                  //               launchUrlString(
                  //                 '${AppConfig.staticUrl}/${SecureStorageService.instance.userNickname}/dialogs/${data.nickname!}',
                  //                 mode: LaunchMode.externalApplication,
                  //               );
                  //             },
                  //             icon: const Icon(Icons.mail),
                  //           ),
                  //         ),
                  //         data.inFriends ?? false
                  //             ? const Tooltip(
                  //                 message: 'Удалить из друзей',
                  //                 child: IconButton(
                  //                   onPressed: null,
                  //                   icon: Icon(Icons.person_remove),
                  //                 ),
                  //               )
                  //             : const Tooltip(
                  //                 message: 'Добавить в друзья',
                  //                 child: IconButton(
                  //                   onPressed: null,
                  //                   icon: Icon(Icons.person_add),
                  //                 ),
                  //               ),
                  //         const Tooltip(
                  //           message: 'Игнорировать пользователя',
                  //           child: IconButton(
                  //             //onPressed: () {},
                  //             onPressed: null,
                  //             icon: Icon(Icons.notifications_paused),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  if (!p.friends.isLoading &&
                      !p.friends.hasError &&
                      p.friends.hasValue &&
                      p.friends.asData!.value.isNotEmpty)
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, kDividerHeight),
                      //padding: const EdgeInsets.fromLTRB(8, 0, 8, kDividerHeight),
                      sliver: SliverToBoxAdapter(
                        child: UserFriendsWidget(
                          data: p.friends.asData?.value ?? [],
                        ),
                      ),
                    ),
                  if (data.stats?.statuses?.anime != null &&
                      p.animeStat.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: UserAnimeStatsWidget(
                          list: p.animeStat,
                        ),
                      ),
                    ),
                  if (data.stats?.statuses?.manga != null &&
                      p.mangaRanobeStat.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: UserMangaStatsWidget(
                          list: p.mangaRanobeStat,
                        ),
                      ),
                    ),
                  //const SliverToBoxAdapter(child: SizedBox(height: 60)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
