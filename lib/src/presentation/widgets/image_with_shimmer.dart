import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../utils/extensions/buildcontext.dart';
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
      placeholder: (context, url) => const CustomShimmer(),
      errorWidget: (context, url, error) {
        return Container(
          color: context.colorScheme.secondaryContainer,
          child: Icon(
            Icons.broken_image_rounded,
            color: context.colorScheme.onSecondaryContainer,
          ),
        );
      },
      fit: fit,
      width: width,
      height: height,
      cacheManager: cacheManager,
    );
  }
}
