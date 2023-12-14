import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/pages_extra.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/image_with_shimmer.dart';
import 'library_anime_search_controller.dart';

class LibraryAnimeSearchPage extends ConsumerWidget {
  const LibraryAnimeSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(libraryAnimeSearchProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              pinned: true,
              title: TextField(
                autofocus: true,
                controller: provider.fieldController,
                onChanged: provider.onSearchChanged,
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  //contentPadding: EdgeInsets.zero,
                  hintText: 'Поиск аниме',
                  suffixIcon: provider.fieldController.text.isNotEmpty
                      ? GestureDetector(
                          child: const Icon(Icons.close),
                          onTap: () => provider.clearQuery(),
                        )
                      : null,
                ),
              ),
              bottom: AppBar(
                automaticallyImplyLeading: false,
                primary: false,
                titleSpacing: 0,
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: [
                      const SizedBox(
                        width: 8.0,
                      ),
                      ...LibrarySearchType.values.map(
                        (e) => ChoiceChip(
                          label: Text(e.rusName),
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          selected: e == provider.searchType,
                          onSelected: (value) => ref
                              .read(libraryAnimeSearchProvider)
                              .setSearchType(e),
                        ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Divider(
                height: 1,
              ),
            ),
            ...provider.result.when(
              data: (data) {
                if (data.isEmpty &&
                    provider.fieldController.value.text.isNotEmpty) {
                  return [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 16),
                    ),
                    const SliverToBoxAdapter(
                      child: _NothingFound(),
                    ),
                  ];
                }

                return [
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  SliverList.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      final lastElement = index == (data.length - 1);

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          lastElement ? 16 : 8,
                        ),
                        child: _SearchAnimeItem(item),
                      );
                    },
                  ),
                ];
              },
              error: (e, _) => [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                SliverToBoxAdapter(
                  child: _SearchError(
                    e.toString(),
                    onRetry: () {
                      provider.fetch(provider.fieldController.value.text);
                    },
                  ),
                ),
              ],
              loading: () => [
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAnimeItem extends StatelessWidget {
  final GraphqlSearch anime;

  const _SearchAnimeItem(this.anime);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();

          final extra = AnimeDetailsPageExtra(
            id: anime.id,
            label: (anime.russian == '' ? anime.name : anime.russian) ?? '',
          );

          context.pushNamed(
            'library_anime',
            pathParameters: <String, String>{
              'id': (anime.id).toString(),
            },
            extra: extra,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: AspectRatio(
                aspectRatio: 0.703,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: ImageWithShimmerWidget(
                    imageUrl: anime.poster?.mainAltUrl ?? '',
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (anime.russian == '' ? anime.name : anime.russian) ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 8,
                      children: [
                        _RateStatusChip(anime.userRate.status),
                        if (anime.userRate.status != RateStatus.planned &&
                            anime.userRate.status != RateStatus.completed)
                          Card(
                            margin: const EdgeInsets.all(0.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            color: context.colorScheme.secondaryContainer,
                            elevation: 0.0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                                horizontal: 4.0,
                              ),
                              child: Text(
                                'Эпизоды: ${anime.userRate.episodes}',
                                maxLines: 1,
                                style: TextStyle(
                                  color: context.colorScheme.onBackground,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        // CustomInfoChip(
                        //   title: 'Эпизоды: ${anime.userRate.episodes}',
                        // ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateStatusChip extends StatelessWidget {
  final RateStatus status;

  const _RateStatusChip(this.status);

  Color getColor({required RateStatus status, required bool dark}) {
    return switch (status) {
      RateStatus.planned =>
        dark ? Colors.yellow.shade400 : Colors.yellow.shade300,
      RateStatus.watching =>
        dark ? Colors.deepPurple.shade400 : Colors.deepPurple.shade300,
      RateStatus.rewatching =>
        dark ? Colors.deepPurple.shade400 : Colors.deepPurple.shade300,
      RateStatus.completed =>
        dark ? Colors.green.shade400 : Colors.green.shade300,
      RateStatus.onHold =>
        dark ? Colors.lightBlue.shade400 : Colors.lightBlue.shade300,
      RateStatus.dropped => dark ? Colors.red.shade400 : Colors.red.shade300,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor(status: status, dark: context.isDarkThemed);

    return Card(
      margin: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: color.withOpacity(0.5),
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        child: Text(
          status.rusName,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const _SearchError(
    this.error, {
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '(´･ω･`)?',
            textAlign: TextAlign.center,
            style: context.textTheme.displaySmall,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
            child: Text(
              'Ой, ошибка..',
              style: context.textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              error,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onBackground.withOpacity(
                  0.8,
                ),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}

class _NothingFound extends StatelessWidget {
  const _NothingFound();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '(˘･_･˘)',
            textAlign: TextAlign.center,
            style: context.textTheme.displaySmall,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
            child: Text(
              'Ничего не найдено',
              style: context.textTheme.titleLarge,
            ),
          ),
          Text(
            'Измени список или воспользуйся глобальным поиском',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onBackground.withOpacity(
                0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
