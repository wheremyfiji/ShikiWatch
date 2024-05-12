import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
// ignore: implementation_imports
import 'package:flutter_html/src/tree/image_element.dart' as ie;
import 'package:flutter_html/flutter_html.dart';

import '../../cached_image.dart';

class CachedImageExtension extends ImageExtension {
  CachedImageExtension({
    super.handleAssetImages = false,
    super.handleDataImages = false,
    super.handleNetworkImages = true,
  });

  @override
  InlineSpan build(ExtensionContext context) {
    final imageElement = context.styledElement as ie.ImageElement;

    return WidgetSpan(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        clipBehavior: Clip.hardEdge,
        child: CachedNetworkImage(
          imageUrl: imageElement.src,
          cacheManager: cacheManager,
          fit: BoxFit.fill,
          placeholder: (context, url) => const SizedBox.shrink(),
          errorListener: (value) {},
        ),
      ),
    );
  }
}
