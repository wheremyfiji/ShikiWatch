import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/models/user.dart';
import '../../../../services/secure_storage/secure_storage_service.dart';
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

    const c = 6;

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

              return Container(
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
                              onTap: () {},
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
              );
            },
          ),
        )
      ],
    );
  }
}
