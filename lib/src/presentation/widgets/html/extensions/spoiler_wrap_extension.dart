import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as html;

import '../../../../utils/extensions/buildcontext.dart';

class SpoilerWrapExtension extends HtmlExtension {
  SpoilerWrapExtension(
    this.buildContext,
  );

  final BuildContext buildContext;

  @override
  Set<String> get supportedTags => {'div'};

  @override
  bool matches(ExtensionContext context) {
    return switch (context.currentStep) {
      CurrentStep.preparing =>
        context.attributes['class'] == 'b-spoiler_block to-process',
      CurrentStep.building => context.styledElement is SpoilerElement,
      _ => false,
    };
  }

  @override
  StyledElement prepare(
      ExtensionContext context, List<StyledElement> children) {
    return SpoilerElement(
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

    return WidgetSpan(
      child: SpoilerBlock(innerChild),
    );
  }
}

class SpoilerBlock extends StatefulWidget {
  const SpoilerBlock(this.innerChild, {super.key});

  final Widget innerChild;

  @override
  State<SpoilerBlock> createState() => _SpoilerBlockState();
}

class _SpoilerBlockState extends State<SpoilerBlock> {
  bool show = false;

  toggle() {
    setState(() {
      show = !show;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spoilerCollapsed = Container(
      key: const ValueKey<String>('spoilerCollapsed'),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      padding: const EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: 4.0,
      ),
      child: Text(
        'Показать спойлер',
        style: TextStyle(
          color: context.colorScheme.onPrimaryContainer,
        ),
      ),
    );

    final spoilerExpanded = Container(
      key: const ValueKey<String>('spoilerExpanded'),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(6.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      padding: const EdgeInsets.symmetric(
        vertical: 3.0,
        horizontal: 6.0,
      ),
      child: widget.innerChild,
    );

    return GestureDetector(
      onTap: toggle,
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        reverseDuration: Duration.zero,
        firstCurve: Curves.fastLinearToSlowEaseIn,
        secondCurve: Curves.fastLinearToSlowEaseIn,
        sizeCurve: Easing.standard,
        firstChild: spoilerExpanded,
        secondChild: spoilerCollapsed,
        alignment: Alignment.topLeft,
        crossFadeState:
            show ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      ),
    );
  }
}

class SpoilerElement extends StyledElement {
  SpoilerElement({
    required StyledElement child,
  }) : super(
          node: html.Element.tag("spoiler-element"),
          style: Style(),
          children: [child],
          name: "[spoiler-element]",
        );
}
