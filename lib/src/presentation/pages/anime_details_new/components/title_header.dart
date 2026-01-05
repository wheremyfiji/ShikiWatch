import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/enums/shiki_gql.dart';
import '../../../widgets/cached_image.dart';
import '../graphql_anime.dart';

class TitleHeader extends StatelessWidget {
  const TitleHeader(
    this.title, {
    super.key,
    required this.useRowLayout,
  });

  final GraphqlAnime title;
  final bool useRowLayout;

  @override
  Widget build(BuildContext context) {
    final avgScore = _getAverageRating(title.scoresStats);

    if (useRowLayout) {
      return Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: title.poster.originalUrl ?? '',
              fit: BoxFit.cover,
              cacheManager: cacheManager,
            ),
          ),
          Positioned.fill(
            top: -1,
            bottom: -1,
            left: -1,
            right: -1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colorScheme.background,
                    context.colorScheme.background.withOpacity(0.9),
                    context.colorScheme.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [
                    0.0,
                    0.4,
                    1.0,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, context.padding.top + 56, 16, 0),
            child: Row(
              children: [
                // flex 5
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: 0.703,
                    child: CachedImage(
                      title.poster.originalUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title.score != 0) ...[
                        _Score(
                          title.score,
                          avgScore: avgScore,
                          padding: false,
                        ),
                      ],
                      Text(
                        title.russian ?? title.name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.headlineSmall?.copyWith(
                          height: 1.2,
                          fontWeight: FontWeight.normal,
                          color: context.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _Info(
                        kind: title.kind.rusName,
                        status: title.status.rusName,
                        season: _parseSeason(title.season),
                        eps: _eps(
                          aired: title.episodesAired,
                          total: title.episodes,
                          titleStatus: title.status,
                        ),
                        rating: title.rating.name,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fade(),
        ],
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: CachedImage(
            title.poster.originalUrl ?? '',
            placeholder: (context, url) {
              return const SizedBox.shrink();
            },
          ),
        ),
        const _TopShadow(),
        const _BottomShadow(),
        Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.score != 0)
                _Score(
                  title.score,
                  avgScore: avgScore,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Text(
                  title.russian ?? title.name,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.headlineSmall?.copyWith(
                    height: 1.2,
                    fontWeight: FontWeight.normal,
                    color: context.colorScheme.onBackground,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 0, 0),
                child: _Info(
                  kind: title.kind.rusName,
                  status: title.status.rusName,
                  season: _parseSeason(title.season),
                  eps: _eps(
                    aired: title.episodesAired,
                    total: title.episodes,
                    titleStatus: title.status,
                  ),
                  rating: title.rating.name,
                ),
              ),
            ],
          ).animate().fade(),
        ),
      ],
    );
  }

  static double? _getAverageRating(List<GraphqlScoreStat> stats) {
    if (stats.isEmpty) return null;

    final totalScoreSum =
        stats.fold(0, (sum, item) => sum + (item.score * item.count));

    final totalVotes = stats.fold(0, (sum, item) => sum + item.count);

    if (totalVotes == 0) return null;

    final average = totalScoreSum / totalVotes;

    return double.parse(average.toStringAsFixed(2));
  }

  static String _parseSeason(String value) {
    List<String> splitted = value.split('_');

    const map = {
      'winter': 'Зима',
      'spring': 'Весна',
      'summer': 'Лето',
      'fall': 'Осень',
    };

    try {
      return '${map[splitted[0]]} ${splitted[1]}';
    } catch (e) {
      return value;
    }
  }

  static String _eps({
    required int aired,
    required int total,
    required AnimeStatus titleStatus,
  }) {
    if (aired == 0 && total == 0) {
      return '? эп.';
    }

    if (titleStatus == AnimeStatus.released) {
      return '$total эп.';
    }

    if (aired == 0 || aired == total) {
      return '$total эп.';
    }

    return '$aired из ${total == 0 ? '?' : total} эп.';
  }
}

class _TopShadow extends StatelessWidget {
  const _TopShadow();

  @override
  Widget build(BuildContext context) {
    final tint = context.theme.scaffoldBackgroundColor;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: SizedBox(
          height: context.mediaQuery.padding.top * 1.8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomLeft,
                colors: [
                  tint.withOpacity(0.8),
                  //const Color(0x00000000),
                  tint.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomShadow extends StatelessWidget {
  const _BottomShadow();

  @override
  Widget build(BuildContext context) {
    final tint = context.theme.scaffoldBackgroundColor;
    return Positioned.fill(
      top: -1,
      bottom: -1,
      left: -1,
      right: -1,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0x00000000),
                tint,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [
                0.0,
                0.92,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score(
    this.score, {
    // ignore: unused_element
    this.avgScore,
    this.padding = true,
  });

  final double score;
  final double? avgScore;
  final bool padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: padding ? const EdgeInsets.only(left: 14) : EdgeInsets.zero,
          child: RatingBarIndicator(
            rating: (score) / 2,
            itemSize: 16,
            itemCount: 5,
            itemBuilder: (context, index) => Icon(
              Icons.star_rounded,
              color: context.colorScheme.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 1),
          child: Text(
            score.toString(),
            style: TextStyle(
              fontSize: 12,
              height: 1,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (avgScore != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 1),
            child: Text(
              '($avgScore)',
              style: TextStyle(
                fontSize: 12,
                height: 1,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.kind,
    required this.status,
    required this.eps,
    required this.season,
    required this.rating,
  });

  final String kind;
  final String status;
  final String eps;
  final String season;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 12,
        children: [
          _InfoItem(
            title: 'Тип',
            content: '$kind • $status',
          ),
          if (season != '?')
            _InfoItem(
              title: 'Сезон',
              content: season,
            ),
          _InfoItem(
            title: 'Эпизоды',
            content: eps,
          ),
          if (rating.isNotEmpty)
            _InfoItem(
              title: 'Рейтинг',
              content: rating,
            ),
          const SizedBox(
            width: 4,
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String content;

  const _InfoItem({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
            letterSpacing: 2,
            wordSpacing: 1,
          ),
        ),
        Text(
          content,
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: 14,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
