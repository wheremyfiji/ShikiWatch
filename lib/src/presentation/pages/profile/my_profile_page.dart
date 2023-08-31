import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../services/secure_storage/secure_storage_service.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/error_widget.dart';

import 'widgets/profile_actions.dart';
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

    //final isLoading = controller.profile.isLoading;

    return Scaffold(
      body: RefreshIndicator(
        //edgeOffset: 100,
        onRefresh: () async => ref
            .refresh(userProfileProvider(SecureStorageService.instance.userId)),
        child: SafeArea(
          top: false,
          bottom: false,
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
                              SecureStorageService.instance.userId))),
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
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, kDividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: ProfileActions(data.id!.toString()),
                    ),
                  ),
                  if (!controller.friends.isLoading &&
                      !controller.friends.hasError &&
                      controller.friends.hasValue &&
                      controller.friends.asData!.value.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: UserFriendsWidget(
                          data: controller.friends.asData?.value ?? [],
                        ),
                      ),
                    ),
                  if (data.stats?.statuses?.anime != null &&
                      controller.animeStat.isNotEmpty)
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, kDividerHeight),
                      sliver: SliverToBoxAdapter(
                        child: UserAnimeStatsWidget(
                          list: controller.animeStat,
                        ),
                      ),
                    ),
                  if (data.stats?.statuses?.manga != null &&
                      controller.mangaRanobeStat.isNotEmpty)
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, kDividerHeight),
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
      //actions: const [],
    );
  }
}
