import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../domain/models/anime_player_page_extra.dart';
import '../domain/models/manga_short.dart';
import '../domain/models/pages_extra.dart';
import '../domain/models/user.dart';

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
import '../presentation/pages/profile/user_search.dart';
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

        return FadeTransitionPage(
          key: state.pageKey,
          child: TargetP.instance.isDesktop
              ? AnimePlayerDesktopPage(data: data)
              : AnimePlayerPage(data: data),
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
                    //Animes data = state.extra as Animes;
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
