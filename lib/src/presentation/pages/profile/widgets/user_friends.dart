import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/models/user.dart';
import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../../../utils/extensions/date_time_ext.dart';
import '../../../widgets/cached_image.dart';

class UserFriendsWidget extends StatelessWidget {
  const UserFriendsWidget(
    this.friends, {
    super.key,
  });

  final List<User> friends;

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const SizedBox.shrink();
    }

    const c = 10;

    final overflow = friends.length > c;
    final listLength = overflow ? c + 1 : friends.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Badge.count(
            alignment: AlignmentDirectional.bottomEnd,
            offset: const Offset(24, -4),
            count: friends.length,
            backgroundColor: context.colorScheme.secondary,
            textColor: context.colorScheme.onSecondary,
            child: Text(
              'Друзья',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 8.0,
        ),
        SizedBox(
          height: 84,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: listLength,
            itemBuilder: (context, index) {
              final friend = friends[index];
              final isFirstItem = index == 0;
              final isLast = index == listLength - 1;

              return Tooltip(
                message: friend.nickname,
                child: Container(
                  margin: EdgeInsets.only(
                    left: isFirstItem ? 16 : 0,
                    right: isLast ? 16 : 8,
                  ),
                  width: 84,
                  height: 84,
                  child: isLast && overflow
                      ? Stack(
                          children: [
                            CircleAvatar(
                              radius: 42,
                              child: Text(
                                '+${friends.length - c}',
                              ),
                            ),
                            Material(
                              type: MaterialType.transparency,
                              clipBehavior: Clip.hardEdge,
                              borderRadius: BorderRadius.circular(42),
                              child: InkWell(
                                onTap: () => UserFriendsBottomSheet.show(
                                  context,
                                  friends: friends,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            CachedCircleImage(
                              friend.image?.x160 ?? friend.avatar ?? '',
                              radius: 42,
                              clipBehavior: Clip.antiAlias,
                            ),
                            Material(
                              type: MaterialType.transparency,
                              clipBehavior: Clip.hardEdge,
                              borderRadius: BorderRadius.circular(42),
                              child: InkWell(
                                onTap: friend.id.toString() ==
                                        SecureStorageService.instance.userId
                                    ? null
                                    : () => context.push(
                                          '/profile/${friend.id!}',
                                          extra: friend,
                                        ),
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

class UserFriendsBottomSheet extends StatelessWidget {
  const UserFriendsBottomSheet(this.friends, {super.key});

  final List<User> friends;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      minChildSize: 0.5,
      initialChildSize: 0.75,
      snapSizes: const [0.75, 1.0],
      builder: (context, scrollController) {
        return SafeArea(
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    'Друзья',
                    style: context.textTheme.titleLarge,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(),
                ),
              ),
              SliverList.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];

                  final userLastOnline =
                      DateTime.tryParse(friend.lastOnlineAt ?? '')?.toLocal();

                  return ListTile(
                    onTap: friend.id.toString() ==
                            SecureStorageService.instance.userId
                        ? null
                        : () => context.push(
                              '/profile/${friend.id!}',
                              extra: friend,
                            ),
                    leading: CachedCircleImage(
                      friend.image?.x160 ?? friend.avatar ?? '',
                      //radius: 42,
                      clipBehavior: Clip.antiAlias,
                    ),
                    title: Text(friend.nickname!),
                    subtitle: userLastOnline == null
                        ? null
                        : Text(
                            'онлайн ${userLastOnline.convertToDaysAgo()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void show(BuildContext context, {required List<User> friends}) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      useRootNavigator: false,
      showDragHandle: true,
      backgroundColor: context.colorScheme.background,
      elevation: 0,
      builder: (_) => SafeArea(child: UserFriendsBottomSheet(friends)),
    );
  }
}
