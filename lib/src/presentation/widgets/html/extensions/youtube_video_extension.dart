import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../cached_image.dart';

class YouTubeVideoExtension extends HtmlExtension {
  YouTubeVideoExtension(this.buildContext);

  final BuildContext buildContext;

  @override
  //Set<String> get supportedTags => {"div"};
  Set<String> get supportedTags => {'div'};

  @override
  bool matches(ExtensionContext context) {
    return switch (context.currentStep) {
      CurrentStep.preparing => context.attributes['class'] ==
          'c-video b-video unprocessed youtube  fixed',
      CurrentStep.building => context.styledElement is YouTubeTagElement,
      _ => false,
    };
  }

  @override
  StyledElement prepare(
      ExtensionContext context, List<StyledElement> children) {
    final videoId = _parseYoutubeId(context.innerHtml);

    return YouTubeTagElement(
      name: context.elementName,
      elementId: context.id,
      node: context.node,
      children: children,
      style: Style(),
      videoId: videoId,
    );
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final element = context.styledElement as YouTubeTagElement;
    final id = element.videoId;

    return WidgetSpan(
      child: GestureDetector(
        onTap: () async {
          try {
            final uri = Uri.parse('https://youtube.com/watch?v=$id');
            launchUrl(uri);
          } catch (e) {
            //
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              SizedBox(
                width: 240,
                height: 135,
                child: CachedImage(
                  'https://img.youtube.com/vi/$id/0.jpg',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox.shrink(),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                margin: const EdgeInsets.all(4.0),
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: Colors.red,
                      size: 12,
                    ),
                    SizedBox(
                      width: 3.0,
                    ),
                    Text(
                      'youtube',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _parseYoutubeId(String html) {
    final hrefRegex = RegExp(r'href="([^"]+)"');
    final hrefMatch = hrefRegex.firstMatch(html);
    final hrefValue = hrefMatch!.group(1)!;

    return hrefValue.split('/').last;
  }
}

class YouTubeTagElement extends ReplacedElement {
  YouTubeTagElement({
    required super.name,
    required super.elementId,
    required super.node,
    required super.style,
    required super.children,
    required this.videoId,
  });

  final String videoId;
}
