import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:network_logger/network_logger.dart';

import '../../../services/secure_storage/secure_storage_service.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/donate_widget.dart';

import 'components/current_app_user.dart';
import 'components/other_more_actions.dart';

class OtherMorePage extends StatelessWidget {
  const OtherMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomSearchBar(
          leading: const Icon(Icons.search),
          hintText: 'Поиск пользователей',
          onTap: () => context.pushNamed('user_search'),
        ),
        actions: [
          if (SecureStorageService.instance.userId == '384889' ||
              SecureStorageService.instance.userId == '1161605') ...[
            IconButton(
              onPressed: () => NetworkLoggerScreen.open(context),
              icon: const Icon(Icons.travel_explore),
            ),
          ],
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 16),
              sliver: SliverToBoxAdapter(
                child: CurrentAppUser(),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverToBoxAdapter(
                child: OtherMoreActions(),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverToBoxAdapter(child: DonateWidget()),
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
