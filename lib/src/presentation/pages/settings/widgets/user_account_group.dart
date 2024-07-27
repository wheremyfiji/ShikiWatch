import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/router.dart';
import '../../../widgets/cached_image.dart';

import 'settings_group.dart';

class UserAccountTile extends ConsumerWidget {
  const UserAccountTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: ListTile(
        leading: CachedCircleImage(
          SecureStorageService.instance.userProfileImage,
          radius: 12,
        ),
        title: Text(
          SecureStorageService.instance.userNickname,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.colorScheme.onBackground,
          ),
        ),
        subtitle: Text(
          'Выйти из аккаунта',
          style: TextStyle(
            color: context.colorScheme.onBackground.withOpacity(0.8),
          ),
        ),
        onTap: () async {
          bool? dialogValue = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              icon: const Icon(Icons.logout_rounded),
              title: const Text('Выйти из аккаунта?'),
              content: const Text(
                  'Локальная история и настройки останутся на месте'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Выйти'),
                ),
              ],
            ),
          );

          if (dialogValue == null || !dialogValue) {
            return;
          }

          await SecureStorageService.instance.deleteAll();

          ref.read(routerNotifierProvider.notifier).userLogin = false;

          if (context.mounted) {
            context.scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Перезапусти приложение'),
                duration: Duration(seconds: 5),
              ),
            );
            GoRouter.of(context).goNamed('login');
          }
        },
      ),
    );
  }
}

class UserAccountGroup extends ConsumerWidget {
  const UserAccountGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsGroup(
      title: 'Аккаунт',
      options: [
        ListTile(
          leading: CachedCircleImage(
            SecureStorageService.instance.userProfileImage,
          ),
          title: Text(
            SecureStorageService.instance.userNickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.colorScheme.onBackground,
            ),
          ),
          subtitle: Text(
            'Выйти из аккаунта',
            style: TextStyle(
              color: context.colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
          onTap: () async {
            bool? dialogValue = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                icon: const Icon(Icons.logout_rounded),
                title: const Text('Выйти из аккаунта?'),
                content: const Text(
                    'Локальная история и настройки останутся на месте'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Отмена'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Выйти'),
                  ),
                ],
              ),
            );

            if (dialogValue == null || !dialogValue) {
              return;
            }

            await SecureStorageService.instance.deleteAll();

            ref.read(routerNotifierProvider.notifier).userLogin = false;

            if (context.mounted) {
              context.scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Перезапустите приложение'),
                  duration: Duration(seconds: 5),
                ),
              );
              GoRouter.of(context).goNamed('login');
            }
          },
        ),
      ],
    );
  }
}
