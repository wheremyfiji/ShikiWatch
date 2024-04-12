import 'package:flutter/material.dart';

import '../../../../domain/enums/stream_quality.dart';
import '../domain/playable_content.dart';

class QualityPopUpMenu extends StatelessWidget {
  const QualityPopUpMenu({
    super.key,
    required this.playableContent,
    required this.selectedQuality,
    required this.onSelected,
    required this.onOpened,
    required this.onCanceled,
  });

  final PlayableContent playableContent;
  final StreamQuality selectedQuality;
  final void Function(StreamQuality) onSelected;
  final void Function() onOpened;
  final void Function() onCanceled;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<StreamQuality>(
      tooltip: 'Качество',
      initialValue: selectedQuality,
      itemBuilder: (context) {
        return [
          if (playableContent.fourK != null)
            const PopupMenuItem<StreamQuality>(
              value: StreamQuality.fourK,
              child: Text('2160p'),
            ),
          if (playableContent.fhd != null)
            const PopupMenuItem<StreamQuality>(
              value: StreamQuality.fhd,
              child: Text('1080p'),
            ),
          if (playableContent.hd != null)
            const PopupMenuItem<StreamQuality>(
              value: StreamQuality.hd,
              child: Text('720p'),
            ),
          if (playableContent.sd != null)
            const PopupMenuItem<StreamQuality>(
              value: StreamQuality.sd,
              child: Text('480p'),
            ),
          if (playableContent.low != null)
            const PopupMenuItem<StreamQuality>(
              value: StreamQuality.low,
              child: Text('360p'),
            ),
        ];
      },
      onOpened: onOpened,
      onCanceled: onCanceled,
      // onSelected: (q) {
      //   print('object 3');
      //   onSelected(q);
      // },
      onSelected: onSelected,

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedQuality.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(
            width: 4,
          ),
          const Icon(Icons.expand_more)
        ],
      ),
    );
  }
}
