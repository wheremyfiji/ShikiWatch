import 'package:flutter/material.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/custom_info_chip.dart';

class TitleName extends StatelessWidget {
  final int animeId;
  final String title;
  final String? subTitle;
  final String rating;
  final String? score;
  final List<String>? english;
  final List<String>? japanese;
  final List<String>? synonyms;

  const TitleName({
    super.key,
    required this.animeId,
    required this.title,
    required this.subTitle,
    required this.rating,
    required this.score,
    required this.english,
    required this.japanese,
    required this.synonyms,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 16),
      child: InkWell(
        onTap: () => TitleOtherNamesBottomSheet.show(
          context,
          english: english,
          japanese: japanese,
          synonyms: synonyms,
        ),
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
}

class TitleOtherNamesBottomSheet extends StatelessWidget {
  final List<String>? english;
  final List<String>? japanese;
  final List<String>? synonyms;

  const TitleOtherNamesBottomSheet({
    super.key,
    required this.english,
    required this.japanese,
    required this.synonyms,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (english != null && english!.isNotEmpty) ...[
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
                  TextSpan(text: english!.join('\n')),
                ],
              ),
            ),
            const Divider(),
          ],
          if (japanese != null && japanese!.isNotEmpty) ...[
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
                  TextSpan(text: japanese!.join('\n')),
                ],
              ),
            ),
          ],
          if (synonyms != null && synonyms!.isNotEmpty) ...[
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
                  TextSpan(text: synonyms!.join('\n')),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required List<String>? english,
    required List<String>? japanese,
    required List<String>? synonyms,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: context.mediaQuery.size.width >= 700 ? 700 : double.infinity,
      ),
      builder: (_) => SafeArea(
        child: TitleOtherNamesBottomSheet(
          english: english,
          japanese: japanese,
          synonyms: synonyms,
        ),
      ),
    );
  }
}
