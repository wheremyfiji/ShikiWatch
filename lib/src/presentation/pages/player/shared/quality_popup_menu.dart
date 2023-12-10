import 'package:flutter/material.dart';

import '../../../../domain/enums/stream_quality.dart';

import 'shared.dart';

class QualityPopUpMenu extends StatelessWidget {
  final VideoLinks videoLinks;
  final StreamQuality selectedQuality;
  final void Function(StreamQuality) onSelected;
  final void Function() onOpened;
  final void Function() onCanceled;

  const QualityPopUpMenu({
    super.key,
    required this.videoLinks,
    required this.selectedQuality,
    required this.onSelected,
    required this.onOpened,
    required this.onCanceled,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<StreamQuality>(
      tooltip: 'Качество',
      initialValue: selectedQuality,
      itemBuilder: (context) {
        return [
          if (videoLinks.fhd != null)
            const PopupMenuItem<StreamQuality>(
              value: StreamQuality.fhd,
              child: Text('1080p'),
            ),
          if (videoLinks.hd != null)
            const PopupMenuItem<StreamQuality>(
              value: StreamQuality.hd,
              child: Text('720p'),
            ),
          if (videoLinks.sd != null)
            const PopupMenuItem<StreamQuality>(
              value: StreamQuality.sd,
              child: Text('480p'),
            ),
          if (videoLinks.low != null)
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
