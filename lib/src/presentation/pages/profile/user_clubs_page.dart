import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shikidev/src/constants/config.dart';
import 'package:shikidev/src/data/data_sources/user_data_src.dart';
import 'package:shikidev/src/services/secure_storage/secure_storage_service.dart';
import 'package:shikidev/src/utils/extensions/riverpod_extensions.dart';

import '../../../domain/models/shiki_club.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';

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
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Клубы'),
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
                    leading: CircleAvatar(
                      maxRadius: 24,
                      backgroundColor: Colors.transparent,
                      backgroundImage: CachedNetworkImageProvider(
                        AppConfig.staticUrl + (club.logo?.original ?? ''),
                        cacheManager: cacheManager,
                      ),
                    ),
                    title: Text(
                      club.name ?? '',
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
    );
  }
}
