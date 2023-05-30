import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../domain/models/anime_player_page_extra.dart';
import '../domain/models/animes.dart';
import '../domain/models/manga_short.dart';
import '../domain/models/user.dart';

import '../presentation/pages/anime_details/anime_details_desktop_page.dart';
import '../presentation/pages/calendar/calendar_page.dart';
import '../presentation/pages/explore/next_season_anime_page.dart';
import '../presentation/pages/explore/top_anime_page.dart';
import '../presentation/pages/explore/top_manga_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/login/login_desktop_page.dart';
import '../presentation/pages/manga_detail/manga_detail_page.dart';
import '../presentation/pages/profile/my_profile_page.dart';
import '../presentation/pages/player/anime_player_desktop_page.dart';
import '../presentation/pages/player/anime_player_page.dart';
import '../presentation/pages/profile/user_profile_page.dart';
import '../presentation/pages/root/root_page.dart';
import '../presentation/pages/search/anime_filter_page.dart';
import '../presentation/pages/search/anime_search_page.dart';
import '../presentation/pages/settings/settings_page.dart';
import '../presentation/pages/library/library_page.dart';
import '../presentation/pages/explore/explore_page.dart';
import '../presentation/pages/anime_details/anime_details_page.dart';
import '../presentation/pages/settings/local_database_manage_page.dart';

import '../presentation/providers/anime_search_provider.dart';
import 'target_platform.dart';
import 'updater.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _tabANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'bebra');

BuildContext? get routerCtx =>
    router.routerDelegate.navigatorKey.currentContext;

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  observers: [
    SentryNavigatorObserver(),
  ],
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      redirect: (_, __) => '/login',
    ),

    // GoRoute(
    //   path: '/modal',
    //   parentNavigatorKey: _rootNavigatorKey,
    //   builder: (BuildContext context, GoRouterState state) =>
    //       const ModalScreen(),
    // ),

    GoRoute(
      path: '/player',
      name: 'player',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        AnimePlayerPageExtra data = state.extra as AnimePlayerPageExtra;
        return CustomTransitionPage(
          child: TargetP.instance.isDesktop
              ? AnimePlayerDesktopPage(data: data)
              : AnimePlayerPage(data: data),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 0),
        );
      },
    ),

    GoRoute(
      path: '/backup',
      name: 'backup',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: const LocalDatabaseManage(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 0),
        );
      },
    ),

    GoRoute(
      name: 'login',
      path: '/login',
      //parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => TargetP.instance.isDesktop
          ? const LoginDesktopPage()
          : const LoginPage(),
      routes: [
        GoRoute(
          name: 'login_settings',
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),

    StatefulShellRoute.indexedStack(
      branches: <StatefulShellBranch>[
        /// library screen
        StatefulShellBranch(
          observers: [
            SentryNavigatorObserver(),
          ],
          navigatorKey: _tabANavigatorKey,
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
                  name: 'library_anime',
                  path: 'anime/:id',
                  pageBuilder: (context, state) {
                    Animes data = state.extra as Animes;
                    return CustomTransitionPage(
                      child: TargetP.instance.isDesktop
                          ? AnimeDetailsDesktopPage(
                              key: state.pageKey,
                              animeData: data,
                            )
                          : AnimeDetailsPage(
                              key: state.pageKey,
                              animeData: data,
                            ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 150),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 150),
                    );
                  },
                ),
                GoRoute(
                  name: 'library_manga',
                  path: 'manga/:id',
                  pageBuilder: (context, state) {
                    MangaShort data = state.extra as MangaShort;
                    return CustomTransitionPage(
                      child: MangaDetailPage(
                        key: state.pageKey,
                        manga: data,
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 150),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 150),
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
                    final sId = state.queryParameters['studioId'];
                    final gId = state.queryParameters['genreId'];
                    return CustomTransitionPage(
                      child: AnimeSearchPage(
                        key: state.pageKey,
                        studioId: sId == null ? null : int.tryParse(sId),
                        genreId: gId == null ? null : int.tryParse(gId),
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 150),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 50),
                    );
                  },
                  routes: [
                    GoRoute(
                        name: 'search_filters', //AnimeSearchController
                        path: 'filters',
                        pageBuilder: (context, state) {
                          SearchPageParameters p =
                              state.extra as SearchPageParameters;
                          return CustomTransitionPage(
                            child: AnimeFilterPage(p),
                            transitionsBuilder: (_, animation, __, child) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                            transitionDuration:
                                const Duration(milliseconds: 150),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 50),
                          );
                        }),
                  ],
                ),
                GoRoute(
                  name: 'explore_id',
                  path: r':id(\d+)',
                  pageBuilder: (context, state) {
                    Animes data = state.extra as Animes;
                    return CustomTransitionPage(
                      child: TargetP.instance.isDesktop
                          ? AnimeDetailsDesktopPage(
                              key: state.pageKey,
                              animeData: data,
                            )
                          : AnimeDetailsPage(
                              key: state.pageKey,
                              animeData: data,
                            ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 150),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 150),
                    );
                  },
                ),
                GoRoute(
                  name: 'calendar',
                  path: 'calendar',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: CalendarPage(
                        key: state.pageKey,
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 150),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 150),
                    );
                  },
                ),
                GoRoute(
                  name: 'top_anime',
                  path: 'top_anime',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: TopAnimePage(
                        key: state.pageKey,
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 150),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 150),
                    );
                  },
                ),
                GoRoute(
                  name: 'top_manga',
                  path: 'top_manga',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: TopMangaPage(
                        key: state.pageKey,
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 150),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 150),
                    );
                  },
                ),
                GoRoute(
                  name: 'next_season_anime',
                  path: 'next_season_anime',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: NextSeasonAnimePage(
                        key: state.pageKey,
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 150),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 150),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        /// my_profile screen
        StatefulShellBranch(
          observers: [
            SentryNavigatorObserver(),
          ],
          routes: <RouteBase>[
            GoRoute(
              name: 'profile',
              path: '/profile',
              builder: (BuildContext context, GoRouterState state) =>
                  MyProfilePage(
                key: state.pageKey,
              ),
              routes: <RouteBase>[
                GoRoute(
                  name: 'profile_id',
                  path: r':id(\d+)',
                  pageBuilder: (context, state) {
                    User data = state.extra as User;
                    return CustomTransitionPage(
                      child: UserProfilePage(
                        key: state.pageKey,
                        data: data,
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 150),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 150),
                    );
                  },
                ),
                GoRoute(
                  name: 'profile_settings',
                  path: 'settings',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: SettingsPage(
                        key: state.pageKey,
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 150),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 0),
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
        return ExcludeSemantics(
          child: UpdaterWidget(
            child: ScaffoldWithNavBar(navigationShell: navigationShell),
          ),
        );
      },
    ),
  ],
  // errorBuilder: (context, state) => Scaffold(
  //   body: Padding(
  //     padding: const EdgeInsets.all(24.0),
  //     child: Center(
  //       child: Text(state.error.toString()),
  //     ),
  //   ),
  // ),
);
