import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/enums/library_state.dart';
import 'manga_tabs/completed_manga_tab.dart';
import 'manga_tabs/dropped_manga_tab.dart';
import 'manga_tabs/on_hold_manga_tab.dart';
import 'manga_tabs/planned_manga_tab.dart';
import 'manga_tabs/re_reading_manga_tab.dart';
import 'manga_tabs/reading_manga_tab.dart';

import 'tabs/dropped_tab.dart';
import 'tabs/on_hold_tab.dart';
import 'tabs/rewatching_tab.dart';
import 'tabs/completed_tab.dart';
import 'tabs/planned_tab.dart';
import 'tabs/watching_tab.dart';
import 'tabs/local_history_tab.dart';

import 'library_page_appbar.dart';

class LibraryPage extends HookConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryStateProvider);

    final mangaTabController =
        useTabController(initialLength: 6, initialIndex: 0);

    final animeTabController =
        useTabController(initialLength: 7, initialIndex: 1);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: NestedScrollView(
          clipBehavior: Clip.none,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              LibraryPageAppBar(
                innerBoxIsScrolled: innerBoxIsScrolled,
                tabController: state == LibraryFragmentMode.manga
                    ? mangaTabController
                    : animeTabController,
              ),
            ];
          },
          body: SafeArea(
            top: false,
            bottom: false,
            child: state == LibraryFragmentMode.manga
                ? TabBarView(
                    controller: mangaTabController,
                    children: const [
                      ReadingMangaTab(),
                      PlannedMangaTab(),
                      CompletedMangaTab(),
                      ReReadingMangaTab(),
                      OnHoldMangaTab(),
                      DroppedMangaTab(),
                    ],
                  )
                : TabBarView(
                    controller: animeTabController,
                    children: const [
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
