import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/enums/library_layout_mode.dart';
import '../../../providers/library_tab_page_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/loading_grid.dart';
import '../widgets/anime_tab_content.dart';
import '../widgets/empty_list.dart';

class RewatchingTab extends ConsumerWidget {
  const RewatchingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(rewatchingTabPageProvider);

    final LibraryLayoutMode currentLayout = ref
        .watch(settingsProvider.select((settings) => settings.libraryLayout));

    return controller.animes.when(
      data: (data) {
        if (data.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(rewatchingTabPageProvider),
            child: Stack(
              children: <Widget>[ListView(), const EmptyList()],
            ),
          );
        }

        return AnimeTabContent(
          data: data,
          currentLayout: currentLayout,
          onRefresh: () async => ref.refresh(rewatchingTabPageProvider),
          pageStorageKey: const PageStorageKey<String>('RewatchingTab'),
        );
      },
      loading: () => currentLayout == LibraryLayoutMode.grid
          ? const LoadingGrid()
          : const Center(
              child: CircularProgressIndicator(),
            ),
      error: (err, stack) => CustomErrorWidget(
        err.toString(),
        () => ref.refresh(rewatchingTabPageProvider),
      ),
    );
  }
}
