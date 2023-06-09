import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/enums/library_state.dart';
import '../../../services/secure_storage/secure_storage_service.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/cached_image.dart';

final libraryStateProvider = StateProvider<LibraryFragmentMode>((ref) {
  // int value = Hive.box(BoxType.settings.name).get(
  //   libraryStartFragmentKey,
  //   defaultValue: 0,
  // );

  final LibraryFragmentMode currentFragment = ref
      .watch(settingsProvider.select((settings) => settings.libraryFragment));

  return currentFragment;
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
      title: state == LibraryFragmentMode.manga
          ? const Text('Манга и ранобе')
          : const Text('Аниме'),
      actions: [
        // IconButton(
        //   onPressed: () {},
        //   icon: const Icon(Icons.notifications),
        // ),
        GestureDetector(
          onTap: () => showLibraryPopUp(context),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundImage: CachedNetworkImageProvider(
              SecureStorageService.instance.userProfileImage,
              cacheManager: cacheManager,
            ),
          ),
        ),
        // PopupMenuButton<LibraryState>(
        //   tooltip: 'Выбор списка',
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   //initialValue: state,
        //   color: Theme.of(context).colorScheme.onInverseSurface,
        //   itemBuilder: (context) => const [
        //     PopupMenuItem(
        //       value: LibraryState.anime,
        //       child: Text('Аниме'),
        //     ),
        //     PopupMenuItem(
        //       value: LibraryState.manga,
        //       child: Text('Манга и ранобе'),
        //     ),
        //   ],
        //   onSelected: (value) {
        //     ref.read(libraryStateProvider.notifier).state = value;
        //   },
        //   child: CircleAvatar(
        //     backgroundColor: Colors.transparent,
        //     foregroundImage: CachedNetworkImageProvider(
        //       SecureStorageService.instance.userProfileImage,
        //       cacheManager: cacheManager,
        //     ),
        //   ),
        // ),
        const SizedBox(
          width: 16,
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
        tabs: state == LibraryFragmentMode.manga
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

  showLibraryPopUp(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => const LibraryPopUp(),
    );
  }
}

class LibraryPopUp extends ConsumerWidget {
  const LibraryPopUp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryStateProvider);

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Padding(
      padding: isPortrait
          ? MediaQuery.of(context)
              .viewInsets
              .copyWith(top: kToolbarHeight + 16.0, left: 16.0, right: 16.0)
          : const EdgeInsets.all(0.0),
      child: FractionallySizedBox(
        alignment: Alignment.topCenter,
        heightFactor: isPortrait ? 0.5 : 1.0,
        widthFactor: isPortrait ? 1 : 0.6,
        child: Material(
          color: Theme.of(context).colorScheme.background,
          //surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          shadowColor: Colors.transparent,
          elevation: 0,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.hardEdge,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // IconButton(
                //   onPressed: () => Navigator.pop(context),
                //   icon: const Icon(Icons.close),
                //   tooltip: 'Закрыть',
                // ),
                Card(
                  margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  //color: Theme.of(context).colorScheme.background,
                  //elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      foregroundImage: CachedNetworkImageProvider(
                        SecureStorageService.instance.userProfileImage,
                        cacheManager: cacheManager,
                      ),
                    ),
                    title: Text(
                      SecureStorageService.instance.userNickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'id: ${SecureStorageService.instance.userId}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  //color: Theme.of(context).colorScheme.background,
                  //elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<LibraryFragmentMode>(
                        title: const Text(
                          'Аниме',
                        ),
                        value: LibraryFragmentMode.anime,
                        groupValue: state,
                        onChanged: (value) {
                          ref.read(libraryStateProvider.notifier).state =
                              LibraryFragmentMode.anime;
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile<LibraryFragmentMode>(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        title: const Text(
                          'Манга и ранобе',
                        ),
                        value: LibraryFragmentMode.manga,
                        groupValue: state,
                        onChanged: (value) {
                          ref.read(libraryStateProvider.notifier).state =
                              LibraryFragmentMode.manga;
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(curve: Curves.easeInOut).scale(
          alignment: const Alignment(1, -1),
          //duration: 3.seconds,
          begin: const Offset(.5, 0.2),
          curve: Curves.easeOutCubic,
        );
  }
}
