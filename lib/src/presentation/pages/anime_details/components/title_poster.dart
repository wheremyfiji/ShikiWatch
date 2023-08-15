import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../constants/config.dart';
import '../../../widgets/cached_image.dart';

class TitlePoster extends StatelessWidget {
  final String imageUrl;

  const TitlePoster(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 316,
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: '${AppConfig.staticUrl}$imageUrl',
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
              color: Theme.of(context).colorScheme.background.withOpacity(0.8),
            ),
          ),
          Positioned.fill(
            top: -1,
            bottom: -1,
            left: -1,
            right: -1,
            child: Container(
              //clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.background,
                    Theme.of(context).colorScheme.background.withOpacity(0.2),
                    Theme.of(context).colorScheme.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [
                    0.1,
                    0.4,
                    0.8,
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 300,
                child: AspectRatio(
                  aspectRatio: 0.703,
                  child: CachedImage(
                    '${AppConfig.staticUrl}$imageUrl',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
