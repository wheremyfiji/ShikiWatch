import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import 'package:sentry_flutter/sentry_flutter.dart';

import '../domain/models/anime_player_page_extra.dart';
import '../domain/models/animes.dart';

import '../presentation/pages/anime_details/anime_details_desktop_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/login/login_desktop_page.dart';
import '../presentation/pages/my_profile/my_profile_page.dart';
import '../presentation/pages/player/anime_player_desktop_page.dart';
import '../presentation/pages/player/anime_player_page.dart';
import '../presentation/pages/root/root_page.dart';
import '../presentation/pages/search/anime_filter_page.dart';
import '../presentation/pages/search/anime_search_page.dart';
import '../presentation/pages/settings/settings_page.dart';
import '../presentation/pages/library/library_page.dart';
import '../presentation/pages/explore/explore_page.dart';
import '../presentation/pages/anime_details/anime_details_page.dart';

import 'target_platform.dart';
import 'updater.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _tabANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'bebra');

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  // observers: [
  //   //HeroController(),
  //   //SentryNavigatorObserver(),
  // ],
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
      //path: '/player/:link/:name/:ep',
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
      // builder: (context, state) {
      //   AnimePlayerPageExtra data = state.extra as AnimePlayerPageExtra;
      //   //return AnimePlayerPage(data: data);
      //   return PlayerPageWindows(data: data);
      // },
      // builder: (BuildContext context, GoRouterState state) => AnimePlayerPage(
      //   link: state.params['link'],
      //   name: state.params['name'],
      //   ep: state.params['ep'],
      // ),
    ),

    GoRoute(
      path: '/login',
      //parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => TargetP.instance.isDesktop
          ? const LoginDesktopPage()
          : const LoginPage(),
      routes: [
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),

    StatefulShellRoute(
      branches: <StatefulShellBranch>[
        /// library screen
        StatefulShellBranch(
          navigatorKey: _tabANavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/library',
              builder: (BuildContext context, GoRouterState state) =>
                  const LibraryPage(),
              routes: <RouteBase>[
                GoRoute(
                  path: r':id(\d+)',
                  //name: 'sample',
                  pageBuilder: (context, state) {
                    Animes data = state.extra as Animes;
                    return CustomTransitionPage(
                      child: TargetP.instance.isDesktop
                          ? AnimeDetailsDesktopPage(
                              animeData: data,
                            )
                          : AnimeDetailsPage(animeData: data),
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
          routes: <RouteBase>[
            GoRoute(
              name: 'explore',
              path: '/explore',
              builder: (BuildContext context, GoRouterState state) =>
                  const ExplorePage(),
              routes: [
                GoRoute(
                    name: 'explore_search',
                    path: 'search',
                    pageBuilder: (_, __) => CustomTransitionPage(
                          child: const AnimeSearchPage(),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 150),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 50),
                        ),
                    routes: [
                      GoRoute(
                        name: 'search_filters',
                        path: 'filters',
                        pageBuilder: (_, __) => CustomTransitionPage(
                          child: const AnimeFilterPage(),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 150),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 50),
                        ),
                      ),
                    ]),
                GoRoute(
                  name: 'explore_id',
                  path: r':id(\d+)',
                  pageBuilder: (context, state) {
                    Animes data = state.extra as Animes;
                    return CustomTransitionPage(
                      child: TargetP.instance.isDesktop
                          ? AnimeDetailsDesktopPage(
                              animeData: data,
                            )
                          : AnimeDetailsPage(animeData: data),
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
          routes: <RouteBase>[
            GoRoute(
              path: '/my_profile',
              builder: (BuildContext context, GoRouterState state) =>
                  const MyProfilePage(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'settings',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: const SettingsPage(),
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
      builder:
          (BuildContext context, StatefulShellRouteState state, Widget child) {
        return UpdaterWidget(
            child: ScaffoldWithNavBar(shellState: state, body: child));
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
