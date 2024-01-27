import 'package:flutter/material.dart';

import '../../../../../constants/config.dart';
import '../../../../widgets/cached_image.dart';

class PlayerInfoHeader extends StatelessWidget {
  final String animeName;
  final String animePicture;
  final int episodeNumber;
  final String studioName;
  final Widget skipButton;
  final VoidCallback? onPressed;

  const PlayerInfoHeader({
    super.key,
    required this.animeName,
    required this.animePicture,
    required this.episodeNumber,
    required this.studioName,
    required this.skipButton,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: CachedImage(
            AppConfig.staticUrl + animePicture,
            height: 100,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              animeName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              'Серия $episodeNumber • $studioName',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        const Spacer(),
        skipButton,
        // IconButton(
        //   tooltip: 'Перемотать 125 секунд',
        //   iconSize: 32,
        //   color: Colors.white,
        //   onPressed: onPressed,
        //   icon: const Icon(Icons.double_arrow_rounded),
        // ),
      ],
    );
  }
}
