import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/enums/stream_quality.dart';
import '../../../providers/anime_player_provider.dart';

const List<double> _examplePlaybackRates = <double>[
  0.25,
  0.5,
  //0.75,
  1.0,
  1.25,
  1.5,
  //1.75,
  2.0,
];

class PlayerHeader extends StatelessWidget {
  final String animeName;
  final int episodeNumber;
  final String studioName;
  final bool isInit;
  final double playbackSpeed;
  final Function(double) onSelectedSpeed;
  final Widget qualityChild;

  const PlayerHeader({
    super.key,
    required this.animeName,
    required this.episodeNumber,
    required this.studioName,
    required this.isInit,
    required this.playbackSpeed,
    required this.onSelectedSpeed,
    required this.qualityChild,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          tooltip: 'Назад',
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                animeName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 4.0,
              ),
              Text(
                'Серия $episodeNumber • $studioName',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 16.0,
        ),
        if (isInit) ...[
          PlayerSpeedPopUp(
            playbackSpeed: playbackSpeed,
            onSelected: onSelectedSpeed,
          ),
          qualityChild,
        ],
      ],
    );
  }
}

class PlayerSpeedPopUp extends StatelessWidget {
  final double playbackSpeed;
  final Function(double) onSelected;

  const PlayerSpeedPopUp({
    super.key,
    required this.playbackSpeed,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      initialValue: playbackSpeed,
      tooltip: 'Скорость воспроизведения',
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<double>>[
          for (final double speed in _examplePlaybackRates)
            PopupMenuItem<double>(
              value: speed,
              child: Text('${speed}x'),
            )
        ];
      },
      child: Padding(
        // padding: const EdgeInsets.symmetric(
        //   vertical: 12,
        //   horizontal: 16,
        // ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          '${playbackSpeed}x',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}

class QualityPopUpMenu extends ConsumerWidget {
  final PlayerProviderParameters p;

  const QualityPopUpMenu(this.p, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(playerControllerProvider(p));

    return PopupMenuButton<StreamQuality>(
      initialValue: c.selectedQuality,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            c.selectedQuality.name,
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
      itemBuilder: (context) {
        return [
          if (c.streamFhd != null)
            const PopupMenuItem<StreamQuality>(
              value: StreamQuality.fhd,
              child: Text('1080p'),
            ),
          if (c.streamHd != null)
            const PopupMenuItem<StreamQuality>(
              value: StreamQuality.hd,
              child: Text('720p'),
            ),
          if (c.streamSd != null)
            const PopupMenuItem<StreamQuality>(
              value: StreamQuality.sd,
              child: Text('480p'),
            ),
          if (c.streamLow != null)
            const PopupMenuItem<StreamQuality>(
              value: StreamQuality.low,
              child: Text('360p'),
            ),
        ];
      },
      onSelected: (value) {
        c.selectedQuality = value;
        c.changeStreamQuality(value);
      },
    );
  }
}

// class QualityButton extends StatelessWidget {
//   final int streamQuality;
//   //final int initialValue;
//   final Function(int) onSelected;

//   const QualityButton({
//     super.key,
//     required this.streamQuality,
//     required this.onSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<int>(
//       initialValue: streamQuality,
//       onSelected: onSelected,
//       itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
//         const PopupMenuItem<int>(
//           value: 0,
//           child: Text('720p'),
//         ),
//         const PopupMenuItem<int>(
//           value: 1,
//           child: Text('480p'),
//         ),
//         const PopupMenuItem<int>(
//           value: 2,
//           child: Text('360p'),
//         ),
//       ],
//       child: Padding(
//         padding: const EdgeInsets.all(0),
//         child: QualityTextWidget(
//           quality: streamQuality,
//         ),
//       ),
//     );
//   }
// }

// class QualityTextWidget extends StatelessWidget {
//   final int quality;
//   const QualityTextWidget({super.key, required this.quality});

//   String getString(int value) {
//     String str;

//     const map = {0: '720p', 1: '480p', 2: '360p'};

//     str = map[value] ?? 'N/A';

//     return str;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           getString(quality),
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 14,
//           ),
//           overflow: TextOverflow.ellipsis,
//           maxLines: 1,
//         ),
//         const SizedBox(
//           width: 4,
//         ),
//         const Icon(Icons.expand_more)
//       ],
//     );
//   }
// }
