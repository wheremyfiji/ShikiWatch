import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:shikidev/src/utils/target_platform.dart';

const _allDestinations = [
  NavigationRailDestination(
    label: Text('Библиотека'),
    icon: Icon(Icons.book_outlined),
    selectedIcon: Icon(Icons.book),
  ),
  NavigationRailDestination(
    // label: 'Главная',
    // icon: Icon(Icons.explore_outlined),
    // selectedIcon: Icon(Icons.explore),
    label: Text('Поиск'),
    icon: Icon(Icons.search_outlined), //explore
    selectedIcon: Icon(Icons.search),
  ),
  NavigationRailDestination(
    label: Text('Профиль'),
    icon: Icon(Icons.account_circle_outlined),
    selectedIcon: Icon(Icons.account_circle),
  ),
];

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  @override
  Widget build(BuildContext context) {
    final ext = MediaQuery.of(context).size.width > 1600; //1200

    return TargetP.instance.isDesktop
        ? Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  Stack(
                    children: [
                      NavigationRail(
                        // trailing: const Expanded(
                        //   child: Align(
                        //     alignment: Alignment.bottomLeft,
                        //     child: Padding(
                        //       padding: EdgeInsets.only(bottom: 8.0),
                        //       child: Text('Версия: пошел '),
                        //     ),
                        //   ),
                        // ),
                        extended: ext,
                        groupAlignment: -1.0,
                        destinations: _allDestinations,
                        selectedIndex: navigationShell.currentIndex,
                        onDestinationSelected: (tappedIndex) {
                          if (navigationShell.currentIndex == tappedIndex &&
                              GoRouter.of(context).location == '/explore') {
                            context.push('/explore/search');
                            return;
                          }

                          if (navigationShell.currentIndex == tappedIndex) {
                            navigationShell
                                .shellRouteContext.navigatorKey.currentState
                                ?.popUntil((r) => r.isFirst);
                          } else {
                            navigationShell.goBranch(tappedIndex);
                          }
                        },
                      ),
                    ],
                  ),
                  //const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: navigationShell,
                  )
                ],
              ),
            ),
          )
        : Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.book_outlined),
                  selectedIcon: Icon(Icons.book),
                  label: 'Библиотека',
                ),
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Главная',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_circle_outlined),
                  selectedIcon: Icon(Icons.account_circle),
                  label: 'Профиль',
                ),
              ],
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (tappedIndex) {
                if (navigationShell.currentIndex == tappedIndex &&
                    GoRouter.of(context).location == '/explore') {
                  context.push('/explore/search');
                  return;
                }

                if (navigationShell.currentIndex == tappedIndex) {
                  navigationShell.shellRouteContext.navigatorKey.currentState
                      ?.popUntil((r) => r.isFirst);
                } else {
                  navigationShell.goBranch(tappedIndex);
                }
              },
            ),
          );
  }
}
