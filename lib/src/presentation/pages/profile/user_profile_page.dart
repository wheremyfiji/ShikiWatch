import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/extensions/buildcontext.dart';
import '../../providers/user_profile_provider.dart';
import '../../../domain/models/user.dart';
import '../../widgets/error_widget.dart';

import 'widgets/profile_actions.dart';
import 'widgets/profile_appbar.dart';

import 'widgets/user_friends.dart';
import 'widgets/user_lists_info.dart';

const double kDividerHeight = 16;
const _spacer = SliverPadding(padding: EdgeInsets.only(bottom: 16));

class UserProfilePage extends ConsumerWidget {
  final User data;

  const UserProfilePage({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(userProfileProvider(data.id.toString()));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.refresh(userProfileProvider(data.id.toString())),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              ...p.profile.when(
                data: (userInfo) => [
                  UserProfileAppBar(
                    userInfo,
                    title: userInfo.nickname ?? '',
                  ),
                  _spacer,
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverToBoxAdapter(
                      child: ProfileActions(userInfo.id!.toString()),
                    ),
                  ),
                  if (!p.friends.isLoading &&
                      !p.friends.hasError &&
                      p.friends.hasValue &&
                      p.friends.asData!.value.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: UserFriendsWidget(
                        p.friends.asData?.value ?? [],
                      ),
                    ),
                    _spacer,
                  ],
                  SliverToBoxAdapter(
                    child: UserListsInfo(
                      segmentsAnime: p.segmentsAnime,
                      segmentsManga: p.segmentsManga,
                      animesCount: p.userAnimesCount,
                      mangasCount: p.userMangasCount,
                      // label: '',
                      // segments: segments,
                    ),
                  ),
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
                      () =>
                          ref.refresh(userProfileProvider(data.id.toString())),
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