import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../utils/extensions/buildcontext.dart';
import '../../providers/environment_provider.dart';
import '../../../../build_date_time.dart';
import '../../../constants/config.dart';

import 'components/info_links.dart';
import 'components/update_card.dart';

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
              child: UpdateCard(),
            ),
            const SliverToBoxAdapter(
              child: InfoLinks(),
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
