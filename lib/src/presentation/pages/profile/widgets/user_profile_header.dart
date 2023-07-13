import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher_string.dart';

import '../../../../domain/models/user_profile.dart';
import '../../../widgets/cached_image.dart';

class UserProfileHeader extends StatelessWidget {
  final UserProfile data;
  const UserProfileHeader({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 64, //72
          backgroundImage: CachedNetworkImageProvider(
            data.image?.x160 ?? data.avatar ?? '',
            cacheManager: cacheManager,
          ),
        ),
        const SizedBox(
          width: 16.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Tooltip(
              //message: 'gender: ${data.commonInfo![0]}',
              //  child:
              Text(
                data.nickname ?? 'ты кто',
                softWrap: true,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontSize: 20),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              //),
              const SizedBox(
                height: 4,
              ),
              Text(
                data.lastOnline ?? data.lastOnlineAt ?? '', //
                softWrap: true,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              if (data.website != null) ...[
                const SizedBox(
                  height: 2,
                ),
                InkWell(
                  onTap: () {
                    final url = data.website ?? '';
                    if (url.contains('https://') || url.contains('http://')) {
                      launchUrlString(
                        data.website!,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      launchUrlString(
                        'https://${data.website!}',
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Text(
                    data.website ?? '',
                    softWrap: true,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
