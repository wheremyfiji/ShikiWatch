import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/models/user.dart';
import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../../widgets/cached_image.dart';

class UserFriendsWidget extends StatelessWidget {
  final List<User> data;
  const UserFriendsWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Text(
        //   'Друзья (${data.length})',
        //   style: Theme.of(context)
        //       .textTheme
        //       .bodyLarge!
        //       .copyWith(fontWeight: FontWeight.bold),
        // ),
        Row(
          children: [
            Text(
              'Друзья',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '(${data.length})',
                style: context.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: data.length,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => const SizedBox(
              width: 16,
            ),
            itemBuilder: (context, index) {
              final friend = data[index];

              return Material(
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: friend.id.toString() ==
                          SecureStorageService.instance.userId
                      ? null
                      : () =>
                          context.push('/profile/${friend.id!}', extra: friend),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: CachedCircleImage(
                          friend.image?.x160 ?? friend.avatar ?? '',
                          radius: 42,
                        ),
                      ),
                      Expanded(
                        child: LimitedBox(
                          maxWidth: 80,
                          child: Text(
                            friend.nickname ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
