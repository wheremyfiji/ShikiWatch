import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/extensions/duration.dart';
import '../../../hooks/use_now_timer.dart';

class TitleNextEpisode extends HookWidget {
  const TitleNextEpisode({
    super.key,
    required this.episodesAired,
    required this.nextEpisodeAt,
  });

  final int episodesAired;
  final DateTime nextEpisodeAt;

  @override
  Widget build(BuildContext context) {
    final now = useNowTimer();

    final difference = nextEpisodeAt.difference(now);
    final isReleased = difference.isNegative;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isReleased
              ? 'Эпизод ${episodesAired + 1} уже вышел'
              : 'Эпизод ${episodesAired + 1} выйдет через ${difference.toHumanReadable}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
        Text(
          DateFormat.MMMMEEEEd().format(nextEpisodeAt),
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: 14,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
