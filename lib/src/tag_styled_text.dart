import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tag_styled_text/src/utils.dart';

import 'default_tag_styles.dart';
import 'span_tag_builder.dart';
import 'span_tags.dart';
import 'tag_nodes.dart';

/// A [Text] that is capable of rendering a xml [text] into a tree
/// of [InlineSpan]s.
///
/// See [DefaultTagStyles] to insert default tags and styles on
/// the widget subtree.
class TagStyledText extends StatefulWidget {
  const TagStyledText(
    this.text, {
    super.key,
    this.tags,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  /// The styled text to be displayed by this widget.
  ///
  /// Must contain valid xml based tags.
  /// Be wary that special xml characters will be escaped when needed.
  ///
  /// See [SpanTag] for more information about how to properly mark
  /// the [text] with appropriate tags.
  final String text;

  /// A collection of known [SpanTag]s that will be used when the
  /// corresponding <tag> is matched.
  ///
  /// Will be merged with [DefaultTagStyles], if any.
  final Map<String, SpanTag>? tags;

  /// {@macro flutter.widgets.text.style}
  final TextStyle? style;

  /// {@macro flutter.widgets.text.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.widgets.text.textAlign}
  final TextAlign? textAlign;

  /// {@macro flutter.widgets.text.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutter.widgets.text.locale}
  final Locale? locale;

  /// {@macro flutter.widgets.text.softWrap}
  final bool? softWrap;

  /// {@macro flutter.widgets.text.overflow}
  final TextOverflow? overflow;

  /// {@macro flutter.widgets.text.textScaleFactor}
  final double? textScaleFactor;

  /// {@macro flutter.widgets.text.maxLines}
  final int? maxLines;

  /// {@macro flutter.widgets.text.semanticsLabel}
  final String? semanticsLabel;

  /// {@macro flutter.widgets.text.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// {@macro flutter.widgets.text.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// Passthrough property to [Text].
  /// See [Text.selectionColor] for more information.
  final Color? selectionColor;

  @override
  State<TagStyledText> createState() => TagStyledTextState();
}

class TagStyledTextState extends State<TagStyledText> {
  TagNode _rootNode = const TagNode(span: TextSpan());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _rootNode.dispose();
    final node = _parseText(widget.text);
    setState(() {
      _rootNode = node;
    });
  }

  @override
  void didUpdateWidget(covariant TagStyledText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.text != oldWidget.text) {
      _rootNode.dispose();
      final node = _parseText(widget.text);
      setState(() {
        _rootNode = node;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      _rootNode.span,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaleFactor: widget.textScaleFactor,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
    );
  }

  @override
  void dispose() {
    _rootNode.dispose();
    super.dispose();
  }

  TagNode _parseText(String text) {
    final defaultValues = DefaultTagStyles.of(context);
    final mergedTags = mergeMaps(defaultValues.tags, widget.tags);

    return parseText(context, text, tags: mergedTags);
  }
}
