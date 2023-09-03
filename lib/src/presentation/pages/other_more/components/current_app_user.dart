import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/cached_image.dart';

class CurrentAppUser extends StatelessWidget {
  const CurrentAppUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          ListTile(
            onTap: () => context.pushNamed('profile_id',
                pathParameters: {'id': SecureStorageService.instance.userId}),
            leading: CachedCircleImage(
              SecureStorageService.instance.userProfileImage,
            ),
            title: Text(
              SecureStorageService.instance.userNickname,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'id: ${SecureStorageService.instance.userId}',
              style: TextStyle(
                color: context.colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
          ),
          ListTile(
            onTap: () => context.pushNamed(
              'user_clubs',
              pathParameters: {'id': SecureStorageService.instance.userId},
            ),
            leading: const Icon(Icons.groups),
            title: const Text('Клубы'),
          ),
          ListTile(
            onTap: () => context.pushNamed(
              'user_online_history',
              pathParameters: {'id': SecureStorageService.instance.userId},
            ),
            leading: const Icon(Icons.history_rounded),
            title: const Text('История'),
          ),
        ],
      ),
    );
  }
}
