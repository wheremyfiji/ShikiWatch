import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/target_platform.dart';

class InfoLinks extends StatelessWidget {
  const InfoLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          _buildItem(
            context,
            title: 'Github',
            subtitle: 'Исходный код приложения',
            icon: FontAwesomeIcons.github,
            onTap: () => launchUrlString(
              'https://github.com/wheremyfiji/ShikiWatch',
              mode: LaunchMode.externalApplication,
            ),
          ),
          _buildItem(
            context,
            title: 'Telegram',
            subtitle: 'Новые версии, обсуждение и прочее',
            icon: FontAwesomeIcons.telegram,
            onTap: () => launchUrlString(
              'https://t.me/shikiwatch',
              mode: LaunchMode.externalApplication,
            ),
          ),
          _buildItem(
            context,
            title: 'Shikimori',
            subtitle: 'Энциклопедия аниме и манги',
            icon: Icons.local_florist_rounded,
            //icon: FontAwesomeIcons.s,
            onTap: () => launchUrlString(
              'https://shikimori.me',
              mode: LaunchMode.externalApplication,
            ),
          ),
          if (TargetP.instance.isDesktop) ...[
            _buildItem(
              context,
              title: 'Anime4K',
              subtitle:
                  'Набор высококачественных алгоритмов масштабирования и шумоподавления для аниме в реальном времени с открытым исходным кодом',
              icon: Icons.four_k,
              onTap: () => launchUrlString(
                'https://bloc97.github.io/Anime4K/',
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    IconData? icon,
    required Function() onTap,
  }) {
    return ListTile(
      leading: icon == null
          ? null
          : Icon(
              icon,
              color: context.colorScheme.onBackground,
            ),
      title: Text(
        title,
        style: TextStyle(
          color: context.colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      onTap: onTap,
    );
  }
}
