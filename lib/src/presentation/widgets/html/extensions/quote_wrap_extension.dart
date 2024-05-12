import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as html;

import '../../../../utils/extensions/buildcontext.dart';

class QuoteWrapExtension extends HtmlExtension {
  QuoteWrapExtension(
    this.buildContext,
  );

  final BuildContext buildContext;

  @override
  Set<String> get supportedTags => {'div'};

  @override
  bool matches(ExtensionContext context) {
    return switch (context.currentStep) {
      CurrentStep.preparing => context.attributes['class'] == 'b-quote',
      CurrentStep.building => context.styledElement is QuoteElement,
      _ => false,
    };
  }

  @override
  StyledElement prepare(
      ExtensionContext context, List<StyledElement> children) {
    return QuoteElement(
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

    final wrapped = Container(
      decoration: BoxDecoration(
        color: buildContext.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 8.0,
      ),
      child: innerChild,
    );

    return WidgetSpan(
      child: wrapped,
    );
  }
}

class QuoteElement extends StyledElement {
  QuoteElement({
    required StyledElement child,
  }) : super(
          node: html.Element.tag("quote-element"),
          style: Style(),
          children: [child],
          name: "[quote-element]",
        );
}
