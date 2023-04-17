import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
//import 'package:cached_network_image/cached_network_image.dart';

class ImageWithShimmerWidget extends StatelessWidget {
  const ImageWithShimmerWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      cache: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surface,
              highlightColor: Theme.of(context).colorScheme.onInverseSurface,
              child: Container(
                color: Colors.black,
              ),
            );

          // return Shimmer(
          //   gradient: LinearGradient(
          //     begin: Alignment.centerLeft,
          //     end: Alignment.centerRight,
          //     colors: [
          //       Theme.of(context).colorScheme.onInverseSurface.withOpacity(0),
          //       Theme.of(context)
          //           .colorScheme
          //           .onInverseSurface
          //           .withOpacity(0.5),
          //       Theme.of(context).colorScheme.onInverseSurface.withOpacity(0),
          //       //context.colorScheme.primary.withOpacity(0),
          //       // context.colorScheme.primary.withOpacity(0.5),
          //       // context.colorScheme.primary.withOpacity(0),
          //     ],
          //     stops: const <double>[
          //       0.35,
          //       0.5,
          //       0.65,
          //     ],
          //   ),
          //   //period: const Duration(milliseconds: 700),
          //   child: const LinearProgressIndicator(
          //     value: 0,
          //     minHeight: 16,
          //   ),
          // );
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            return const Icon(Icons.error);
        }
        //return null;
      },
    );
    // CachedNetworkImage(
    //   imageUrl: imageUrl,
    //   placeholder: (context, url) {
    //     return Shimmer.fromColors(
    //       baseColor: Theme.of(context).colorScheme.surface,
    //       highlightColor: Theme.of(context).colorScheme.onInverseSurface,
    //       child: Container(
    //         color: Colors.black,
    //       ),
    //     );
    //   },
    //   errorWidget: (context, url, error) => const Icon(Icons.error),
    //   fit: BoxFit.cover,
    //   width: width,
    //   height: height,
    // );
  }
}
