import 'package:flutter/material.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../utils/extensions/buildcontext.dart';
import 'custom_shimmer.dart';

final cacheManager = CacheManager(
  Config(
    'imageCache',
    maxNrOfCacheObjects: 512,
    stalePeriod: const Duration(days: 14),
  ),
);

Future<void> clearImageCache() async => await cacheManager.emptyCache();

class CachedCircleImage extends StatelessWidget {
  final String url;
  final double? radius;
  final Clip? clipBehavior;
  final Map<String, String>? httpHeaders;
  final int? memCacheHeight;

  const CachedCircleImage(
    this.url, {
    super.key,
    this.radius,
    this.clipBehavior,
    this.httpHeaders,
    this.memCacheHeight,
  });

  static const double _defaultRadius = 20.0;

  static const double _defaultMinRadius = 0.0;

  static const double _defaultMaxRadius = double.infinity;

  double get _minDiameter {
    if (radius == null) {
      return _defaultRadius * 2.0;
    }
    return 2.0 * (radius ?? _defaultMinRadius);
  }

  double get _maxDiameter {
    if (radius == null) {
      return _defaultRadius * 2.0;
    }
    return 2.0 * (radius ?? _defaultMaxRadius);
  }

  @override
  Widget build(BuildContext context) {
    final double minDiameter = _minDiameter;
    final double maxDiameter = _maxDiameter;

    return AnimatedContainer(
      constraints: BoxConstraints(
        minHeight: minDiameter,
        minWidth: minDiameter,
        maxWidth: maxDiameter,
        maxHeight: maxDiameter,
      ),
      duration: kThemeChangeDuration,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        clipBehavior: clipBehavior ?? Clip.hardEdge,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          memCacheHeight: memCacheHeight,
          httpHeaders: httpHeaders,
          cacheManager: cacheManager,
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
          errorListener: (_) {},
        ),
      ),
    );

    // return AnimatedContainer(
    //   constraints: BoxConstraints(
    //     minHeight: minDiameter,
    //     minWidth: minDiameter,
    //     maxWidth: maxDiameter,
    //     maxHeight: maxDiameter,
    //   ),
    //   duration: kThemeChangeDuration,
    //   decoration: BoxDecoration(
    //     // shape: BoxShape.circle,
    //     borderRadius: BorderRadius.circular(maxDiameter),
    //   ),
    //   child: ClipRRect(
    //     borderRadius: BorderRadius.circular(maxDiameter),
    //     child: CachedNetworkImage(
    //       imageUrl: url,
    //       fit: BoxFit.cover,
    //       cacheManager: cacheManager,
    //       placeholder: (context, url) => const CustomShimmer(),
    //       errorWidget: (context, url, error) => const Center(
    //         child: Icon(Icons.error_outline_rounded),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final PlaceholderWidgetBuilder? placeholder;
  final Duration? fadeOutDuration;
  final int? titleId;

  const CachedImage(
    this.imageUrl, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
    this.fadeOutDuration,
    this.placeholder,
    this.titleId,
  });

  @override
  Widget build(BuildContext context) {
    final fallBack = Container(
      color: context.colorScheme.secondaryContainer,
      child: Icon(
        Icons.broken_image_rounded,
        color: context.colorScheme.onSecondaryContainer,
      ),
    );

    String url = imageUrl;

    if (url.contains('missing') && titleId != null) {
      url = 'https://smarthard.net/static/animes/$titleId-placeholder.jpeg';
    }

    try {
      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: width,
        height: height,
        cacheManager: cacheManager,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        placeholder: placeholder ?? (context, url) => const CustomShimmer(),
        fadeOutDuration: fadeOutDuration,
        errorWidget: (context, url, error) {
          return fallBack;
        },
        errorListener: (_) {},
      );
    } on Exception {
      return fallBack;
    }
  }
}
