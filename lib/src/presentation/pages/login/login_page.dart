import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/config.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/router.dart';

import '../../providers/environment_provider.dart';
import 'disclaimer_dialog.dart';
import 'user_login_notifier.dart';

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: context.colorScheme.secondary,
      ),
      title: Text(
        title,
        style: context.textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodySmall?.copyWith(
          fontSize: 14.0,
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(
      userLoginProvider,
      (_, state) => state.whenOrNull(
        error: (error, stackTrace) {
          showErrorSnackBar(
            ctx: context,
            msg: error.toString(),
          );
        },
      ),
    );

    final loginState = ref.watch(userLoginProvider);
    final isLoading = loginState is AsyncLoading<void>;

    final environment = ref.watch(environmentProvider);
    final version = environment.packageInfo.version;
    final build = environment.packageInfo.buildNumber;

    return Material(
      color: context.colorScheme.surface,
      surfaceTintColor: context.colorScheme.surfaceTint,
      shadowColor: Colors.transparent,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12.0),
        topRight: Radius.circular(12.0),
      ),
      type: MaterialType.card,
      clipBehavior: Clip.hardEdge,
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16.0,
          16.0,
          16.0,
          MediaQuery.paddingOf(context).bottom,
        ),
        child: AnimatedSize(
          alignment: Alignment.topCenter,
          curve: Curves.easeInOutExpo,
          duration: const Duration(milliseconds: 400),
          child: isLoading
              ? const SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          bool? dialogValue = await showDialog<bool>(
                            context: context,
                            builder: (context) => const DisclaimerDialog(),
                          );

                          if (dialogValue ?? false) {
                            ref.read(userLoginProvider.notifier).logIn(
                              onFinally: () {
                                ref
                                    .read(routerNotifierProvider.notifier)
                                    .userLogin = true;

                                GoRouter.of(context).go('/library');
                              },
                            );
                          }
                        },
                        child: const Text('Войти с помощью Шикимори'),
                      ),
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      '$version ($build) - $kAppArch',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: context.colorScheme.secondary,
                      ),
                    ),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: TextButton(
                    //     style: ButtonStyle(
                    //       visualDensity: VisualDensity.compact,
                    //       shape:
                    //           MaterialStateProperty.all<RoundedRectangleBorder>(
                    //         RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(12.0),
                    //         ),
                    //       ),
                    //       foregroundColor: MaterialStateProperty.all<Color>(
                    //         context.colorScheme.secondary,
                    //       ),
                    //     ),
                    //     onPressed: () {},
                    //     child: const Text(
                    //       'Политика конфиденциальности',
                    //       style: TextStyle(
                    //         fontSize: 12.0,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
        ),
      ),
    );
  }
}

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = context.mediaQuery.size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const _BottomBar(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          automaticallyImplyLeading: false,
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      //height: 148.0,
                      height: height / 4,
                    ),
                    Text(
                      'ShikiWatch',
                      style: context.textTheme.displaySmall, //headlineLarge
                    ),
                    Text(
                      'Неофициальное приложение для Шикимори',
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.colorScheme.onBackground.withOpacity(
                          0.8,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    const _FeatureTile(
                      icon: Icons.video_library_rounded,
                      title: 'Просмотр аниме',
                      subtitle: 'Выбор источников и удобный встроенный плеер',
                    ),
                    const _FeatureTile(
                      icon: Icons.book_rounded,
                      title: 'Библиотека',
                      subtitle: 'Быстрый доступ к личным спискам тайтлов',
                    ),
                    const _FeatureTile(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Кастомизация',
                      subtitle: 'Продвинутый уровень настройки приложения',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
