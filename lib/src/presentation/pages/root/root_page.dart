import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';

import '../../../services/updater/update_service.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../widgets/app_update_bottom_sheet.dart';
import '../../providers/settings_provider.dart';
import '../../../utils/app_utils.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    required this.children,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    const breakpoint = 600.0;
    const expandedBreakpoint = 1200.0;

    ref.listen(
      appReleaseProvider,
      (_, state) => state.whenOrNull(
        data: (data) {
          if (data == null) {
            return;
          }
          AppUpdateBottomSheet.show(context: context, release: data);
        },
        // error: (error, stackTrace) {
        //   showErrorSnackBar(
        //     ctx: context,
        //     msg: 'Произошла ошибка при проверке обновлений приложения',
        //     dur: const Duration(seconds: 5),
        //   );
        // },
      ),
    );

    final NavigationDestinationLabelBehavior navDestLabelBehavior = ref.watch(
        settingsProvider.select((settings) => settings.navDestLabelBehavior));

    if (screenWidth >= breakpoint) {
      return Scaffold(
        body: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Theme(
                      data: context.theme.copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: NavigationRail(
                        extended: AppUtils.instance.isDesktop
                            ? screenWidth > 1600
                            : screenWidth > expandedBreakpoint,
                        groupAlignment: -1.0,
                        selectedIndex: navigationShell.currentIndex,
                        onDestinationSelected: _onDestinationSelected,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.book_outlined),
                            selectedIcon: Icon(Icons.book),
                            label: Text('Библиотека'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.explore_outlined),
                            selectedIcon: Icon(Icons.explore_rounded),
                            label: Text('Обзор'),
                          ),
                          // NavigationRailDestination(
                          //   icon: Icon(Icons.forum_outlined),
                          //   selectedIcon: Icon(Icons.forum_rounded),
                          //   label: Text('Топики'),
                          // ),
                          NavigationRailDestination(
                            icon: Icon(Icons.more_horiz),
                            selectedIcon: Icon(Icons.more_horiz),
                            label: Text('Ещё'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: AnimatedBranchContainer(
                  currentIndex: navigationShell.currentIndex,
                  children: children,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: AnimatedBranchContainer(
        currentIndex: navigationShell.currentIndex,
        children: children,
      ),
      bottomNavigationBar: Theme(
        data: context.theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: NavigationBar(
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
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Обзор',
            ),
            // NavigationDestination(
            //   icon: Icon(Icons.forum_outlined),
            //   selectedIcon: Icon(Icons.forum_rounded),
            //   label: 'Топики',
            // ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz),
              selectedIcon: Icon(Icons.more_horiz),
              label: 'Ещё',
            ),
          ],
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
        ),
      ),
    );
  }

  _onDestinationSelected(int tappedIndex) {
    navigationShell.goBranch(
      tappedIndex,
      initialLocation: tappedIndex == navigationShell.currentIndex,
    );
  }

  // _onDestinationSelected(BuildContext context, int tappedIndex) {
  //   if (navigationShell.currentIndex == tappedIndex &&
  //       GoRouterState.of(context).uri.toString() == '/explore') {
  //     context.push('/explore/search');
  //     return;
  //   }

  //   if (navigationShell.currentIndex == tappedIndex) {
  //     navigationShell.shellRouteContext.navigatorKey.currentState
  //         ?.popUntil((r) => r.isFirst);
  //   } else {
  //     navigationShell.goBranch(tappedIndex);
  //   }
  // }
}

/// Custom branch Navigator container that provides animated transitions
/// when switching branches.
class AnimatedBranchContainer extends StatelessWidget {
  /// Creates a AnimatedBranchContainer
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  /// The index (in [children]) of the branch Navigator to display.
  final int currentIndex;

  /// The children (branch Navigators) to display in this container.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children.mapIndexed(
        (int index, Widget navigator) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0.0,
              end: index == currentIndex ? 1.0 : 0.0,
            ),
            builder: (context, value, child) {
              // return Transform.translate(
              //   offset: Offset(0, 20 - (value * 20)),
              //   child: Opacity(
              //     opacity: value,
              //     child: child,
              //   ),
              // );

              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0.0, 16.0 - (value * 16.0)),
                  child: child,
                ),
              );
            },
            curve: Curves.fastOutSlowIn, // fastOutSlowIn
            duration: const Duration(milliseconds: 400),
            //duration: const Duration(seconds: 1),
            child: _branchNavigatorWrapper(index, navigator),
          );
        },
      ).toList(),
    );

    // return Stack(
    //   children: children.mapIndexed(
    //     (int index, Widget navigator) {
    //       return AnimatedOpacity(
    //         opacity: index == currentIndex ? 1 : 0,
    //         duration: const Duration(milliseconds: 300),
    //         curve: Curves.fastOutSlowIn,
    //         child: _branchNavigatorWrapper(index, navigator),
    //       );
    //     },
    //   ).toList(),
    // );
  }

  Widget _branchNavigatorWrapper(int index, Widget navigator) {
    return IgnorePointer(
      ignoring: index != currentIndex,
      child: TickerMode(
        enabled: index == currentIndex,
        child: navigator,
      ),
    );
  }
}
