import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/app_utils.dart';

class InfoLinks extends StatelessWidget {
  const InfoLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
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
          ListTile(
            onTap: () => launchUrlString(
              'https://shikimori.one',
              mode: LaunchMode.externalApplication,
            ),
            leading: SvgPicture.asset(
              'assets/svg/shikimori.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            title: const Text('Shikimori'),
            subtitle: const Text('Энциклопедия аниме и манги'),
          ),
          if (AppUtils.instance.isDesktop) ...[
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
              size: 24,
              color: context.colorScheme.onSurfaceVariant,
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
