import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/enums/library_state.dart';
import '../../providers/settings_provider.dart';
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

    final startLibraryFragment = ref
        .watch(settingsProvider.select((settings) => settings.libraryFragment));

    final mangaTabController =
        useTabController(initialLength: 6, initialIndex: 0);

    final animeTabController =
        useTabController(initialLength: 7, initialIndex: 1);

    final tabController = state == LibraryFragmentMode.manga
        ? mangaTabController
        : animeTabController;

    final startIndex = state == LibraryFragmentMode.manga ? 0 : 1;
    final currentIndex =
        useListenableSelector(tabController, () => tabController.index);

    return PopScope(
      canPop: state == startLibraryFragment && currentIndex == startIndex,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }

        if (currentIndex != startIndex) {
          tabController.animateTo(startIndex);
          return;
        }

        if (state == startLibraryFragment) {
          return;
        }

        ref.read(libraryStateProvider.notifier).state = startLibraryFragment;
      },
      child: Listener(
        onPointerUp: (_) {
          final currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        onPointerMove: (_) {
          final currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: Scaffold(
          body: NestedScrollView(
            clipBehavior: Clip.none,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                LibraryPageAppBar(
                  innerBoxIsScrolled: innerBoxIsScrolled,
                  tabController: tabController,
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
      ),
    );
  }
}
