import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'cached_image.dart';
import 'custom_shimmer.dart';

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
    return CachedNetworkImage(
      imageUrl: imageUrl,
      // placeholder: (context, url) {
      //   return Shimmer.fromColors(
      //     baseColor: Theme.of(context).colorScheme.surfaceVariant,
      //     highlightColor: Theme.of(context).colorScheme.onInverseSurface,
      //     child: Container(
      //       color: Colors.black,
      //     ),
      //   );
      // },
      placeholder: (context, url) => const CustomShimmer(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: fit,
      width: width,
      height: height,
      cacheManager: cacheManager,
    );
  }
}
