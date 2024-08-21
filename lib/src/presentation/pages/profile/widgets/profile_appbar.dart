import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher_string.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../widgets/custom_flexible_space.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/share_bottom_sheet.dart';

class UserProfileAppBar extends StatelessWidget {
  const UserProfileAppBar(
    this.userInfo, {
    super.key,
    required this.title,
    //this.actions,
  });

  final UserProfile userInfo;
  final String title;
  //final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: kToolbarHeight * 3,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      //actions: actions,
      actions: [
        IconButton(
          onPressed: () {
            ShareBottomSheet.show(
              context,
              header: ListTile(
                leading: CachedCircleImage(
                  userInfo.image?.x160 ?? userInfo.avatar ?? '',
                  clipBehavior: Clip.antiAlias,
                ),
                // SizedBox(
                //   width: 48,
                //   child:
                //   AspectRatio(
                //     aspectRatio: 1,
                //     child: ClipRRect(
                //       borderRadius: BorderRadius.circular(8.0),
                //       child: CachedImage(
                //         '${AppConfig.staticUrl}/system/animes/original/${title.id}.jpg',
                //       ),
                //     ),
                //   ),
                // ),
                title: Text(
                  userInfo.nickname ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  userInfo.lastOnline ?? userInfo.lastOnlineAt ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              url: userInfo.url ?? '',
            );
          },
          icon: const Icon(Icons.share_rounded),
          iconSize: 22,
        )
      ],
      flexibleSpace: CustomFlexibleSpace(
        title: title,
        act: true,
        background: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: kToolbarHeight + context.padding.top,
            ),
            SizedBox(
              height: kToolbarHeight * 2,
              child: _Content(
                name: userInfo.nickname ?? '',
                avatarUrl: userInfo.image?.x160 ?? userInfo.avatar ?? '',
                onlineInfo: userInfo.lastOnline ?? userInfo.lastOnlineAt ?? '',
                website: userInfo.website ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.name,
    required this.avatarUrl,
    required this.onlineInfo,
    required this.website,
  });

  final String name;
  final String avatarUrl;
  final String onlineInfo;
  final String website;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          CachedCircleImage(
            avatarUrl,
            radius: 48,
            clipBehavior: Clip.antiAlias,
          ),
          const SizedBox(
            width: 16.0,
          ),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                Text(
                  onlineInfo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (website.isNotEmpty)
                  InkWell(
                    onTap: () {
                      if (website.contains('https://') ||
                          website.contains('http://')) {
                        launchUrlString(
                          website,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        launchUrlString(
                          'https://$website',
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Text(
                      website,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
