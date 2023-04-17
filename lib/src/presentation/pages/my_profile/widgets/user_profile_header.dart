import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../domain/models/user_profile.dart';

class UserProfileHeader extends StatelessWidget {
  final UserProfile data;
  const UserProfileHeader({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 72, //64
          backgroundImage: ExtendedNetworkImageProvider(
              data.image?.x160 ?? data.avatar ?? '',
              cache: true),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
