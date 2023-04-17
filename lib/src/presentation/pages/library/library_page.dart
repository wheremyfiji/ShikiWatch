import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'tabs/dropped_tab.dart';
import 'tabs/on_hold_tab.dart';
import 'tabs/rewatching_tab.dart';
import 'tabs/completed_tab.dart';
import 'tabs/planned_tab.dart';
import 'tabs/watching_tab.dart';
//import 'tabs/liked_tab.dart';
import 'tabs/local_history_tab.dart';
import 'library_page_appbar.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: DefaultTabController(
          length: 7,
          initialIndex: 1,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                // SliverOverlapAbsorber(
                //   handle:
                //       NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                //   sliver: SliverSafeArea(
                //       top: false,
                //       sliver:
                LibraryPageAppBar(innerBoxIsScrolled)
                //),
              ];
            },
            body: const TabBarView(
              children: [
                //LikedTab(),
                LocalHistoryTab(),
                WatchingTab(),
                PlannedTab(),
                CompletedTab(),
                RewatchingTab(),
                OnHoldTab(),
                DroppedTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
