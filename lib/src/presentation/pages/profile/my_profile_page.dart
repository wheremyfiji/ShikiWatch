import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:network_logger/network_logger.dart';

import '../../../services/secure_storage/secure_storage_service.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/error_widget.dart';

import 'widgets/user_anime_stats.dart';
import 'widgets/user_friends.dart';
import 'widgets/user_manga_stats.dart';
import 'widgets/user_profile_header.dart';

const double kDividerHeight = 16;

class MyProfilePage extends ConsumerWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.watch(userProfileProvider(SecureStorageService.instance.userId));

    return Scaffold(
      body: RefreshIndicator(
        //edgeOffset: 100,
        onRefresh: () async => ref
            .refresh(userProfileProvider(SecureStorageService.instance.userId)),
        child: CustomScrollView(
          key: const PageStorageKey<String>('ProfilePage'),
          slivers: [
            const _ProfilePageAppBar(),
            ...controller.profile.when(
              error: (error, stackTrace) {
                return [
                  SliverFillRemaining(
                    child: CustomErrorWidget(
                        error.toString(),
                        () => ref.refresh(userProfileProvider(
                            SecureStorageService.instance.userId))
                        //controller.fetch(),
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, kDividerHeight),
                  sliver: SliverToBoxAdapter(
                    child: UserProfileHeader(data: data),
                  ),
                ),
                if (!controller.friends.isLoading &&
                    !controller.friends.hasError &&
                    controller.friends.hasValue &&
                    controller.friends.asData!.value.isNotEmpty)
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, kDividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: UserFriendsWidget(
                        data: controller.friends.asData?.value ?? [],
                      ),
                    ),
                  ),
                if (data.stats?.statuses?.anime != null &&
                    controller.animeStat.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: UserAnimeStatsWidget(
                        list: controller.animeStat,
                      ),
                    ),
                  ),
                if (data.stats?.statuses?.manga != null &&
                    controller.mangaRanobeStat.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: UserMangaStatsWidget(
                        list: controller.mangaRanobeStat,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const _ProfilePageAppBar(),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () async => ref.refresh(
              userProfileProvider(SecureStorageService.instance.userId)),
          child: CustomScrollView(
            slivers: [
              ...controller.profile.when(
                error: (error, stackTrace) {
                  return [
                    SliverFillRemaining(
                      child: CustomErrorWidget(
                          error.toString(),
                          () => ref.refresh(userProfileProvider(
                              SecureStorageService.instance.userId))
                          //controller.fetch(),
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
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, kDividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: UserProfileHeader(data: data),
                    ),
                  ),
                  if (!controller.friends.isLoading &&
                      !controller.friends.hasError &&
                      controller.friends.hasValue &&
                      controller.friends.asData!.value.isNotEmpty)
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, kDividerHeight),
                      sliver: SliverToBoxAdapter(
                        child: UserFriendsWidget(
                          data: controller.friends.asData?.value ?? [],
                        ),
                      ),
                    ),
                  if (data.stats?.statuses?.anime != null &&
                      controller.animeStat.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: UserAnimeStatsWidget(
                          list: controller.animeStat,
                        ),
                      ),
                    ),
                  if (data.stats?.statuses?.manga != null &&
                      controller.mangaRanobeStat.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: UserMangaStatsWidget(
                          list: controller.mangaRanobeStat,
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

class _ProfilePageAppBar extends StatelessWidget {
  const _ProfilePageAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.large(
      title: const Text('Мой профиль'),
      actions: [
        // дебаг для деда
        if (SecureStorageService.instance.userId == '384889' ||
            SecureStorageService.instance.userId == '1161605') ...[
          IconButton(
            onPressed: () => NetworkLoggerScreen.open(context),
            icon: const Icon(Icons.travel_explore),
          ),
        ],
        IconButton(
          tooltip: 'Искать пользователя',
          onPressed: () => context.pushNamed('user_search'),
          icon: const Icon(
            Icons.person_search,
          ),
        ),
        IconButton(
          tooltip: 'Настройки',
          onPressed: () => context.push('/profile/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}
