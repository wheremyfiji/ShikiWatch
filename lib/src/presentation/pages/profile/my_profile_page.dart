import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../services/secure_storage/secure_storage_service.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/error_widget.dart';

import 'widgets/profile_actions.dart';
import 'widgets/profile_appbar.dart';
import 'widgets/user_friends.dart';
import 'widgets/user_lists_info.dart';

const kFlexHeight = 64.0;

const _spacer = SliverPadding(padding: EdgeInsets.only(bottom: 16));

class MyProfilePage extends ConsumerWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.watch(userProfileProvider(SecureStorageService.instance.userId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref
            .refresh(userProfileProvider(SecureStorageService.instance.userId)),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              ...controller.profile.when(
                data: (userInfo) => [
                  UserProfileAppBar(
                    userInfo,
                    title: 'Мой профиль',
                  ),
                  _spacer,
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverToBoxAdapter(
                      child: ProfileActions(userInfo.id!.toString()),
                    ),
                  ),
                  // friends
                  if (!controller.friends.isLoading &&
                      !controller.friends.hasError &&
                      controller.friends.hasValue &&
                      controller.friends.asData!.value.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: UserFriendsWidget(
                        controller.friends.asData?.value ?? [],
                      ),
                    ),
                    _spacer,
                  ],

                  SliverToBoxAdapter(
                    child: UserListsInfo(
                      segmentsAnime: controller.segmentsAnime,
                      segmentsManga: controller.segmentsManga,
                      animesCount: controller.userAnimesCount,
                      mangasCount: controller.userMangasCount,
                      // label: '',
                      // segments: segments,
                    ),
                  ),
                  // SliverList.builder(
                  //   itemCount: 24,
                  //   itemBuilder: (context, index) {
                  //     return ListTile(
                  //       title: Text('index $index'),
                  //     );
                  //   },
                  // ),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: context.padding.bottom,
                    ),
                  ),
                ],
                error: (error, stackTrace) => [
                  const SliverAppBar(),
                  SliverFillRemaining(
                    child: CustomErrorWidget(
                      error.toString(),
                      () => ref.refresh(userProfileProvider(
                          SecureStorageService.instance.userId)),
                    ),
                  ),
                ],
                loading: () => [
                  const SliverAppBar(),
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
