import 'package:flutter/material.dart';

import 'quality_text.dart';

class PlayerHeader extends StatelessWidget {
  final String animeName;
  final int episodeNumber;
  final String studioName;
  final int streamQuality;
  final Function(int) onQualitySelect;

  const PlayerHeader({
    super.key,
    required this.animeName,
    required this.episodeNumber,
    required this.studioName,
    required this.streamQuality,
    required this.onQualitySelect,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), //15 kToolbarHeight
        child: ListTile(
          leading: const BackButton(
            color: Colors.white,
          ),
          title: Text(
            animeName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(
            'Серия $episodeNumber • $studioName',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: QualityButton(
            streamQuality: streamQuality,
            onSelected: onQualitySelect,
          ),
        ),
      ),
    );
  }
}
