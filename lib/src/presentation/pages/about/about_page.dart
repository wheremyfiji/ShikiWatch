import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../build_date_time.dart';
import '../../../constants/config.dart';
import '../../../services/updater/update_service.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../utils/target_platform.dart';
import '../../providers/environment_provider.dart';
import '../../widgets/app_update_bottom_sheet.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                clipBehavior: Clip.antiAlias,
                height: 96,
                child: Image.asset(
                  'assets/img/app-logo.png',
                ),
              ).animate().slideY(begin: .1, end: 0, curve: Curves.easeOutCirc),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Text(
                  'ShikiWatch',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Consumer(
                  builder: (context, ref, child) {
                    final environment = ref.watch(environmentProvider);

                    final version = environment.packageInfo.version;
                    final build = environment.packageInfo.buildNumber;

                    DateTime appBuildTime = DateTime.parse(appBuildDateTime);
                    final dateString = DateFormat.yMMMMd().format(appBuildTime);
                    final timeString = DateFormat.Hm().format(appBuildTime);

                    return Text(
                      '$version ($build) - $kAppArch\nот $dateString ($timeString)',
                      textAlign: TextAlign.center,
                      style: context.theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w400),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: _UpdateCard(),
            ),
            const SliverToBoxAdapter(
              child: _InfoLinks(),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLinks extends StatelessWidget {
  const _InfoLinks();

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
          const Divider(
            height: 1,
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
          const Divider(
            height: 1,
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
            const Divider(
              height: 1,
            ),
            _buildItem(
              context,
              title: 'Anime4K',
              subtitle:
                  'Набор высококачественных алгоритмов масштабирования / шумоподавления аниме в реальном времени с открытым исходным кодом',
              icon: Icons.four_k,
              //icon: FontAwesomeIcons.s,
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

class _UpdateCard extends ConsumerWidget {
  const _UpdateCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final release = ref.watch(appReleaseProvider);

    return release.when(
      data: (data) {
        if (data == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.system_update_rounded),
                    ),
                    Expanded(
                      child: Text(
                        'Доступно обновление',
                        style: context.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text('Новая версия: ${data.tag.replaceFirst('v', '')}'),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () => AppUpdateBottomSheet.show(
                          context: context, release: data),
                      child: const Text('Подробнее'),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    FilledButton(
                      onPressed: () => launchUrlString(
                        data.asset.browserDownloadUrl,
                        mode: LaunchMode.externalApplication,
                      ),
                      child: const Text('Загрузить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
