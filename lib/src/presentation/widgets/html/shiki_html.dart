import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';

import '../../../utils/extensions/buildcontext.dart';
import '../../../utils/shiki_utils.dart';

import 'extensions/youtube_video_extension.dart';
import 'extensions/cached_image_extension.dart';
import 'extensions/replies_wrap_extension.dart';
import 'extensions/spoiler_wrap_extension.dart';
import 'extensions/quote_wrap_extension.dart';

class ShikiHtml extends StatelessWidget {
  const ShikiHtml({
    super.key,
    required this.data,
    this.enableLinkTap = true,
  });

  final String data;
  final bool enableLinkTap;

  @override
  Widget build(BuildContext context) {
    return Html(
      data: data,
      style: {
        'body': Style(
          margin: Margins.all(0),
        ),
        'a': Style(
          textDecoration: TextDecoration.none,
          color: context.colorScheme.primary,
        ),
        's': Style(
          textDecoration: TextDecoration.none,
        ),
      },
      extensions: <HtmlExtension>[
        // OnImageTapExtension(
        //   onImageTap: (url, attributes, element) {
        //     print('url: $url\n attributes: $attributes');
        //   },
        // ),
        QuoteWrapExtension(context),
        RepliesWrapExtension(context),
        SpoilerWrapExtension(context),
        YouTubeVideoExtension(context),
        CachedImageExtension(),

        // TagWrapExtension(
        //   tagsToWrap: {'div'},
        //   builder: (child) {
        //     return Container(
        //       color: Colors.red,
        //       child: child,
        //     );
        //   },
        // ),
      ],
      onLinkTap: (url, attributes, element) {
        if (url == null || url.isEmpty || !enableLinkTap) {
          return;
        }

        ShikiUtils.instance.handleShikiHtmlLinkTap(
          context,
          url: url,
          attributes: attributes,
        );
      },
    );
  }
}
