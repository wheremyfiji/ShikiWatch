import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/anime_player_page_extra.dart';
import '../domain/models/manga_short.dart';
import '../domain/models/pages_extra.dart';
import '../domain/models/user.dart';
import '../presentation/pages/about/about_page.dart';
import '../presentation/pages/anime_details/anime_details_page.dart';
import '../presentation/pages/calendar/calendar_page.dart';
import '../presentation/pages/character/character_page.dart';
import '../presentation/pages/explore/explore_page.dart';
import '../presentation/pages/explore/next_season_anime_page.dart';
import '../presentation/pages/explore/top_anime_page.dart';
import '../presentation/pages/explore/top_manga_page.dart';
import '../presentation/pages/library/library_page.dart';
import '../presentation/pages/library/search/library_anime_search_page.dart';
import '../presentation/pages/login/login_desktop_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/manga_detail/manga_detail_page.dart';
import '../presentation/pages/other_more/other_more_page.dart';
import '../presentation/pages/player/mobile/mobile_player_page.dart';
import '../presentation/pages/player/desktop/desktop_player_page.dart';
import '../presentation/pages/profile/my_profile_page.dart';
import '../presentation/pages/profile/user_clubs_page.dart';
import '../presentation/pages/profile/user_history_page.dart';
import '../presentation/pages/profile/user_profile_page.dart';
import '../presentation/pages/profile/user_search.dart';
import '../presentation/pages/root/root_page.dart';
import '../presentation/pages/search/anime_filter_page.dart';
import '../presentation/pages/search/anime_search_page.dart';
import '../presentation/pages/settings/local_database_manage_page.dart';
import '../presentation/pages/settings/settings_page.dart';
import '../presentation/pages/topics/topics_page.dart';
import '../presentation/providers/anime_search_provider.dart';
import '../services/secure_storage/secure_storage_service.dart';

import 'app_utils.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _tabNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'bebra');

BuildContext? get routerRootCtx => _rootNavigatorKey.currentState?.context;
BuildContext? get routerTabCtx => _tabNavigatorKey.currentState?.context;

final routerProvider = Provider.autoDispose<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider.notifier);

  return GoRouter(
    debugLogDiagnostics: true,
    observers: [
      SentryNavigatorObserver(),
      HeroController(),
    ],
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    routes: notifier.routes,
    redirect: notifier.redirect,
    initialLocation: '/splash',
  );
}, name: 'routerProvider');

final routerNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RouterNotifier, void>(() {
  return RouterNotifier();
}, name: 'routerNotifierProvider');

class RouterNotifier extends AutoDisposeAsyncNotifier<void>
    implements Listenable {
  VoidCallback? routerListener;
  bool userLogin = false;

  @override
  Future<void> build() async {
    userLogin = SecureStorageService.instance.token != '';

    if (userLogin) {
      await Sentry.configureScope(
        (scope) => scope.setUser(
          SentryUser(
            id: SecureStorageService.instance.userId,
            username: SecureStorageService.instance.userNickname,
          ),
        ),
      );
    }

    ref.listenSelf((_, __) {
      if (state.isLoading) return;
      routerListener?.call();
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    if (this.state.isLoading || this.state.hasError) {
      return null;
    }

    final String location = state.uri.toString();

    if (location == '/login/settings') {
      return null;
    }

    final isSplash = location == '/splash';

    if (isSplash) {
      return userLogin ? '/' : '/login';
    }

    final isLoggingIn = location == '/login';

    if (isLoggingIn) return userLogin ? '/' : null;

    return userLogin ? null : '/splash';
  }

  List<RouteBase> get routes => [
        GoRoute(
          path: '/',
          redirect: (_, __) => '/library',
        ),
        GoRoute(
          path: '/splash',
          name: 'splash',
          pageBuilder: (context, state) => FadeTransitionPage(
            key: state.pageKey,
            child: const SplashPage(),
          ),
        ),
        GoRoute(
          path: '/player',
          name: 'player',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            PlayerPageExtra extra = state.extra as PlayerPageExtra;

            return FadeTransitionPage(
              key: state.pageKey,
              child: AppUtils.instance.isDesktop
                  ? DesktopPlayerPage(extra)
                  : MobilePlayerPage(extra),
            );
          },
        ),
        GoRoute(
          path: '/backup',
          name: 'backup',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            return SharedAxisTransition(
              key: state.pageKey,
              child: const LocalDatabaseManage(),
            );
          },
        ),
        GoRoute(
          name: 'login',
          path: '/login',
          pageBuilder: (context, state) => FadeTransitionPage(
            key: state.pageKey,
            child: AppUtils.instance.isDesktop
                ? const LoginDesktopPage()
                : const LoginPage(),
          ),
          routes: [
            GoRoute(
              name: 'login_settings',
              path: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
        StatefulShellRoute(
          branches: <StatefulShellBranch>[
            /// library screen
            StatefulShellBranch(
              observers: [
                SentryNavigatorObserver(),
                HeroController(),
              ],
              navigatorKey: _tabNavigatorKey,
              routes: <RouteBase>[
                GoRoute(
                  name: 'library',
                  path: '/library',
                  builder: (BuildContext context, GoRouterState state) =>
                      LibraryPage(
                    key: state.pageKey,
                  ),
                  routes: <RouteBase>[
                    GoRoute(
                      name: 'library_search',
                      path: 'library_search',
                      pageBuilder: (context, state) {
                        return FadeTransitionPage(
                          key: state.pageKey,
                          child: const LibraryAnimeSearchPage(),
                        );
                      },
                    ),
                    GoRoute(
                      name: 'library_anime',
                      path: 'anime/:id',
                      pageBuilder: (context, state) {
                        final extra = state.extra as AnimeDetailsPageExtra;

                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: AnimeDetailsPage(
                            key: state.pageKey,
                            extra: extra,
                          ),
                          // child: TargetP.instance.isDesktop
                          //     ? AnimeDetailsDesktopPage(
                          //         key: state.pageKey,
                          //         animeData: data,
                          //       )
                          //     : AnimeDetailsPage(
                          //         key: state.pageKey,
                          //         animeData: data,
                          //       ),
                        );
                      },
                    ),
                    GoRoute(
                      name: 'library_manga',
                      path: 'manga/:id',
                      pageBuilder: (context, state) {
                        MangaShort data = state.extra as MangaShort;

                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: MangaDetailPage(
                            key: state.pageKey,
                            manga: data,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      name: 'character',
                      path: 'character/:id',
                      pageBuilder: (context, state) {
                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: CharacterPage(
                            state.pathParameters['id']!,
                            key: state.pageKey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            /// explore screen
            StatefulShellBranch(
              observers: [
                SentryNavigatorObserver(),
                HeroController(),
              ],
              routes: <RouteBase>[
                GoRoute(
                  name: 'explore',
                  path: '/explore',
                  builder: (BuildContext context, GoRouterState state) =>
                      ExplorePage(
                    key: state.pageKey,
                  ),
                  routes: [
                    GoRoute(
                      name: 'explore_search',
                      path: 'search',
                      pageBuilder: (context, state) {
                        final sId = state.uri.queryParameters['studioId'];
                        final gId = state.uri.queryParameters['genreId'];

                        return FadeTransitionPage(
                          key: state.pageKey,
                          child: AnimeSearchPage(
                            key: state.pageKey,
                            studioId: sId == null ? null : int.tryParse(sId),
                            genreId: gId == null ? null : int.tryParse(gId),
                          ),
                        );
                      },
                      routes: [
                        GoRoute(
                          name: 'search_filters', //AnimeSearchController
                          path: 'filters',
                          pageBuilder: (context, state) {
                            SearchPageParameters p =
                                state.extra as SearchPageParameters;

                            return SharedAxisTransition(
                              key: state.pageKey,
                              child: AnimeFilterPage(p),
                            );
                          },
                        ),
                      ],
                    ),
                    GoRoute(
                      name: 'explore_id',
                      path: r':id(\d+)',
                      pageBuilder: (context, state) {
                        final extra = state.extra as AnimeDetailsPageExtra;

                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: AnimeDetailsPage(
                            key: state.pageKey,
                            extra: extra,
                          ),
                          // child: TargetP.instance.isDesktop
                          //     ? AnimeDetailsDesktopPage(
                          //         key: state.pageKey,
                          //         animeData: data,
                          //       )
                          //     : AnimeDetailsPage(
                          //         key: state.pageKey,
                          //         animeData: data,
                          //       ),
                        );

                        //Animes data = state.extra as Animes;
                        // return FadeTransitionPage(
                        //   key: state.pageKey,
                        //   child: TargetP.instance.isDesktop
                        //       ? AnimeDetailsDesktopPage(
                        //           key: state.pageKey,
                        //           animeData: data,
                        //         )
                        //       : AnimeDetailsPage(
                        //           key: state.pageKey,
                        //           animeData: data,
                        //         ),
                        // );
                      },
                    ),
                    GoRoute(
                      name: 'calendar',
                      path: 'calendar',
                      pageBuilder: (context, state) {
                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: CalendarPage(
                            key: state.pageKey,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      name: 'top_anime',
                      path: 'top_anime',
                      pageBuilder: (context, state) {
                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: TopAnimePage(
                            key: state.pageKey,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      name: 'top_manga',
                      path: 'top_manga',
                      pageBuilder: (context, state) {
                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: TopMangaPage(
                            key: state.pageKey,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      name: 'next_season_anime',
                      path: 'next_season_anime',
                      pageBuilder: (context, state) {
                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: NextSeasonAnimePage(
                            key: state.pageKey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            /// topics sceen
            StatefulShellBranch(
              observers: [
                SentryNavigatorObserver(),
                HeroController(),
              ],
              routes: <RouteBase>[
                GoRoute(
                  name: 'topics',
                  path: '/topics',
                  builder: (context, state) => TopicsRootPage(
                    key: state.pageKey,
                  ),
                ),
              ],
            ),

            /// profile screen
            StatefulShellBranch(
              observers: [
                SentryNavigatorObserver(),
                HeroController(),
              ],
              routes: <RouteBase>[
                GoRoute(
                  name: 'profile',
                  path: '/profile',
                  // builder: (BuildContext context, GoRouterState state) =>
                  //     MyProfilePage(
                  //   key: state.pageKey,
                  // ),
                  builder: (BuildContext context, GoRouterState state) =>
                      OtherMorePage(
                    key: state.pageKey,
                  ),
                  routes: <RouteBase>[
                    GoRoute(
                      name: 'profile_id',
                      path: r':id(\d+)',
                      pageBuilder: (context, state) {
                        if (state.pathParameters['id']! ==
                            SecureStorageService.instance.userId) {
                          return SharedAxisTransition(
                            key: state.pageKey,
                            child: MyProfilePage(
                              key: state.pageKey,
                            ),
                          );
                        }

                        User data = state.extra as User;

                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: UserProfilePage(
                            key: state.pageKey,
                            data: data,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      name: 'user_clubs',
                      path: 'user_clubs/:id',
                      pageBuilder: (context, state) {
                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: UserClubsPage(
                            state.pathParameters['id']!,
                            key: state.pageKey,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      name: 'user_online_history',
                      path: 'user_online_history/:id',
                      pageBuilder: (context, state) {
                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: UserHistoryPage(
                            state.pathParameters['id']!,
                            key: state.pageKey,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      name: 'user_search',
                      path: 'user_search',
                      pageBuilder: (context, state) {
                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: UserSearchPage(
                            key: state.pageKey,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      name: 'profile_settings',
                      path: 'settings',
                      pageBuilder: (context, state) {
                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: SettingsPage(
                            key: state.pageKey,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      name: 'about',
                      path: 'about',
                      pageBuilder: (context, state) {
                        return SharedAxisTransition(
                          key: state.pageKey,
                          child: AboutPage(
                            key: state.pageKey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            return navigationShell;
          },
          navigatorContainerBuilder: (context, navigationShell, children) {
            return ScaffoldWithNavBar(
              navigationShell: navigationShell,
              children: children,
            );
          },
        ),
      ];

  @override
  void addListener(VoidCallback listener) {
    routerListener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    routerListener = null;
  }
}

class FadeTransitionPage extends CustomTransitionPage<void> {
  FadeTransitionPage({
    required ValueKey<String> key,
    required Widget child,
  }) : super(
          key: key,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 150),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
                opacity: animation.drive(_curveTween), child: child);
          },
          child: child,
        );

  static final CurveTween _curveTween = CurveTween(
      curve: Curves
          .easeOutCirc); //easeInOutExpo   easeInOut   easeOutCirc   easeIn
}

class SharedAxisTransition extends CustomTransitionPage<void> {
  SharedAxisTransition({
    required ValueKey<String> key,
    required Widget child,
  }) : super(
          key: key,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 150),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
              opacity: _fadeInTransition.animate(animation),
              child: AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) {
                  return Transform.translate(
                    offset: slideInTransition.evaluate(animation),
                    child: child,
                  );
                },
                child: child,
              ),
            );
          },
          child: child,
        );

  static final Animatable<double> _fadeInTransition = CurveTween(
    curve: decelerateEasing,
  ).chain(CurveTween(curve: const Interval(0.3, 1.0)));

  static final Animatable<Offset> slideInTransition = Tween<Offset>(
    begin: const Offset(30.0, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: standardEasing));
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
