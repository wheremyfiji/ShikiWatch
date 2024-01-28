import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/cached_image.dart';
import '../../../../constants/config.dart';

class TitlePoster extends HookWidget {
  final String imageUrl;

  const TitlePoster(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    final expand = useState(false);

    //final heroKey = UniqueKey();

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
        // Positioned.fill(
        //   top: -1,
        //   bottom: -1,
        //   left: -1,
        //   right: -1,
        //   child: BackdropFilter(
        //     filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        //     child: Container(
        //       color: context.colorScheme.background.withOpacity(0.8),
        //     ),
        //   ),
        // ),
        // Positioned.fill(
        //   top: -1,
        //   bottom: -1,
        //   left: -1,
        //   right: -1,
        //   child: Container(
        //     color: context.colorScheme.background.withOpacity(0.8),
        //     //color: Colors.black.withOpacity(0.6),
        //   ),
        // ),
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
                  context.colorScheme.background.withOpacity(0.84),
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
        Align(
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => expand.value = !expand.value, // onDoubleTap ?
            // onTap: () {
            //   Navigator.of(context, rootNavigator: true).push(
            //     HeroDialogRoute(
            //       builder: (ctx) => InteractiveviewerGallery(
            //         sources: ['${AppConfig.staticUrl}$imageUrl'],
            //         initIndex: 0,
            //         maxScale: 3.0,
            //         itemBuilder: (context, imageIndex, isFocus) {
            //           return Center(
            //             child: Hero(
            //               tag: heroKey,
            //               child: CachedImage(
            //                 '${AppConfig.staticUrl}$imageUrl',
            //                 fadeOutDuration: const Duration(milliseconds: 200),
            //                 placeholder: (context, url) =>
            //                     const CircularProgressIndicator(),
            //               ),
            //             ),
            //           );
            //         },
            //       ),
            //     ),
            //   );
            // },
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
  }
}
