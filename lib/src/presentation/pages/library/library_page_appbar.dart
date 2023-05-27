import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/box_types.dart';
import '../../../constants/hive_keys.dart';
import '../../../domain/enums/library_state.dart';
import '../../../services/secure_storage/secure_storage_service.dart';
import '../../widgets/cached_image.dart';

final libraryStateProvider = StateProvider<LibraryState>((ref) {
  int value = Hive.box(BoxType.settings.name).get(
    libraryStartFragmentKey,
    defaultValue: 0,
  );

  return LibraryState.values[value];
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
          ? const Text('Манга и ранобе')
          : const Text('Аниме'),
      actions: [
        // IconButton(
        //   onPressed: () {},
        //   icon: const Icon(Icons.notifications),
        // ),
        PopupMenuButton<LibraryState>(
          tooltip: 'Выбор списка',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          //initialValue: state,
          color: Theme.of(context).colorScheme.onInverseSurface,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: LibraryState.anime,
              child: Text('Аниме'),
            ),
            PopupMenuItem(
              value: LibraryState.manga,
              child: Text('Манга и ранобе'),
            ),
          ],
          onSelected: (value) {
            ref.read(libraryStateProvider.notifier).state = value;
          },
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundImage: CachedNetworkImageProvider(
              SecureStorageService.instance.userProfileImage,
              cacheManager: cacheManager,
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
