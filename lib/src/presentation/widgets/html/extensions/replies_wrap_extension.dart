import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as html;

class RepliesWrapExtension extends HtmlExtension {
  RepliesWrapExtension(
    this.buildContext,
  );

  final BuildContext buildContext;

  @override
  Set<String> get supportedTags => {'div'};

  @override
  bool matches(ExtensionContext context) {
    return switch (context.currentStep) {
      CurrentStep.preparing =>
        context.attributes['class'] == 'b-replies translated-before ',
      CurrentStep.building => context.styledElement is RepliesElement,
      _ => false,
    };
  }

  @override
  StyledElement prepare(
      ExtensionContext context, List<StyledElement> children) {
    return RepliesElement(
      child: context.parser.prepareFromExtension(
        context,
        children,
        extensionsToIgnore: {this},
      ),
    );
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final innerChild = CssBoxWidget.withInlineSpanChildren(
      children: context.inlineSpanChildren!,
      style: context.style!,
    );

    final wrapped = Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(
        children: [
          const Text('Ответы: '),
          Flexible(
            child: innerChild,
          ),
        ],
      ),
    );

    return WidgetSpan(
      child: wrapped,
    );
  }
}

class RepliesElement extends StyledElement {
  RepliesElement({
    required StyledElement child,
  }) : super(
          node: html.Element.tag("replies-element"),
          style: Style(),
          children: [child],
          name: "[replies-element]",
        );
}
