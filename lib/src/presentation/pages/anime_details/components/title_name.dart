import 'package:flutter/material.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/anime_details_provider.dart';
import '../../../widgets/custom_info_chip.dart';

class TitleName extends StatelessWidget {
  final int animeId;
  final String title;
  final String? subTitle;
  final String rating;
  final String? score;
  final bool tap;

  const TitleName({
    super.key,
    required this.animeId,
    required this.title,
    required this.subTitle,
    required this.rating,
    required this.score,
    this.tap = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 16),
      child: InkWell(
        onTap: tap ? () => _showSheet(context) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subTitle != null)
                      Text(
                        subTitle!,
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: context.colorScheme.onBackground.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                    if (score != null && score != '0.0')
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: RatingBarIndicator(
                              rating: (double.tryParse(score!) ?? 0.0) / 2,
                              itemSize: 16,
                              itemCount: 5,
                              itemBuilder: (context, index) => Icon(
                                Icons.star_rounded,
                                color: context.isDarkThemed
                                    ? Colors.amber.shade200
                                    : Colors.amber.shade600,
                              ),
                            ),
                          ),
                          Text(
                            score!,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  context.colorScheme.onBackground.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (rating != '?')
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: CustomInfoChip(
                    title: rating,
                    elevation: false,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _showSheet(BuildContext c) {
    showModalBottomSheet<void>(
      context: c,
      builder: (context) => _AnimeOtherNames(animeId),
      useRootNavigator: true,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(c).size.width >= 700 ? 700 : double.infinity,
      ),
    );
  }
}

class _AnimeOtherNames extends ConsumerWidget {
  final int animeId;

  const _AnimeOtherNames(
    this.animeId, {
    // ignore: unused_element
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anime = ref
        .watch(titleInfoPageProvider(animeId))
        .title
        .whenOrNull(data: (data) => data);

    if (anime == null) {
      return const SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (anime.english != null && anime.english!.isNotEmpty) ...[
              // const Text(
              //   'English',
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(
              //   height: 2,
              // ),
              // ...List.generate(anime.english!.length,
              //     ((index) => SelectableText(anime.english![index]))),

              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'English:\n',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: anime.english!.join('\n')),
                  ],
                ),
              ),
              const Divider(),
            ],
            if (anime.japanese != null && anime.japanese!.isNotEmpty) ...[
              // const Text(
              //   'Japanese',
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(
              //   height: 2,
              // ),
              // ...List.generate(anime.japanese!.length,
              //     ((index) => SelectableText(anime.japanese![index]))),

              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Japanese:\n',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: anime.japanese!.join('\n')),
                  ],
                ),
              ),
            ],
            if (anime.synonyms != null && anime.synonyms!.isNotEmpty) ...[
              const Divider(),
              // const Text(
              //   'Синонимы',
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(
              //   height: 2,
              // ),
              // ...List.generate(anime.synonyms!.length,
              //     ((index) => SelectableText(anime.synonyms![index]))),

              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Синонимы:\n',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: anime.synonyms!.join('\n')),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
