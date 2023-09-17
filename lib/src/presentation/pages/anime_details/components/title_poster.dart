import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../constants/config.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/cached_image.dart';

class TitlePoster extends HookWidget {
  final String imageUrl;

  const TitlePoster(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    final expand = useState(false);

    final imageMaxWidth =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width - 32.0
            : 400.0;

    return Stack(
      clipBehavior: Clip.hardEdge,
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
            color: context.colorScheme.background.withOpacity(0.8),
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
                  context.colorScheme.background,
                  context.colorScheme.background.withOpacity(0.2),
                  context.colorScheme.background,
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
          child: GestureDetector(
            onTap: () => expand.value = !expand.value, // onDoubleTap ?
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastEaseInToSlowEaseOut,
              width: expand.value ? imageMaxWidth : 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(expand.value ? 0 : 16),
              ),
              clipBehavior: Clip.hardEdge,
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
    );

    // return SizedBox(
    //   height: 316,
    //   child: Stack(
    //     children: [
    //       Positioned.fill(
    //         child: CachedNetworkImage(
    //           imageUrl: '${AppConfig.staticUrl}$imageUrl',
    //           fit: BoxFit.cover,
    //           cacheManager: cacheManager,
    //         ),
    //       ),
    //       Positioned.fill(
    //         top: -1,
    //         bottom: -1,
    //         left: -1,
    //         right: -1,
    //         child: Container(
    //           color: context.colorScheme.background.withOpacity(0.8),
    //         ),
    //       ),
    //       Positioned.fill(
    //         top: -1,
    //         bottom: -1,
    //         left: -1,
    //         right: -1,
    //         child: Container(
    //           //clipBehavior: Clip.hardEdge,
    //           decoration: BoxDecoration(
    //             gradient: LinearGradient(
    //               colors: [
    //                 context.colorScheme.background,
    //                 context.colorScheme.background.withOpacity(0.2),
    //                 context.colorScheme.background,
    //               ],
    //               begin: Alignment.topCenter,
    //               end: Alignment.bottomCenter,
    //               stops: const [
    //                 0.1,
    //                 0.4,
    //                 0.8,
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //       Align(
    //         alignment: Alignment.center,
    //         child: ClipRRect(
    //           borderRadius: BorderRadius.circular(16),
    //           child: SizedBox(
    //             height: 300,
    //             child: AspectRatio(
    //               aspectRatio: 0.703,
    //               child: CachedImage(
    //                 '${AppConfig.staticUrl}$imageUrl',
    //                 fit: BoxFit.cover,
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
