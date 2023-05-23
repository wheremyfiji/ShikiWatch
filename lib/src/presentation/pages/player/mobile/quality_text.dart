import 'package:flutter/material.dart';

class QualityButton extends StatelessWidget {
  final int streamQuality;
  //final int initialValue;
  final Function(int) onSelected;

  const QualityButton({
    super.key,
    required this.streamQuality,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      initialValue: streamQuality,
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        const PopupMenuItem<int>(
          value: 0,
          child: Text('720p'),
        ),
        const PopupMenuItem<int>(
          value: 1,
          child: Text('480p'),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text('360p'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: QualityTextWidget(
          quality: streamQuality,
        ),
      ),
    );
  }
}

class QualityTextWidget extends StatelessWidget {
  final int quality;
  const QualityTextWidget({super.key, required this.quality});

  String getString(int value) {
    String str;

    const map = {0: '720p', 1: '480p', 2: '360p'};

    str = map[value] ?? 'N/A';

    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          getString(quality),
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
    );
  }
}
