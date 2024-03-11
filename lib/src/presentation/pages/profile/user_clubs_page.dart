import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../services/secure_storage/secure_storage_service.dart';
import '../../../utils/extensions/riverpod_extensions.dart';
import '../../../data/data_sources/user_data_src.dart';
import '../../../domain/models/shiki_club.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';
import '../../../constants/config.dart';

final userClubsProvider = FutureProvider.autoDispose
    .family<List<ShikiClub>, String>((ref, userId) async {
  if (ref.state.isRefreshing) {
    await ref.debounce();
  }

  final token = ref.cancelToken();

  final c = await ref.read(userDataSourceProvider).getClubs(
        id: userId,
        token: SecureStorageService.instance.token,
        cancelToken: token,
      );

  return c.toList();
}, name: 'userClubsProvider');

class UserClubsPage extends ConsumerWidget {
  final String userId;

  const UserClubsPage(this.userId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(userClubsProvider(userId));

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text('Клубы'),
              pinned: true,
            ),
            clubs.when(
              data: (data) {
                if (data.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('Пусто'),
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final club = data[index];

                    return ListTile(
                      onTap: () {
                        launchUrlString(
                          '${AppConfig.staticUrl}/clubs/${club.id}',
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      leading: CachedCircleImage(
                        AppConfig.staticUrl + (club.logo?.original ?? ''),
                        //radius: 24,
                      ),
                      title: Text(
                        club.name ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: (club.isCensored != null && club.isCensored!)
                          ? const Icon(Icons.eighteen_up_rating_rounded)
                          : null,
                    );
                  },
                );
              },
              error: (error, stackTrace) => SliverFillRemaining(
                child: CustomErrorWidget(error.toString(),
                    () => ref.refresh(userClubsProvider(userId))),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
