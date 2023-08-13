import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/target_platform.dart';
import '../../../services/updater/update_service.dart';
import '../../../utils/utils.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_update_bottom_sheet.dart';

const _allDestinations = [
  NavigationRailDestination(
    label: Text('Библиотека'),
    icon: Icon(Icons.book_outlined),
    selectedIcon: Icon(Icons.book),
  ),
  NavigationRailDestination(
    label: Text('Главная'),
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
  ),
  NavigationRailDestination(
    label: Text('Профиль'),
    icon: Icon(Icons.account_circle_outlined),
    selectedIcon: Icon(Icons.account_circle),
  ),
];

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = MediaQuery.of(context).size.width > 1600; //1200

    ref.listen(
      appReleaseProvider,
      (_, state) => state.whenOrNull(
        data: (data) {
          if (data == null) {
            return;
          }
          AppUpdateBottomSheet.show(context: context, release: data);
        },
        error: (error, stackTrace) {
          showErrorSnackBar(
            ctx: context,
            msg: 'Возникла ошибка при поиске обновлений',
          );
        },
      ),
    );

    final NavigationDestinationLabelBehavior navDestLabelBehavior = ref.watch(
        settingsProvider.select((settings) => settings.navDestLabelBehavior));

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
              height: navDestLabelBehavior ==
                      NavigationDestinationLabelBehavior.alwaysHide
                  ? 60
                  : null,
              labelBehavior: navDestLabelBehavior,
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
