import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final cacheManager = CacheManager(
  Config(
    'imageCache',
    maxNrOfCacheObjects: 1000,
    stalePeriod: const Duration(days: 14),
  ),
);

Future<void> clearImageCache() async => await cacheManager.emptyCache();

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;

  const CachedImage(
    this.imageUrl, {
    super.key,
    //this.fit = BoxFit.cover,
    // this.width = double.infinity,
    // this.height = double.infinity,
    this.fit,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      cacheManager: cacheManager,
    );
  }
}
