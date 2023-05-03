import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/user.dart';
import '../../../../services/secure_storage/secure_storage_service.dart';

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
      children: [
        Text(
          'Друзья',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 4,
        ),
        SizedBox(
          height: 110,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
            ),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final friend = data[index];
              return Material(
                surfaceTintColor: Colors.transparent,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                shadowColor: Colors.transparent,
                child: InkWell(
                  //onTap: () {},
                  onTap: friend.id.toString() ==
                          SecureStorageService.instance.userId
                      ? null
                      : () =>
                          context.push('/profile/${friend.id!}', extra: friend),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: ExtendedNetworkImageProvider(
                            friend.image?.x160 ?? friend.avatar ?? '',
                            cache: true,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            friend.nickname ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Друзья',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        // const SizedBox(
        //   height: 4,
        // ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 100.0, //200 180
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            //shrinkWrap: true,
            //itemCount: data.length,
            itemCount: 12,
            itemBuilder: (context, index) {
              final friend = data[0];
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundImage: ExtendedNetworkImageProvider(
                          friend.image?.x160 ?? friend.avatar ?? '',
                          cache: true,
                        ),
                      ),
                      const SizedBox(
                        width: 80,
                        child: Text(
                          'aaaaaaaaaaaaaaaaaa',
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
