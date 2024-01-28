import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/pages_extra.dart';
import '../../../domain/models/shiki_franchise.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../providers/anime_details_provider.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';

class AnimeFranchisePage extends ConsumerWidget {
  final int animeId;

  const AnimeFranchisePage(this.animeId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final franchise = ref.watch(animeFranchiseProvider(animeId));

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Хронология'),
            ),
            franchise.when(
              data: (data) {
                final franchiseItems = data.nodes;

                if (franchiseItems == null || franchiseItems.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'Σ(ಠ_ಠ)',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.displayMedium,
                              ),
                            ),
                            const Flexible(
                              child: Text(
                                'Ничего не найдено',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList.builder(
                  itemBuilder: (context, index) {
                    final item = franchiseItems[index];

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: FranchiseListItem(
                        item,
                        currentId: data.currentId ?? animeId,
                      ),
                    );
                  },
                  itemCount: franchiseItems.length,
                );
              },
              error: (e, _) => SliverFillRemaining(
                child: CustomErrorWidget(
                  e.toString(),
                  () => ref.refresh(animeFranchiseProvider(animeId)),
                ),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FranchiseListItem extends StatelessWidget {
  final FranchiseNode item;
  final int currentId;

  const FranchiseListItem(
    this.item, {
    super.key,
    required this.currentId,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: item.id == currentId || item.id == null || item.id == 0
            ? null
            : () {
                final extra = TitleDetailsPageExtra(
                  id: item.id!,
                  label: item.name ?? '[Без названия]',
                );

                context.pushNamed(
                  'library_anime',
                  pathParameters: <String, String>{
                    'id': item.id.toString(),
                  },
                  extra: extra,
                );
              },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 100, //120
                child: AspectRatio(
                  aspectRatio: 0.703,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedImage(
                      item.imageUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? '[Без названия]',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${item.kind ?? '?'} • ${item.year ?? '?'} год',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                  if (item.id == currentId)
                    Chip(
                      padding: const EdgeInsets.all(0.0),
                      shadowColor: Colors.transparent,
                      elevation: 0.0,
                      side: const BorderSide(
                        width: 0.0,
                        color: Colors.transparent,
                      ),
                      labelStyle: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onTertiaryContainer,
                      ),
                      backgroundColor: context.colorScheme.tertiaryContainer,
                      label: const Text('Вы здесь'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
