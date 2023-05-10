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
  const ScaffoldWithNavBar({
    required this.shellState,
    required this.body,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulShellRouteState shellState;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    DateTime lastTimeBackbuttonWasClicked = DateTime.now();
    final ext = MediaQuery.of(context).size.width > 1600; //1200
    return WillPopScope(
      onWillPop: () async {
        if (DateTime.now().difference(lastTimeBackbuttonWasClicked) >=
            const Duration(seconds: 2)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              dismissDirection: DismissDirection.horizontal,
              margin: EdgeInsets.fromLTRB(16, 8, 16, 48),
              showCloseIcon: true,
              content: Text("Нажмите ещё раз для выхода"),
              duration: Duration(seconds: 2),
            ),
          );
          lastTimeBackbuttonWasClicked = DateTime.now();
          return false;
        } else {
          return true;
        }
      },
      child: TargetP.instance.isDesktop
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
                          selectedIndex: shellState.currentIndex,
                          onDestinationSelected: (tappedIndex) {
                            if (shellState.currentIndex == tappedIndex &&
                                GoRouter.of(context).location == '/explore') {
                              context.push('/explore/search');
                              return;
                            }

                            if (shellState.currentIndex == tappedIndex) {
                              shellState.currentNavigatorKey.currentState
                                  ?.popUntil((r) => r.isFirst);
                            } else {
                              shellState.goBranch(index: tappedIndex);
                            }
                          },
                        ),
                      ],
                    ),
                    //const VerticalDivider(thickness: 1, width: 1),
                    Expanded(
                      child: body,
                    )
                  ],
                ),
              ),
            )
          : Scaffold(
              body: body,
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
                selectedIndex: shellState.currentIndex,
                onDestinationSelected: (tappedIndex) {
                  if (shellState.currentIndex == tappedIndex &&
                      GoRouter.of(context).location == '/explore') {
                    context.push('/explore/search');
                    return;
                  }

                  if (shellState.currentIndex == tappedIndex) {
                    shellState.currentNavigatorKey.currentState
                        ?.popUntil((r) => r.isFirst);
                  } else {
                    shellState.goBranch(index: tappedIndex);
                  }
                },
              ),
            ),
    );
  }
}
