import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../services/secure_storage/secure_storage_service.dart';

enum LibraryState {
  anime,
  manga,
}

final libraryStateProvider = StateProvider<LibraryState>((ref) {
  return LibraryState.anime;
}, name: 'libraryProvider');

class LibraryPageAppBar extends ConsumerWidget {
  final bool innerBoxIsScrolled;
  final TabController tabController;

  const LibraryPageAppBar({
    Key? key,
    required this.innerBoxIsScrolled,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryStateProvider);

    return SliverAppBar(
      forceElevated: innerBoxIsScrolled,
      pinned: true,
      floating: true,
      snap: false,
      title: state == LibraryState.manga
          ? const Text('Манга и ранобэ')
          : const Text('Аниме'),
      actions: [
        PopupMenuButton<LibraryState>(
          tooltip: 'Выбор списка',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).colorScheme.onInverseSurface,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: LibraryState.anime,
              child: Text('Аниме'),
            ),
            PopupMenuItem(
              value: LibraryState.manga,
              child: Text('Манга и ранобэ'),
            ),
          ],
          onSelected: (value) {
            ref.read(libraryStateProvider.notifier).state = value;
          },
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundImage: ExtendedNetworkImageProvider(
              SecureStorageService.instance.userProfileImage,
              cache: true,
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
      ],
      bottom: TabBar(
        controller: tabController,
        unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            return states.contains(MaterialState.focused)
                ? null
                : Colors.transparent;
          },
        ),
        tabs: state == LibraryState.manga
            ? const [
                Tab(
                  text: 'Читаю',
                ),
                Tab(
                  text: 'В планах',
                ),
                Tab(
                  text: 'Прочитано',
                ),
                Tab(
                  text: 'Перечитываю',
                ),
                Tab(
                  text: 'Отложено',
                ),
                Tab(
                  text: 'Брошено',
                ),
              ]
            : const [
                Tab(
                  text: 'История',
                ),
                Tab(
                  text: 'Смотрю',
                ),
                Tab(
                  text: 'В планах',
                ),
                Tab(
                  text: 'Просмотрено',
                ),
                Tab(
                  text: 'Пересматриваю',
                ),
                Tab(
                  text: 'Отложено',
                ),
                Tab(
                  text: 'Брошено',
                ),
              ],
      ),
    );
  }
}
