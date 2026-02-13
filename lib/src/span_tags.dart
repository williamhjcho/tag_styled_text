import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'tag_nodes.dart';

/// The base tag building interface.
///
/// This definition is used to generate a [TagNode] that will in turn contain
/// the desired [InlineSpan].
///
/// Since the resulting [InlineSpan] is not necessarily stateless, a [TagNode]
/// intermediary definition is needed to attach a lifecycle into the
/// corresponding widget.
///
/// See also:
/// * [TextSpanTag] for the simple and most likely use case for this package.
abstract class SpanTag {
  const SpanTag();

  /// Builds a [InlineSpan] when this tag builder's associated tag was found
  /// within a currently parsing text.
  ///
  /// * [context] is from the current [TagStyledText] widget. It can be used
  ///   to access any context-aware resources from the widget tree.
  /// * [text] is an optional pure text that was found within the tags.
  ///   (e.g. `<tag>Some text</tag>`)
  /// * [children] are any nested tags that were parsed from the input,
  ///   descendants from **this**.
  /// * Any [attributes] that were given to the tag
  ///   (e.g. `<tag id="123" age="33">`)
  TagNode build(
    BuildContext context, {
    String? text,
    List<TagNode>? children,
    Map<String, String> attributes = const {},
  });
}

/// A [SpanTag] that will build [TextSpan]s for the matched tags.
///
/// Simple use case examples:
///
/// ```dart
/// tags: {
///   'bold': TextSpanTag(
///     style: TextStyle(fontWeight: FontWeight.bold),
///   ),
///   'underline': TextSpanTag(
///     style: TextStyle(decoration: TextDecoration.underline),
///   ),
/// },
/// ```
///
/// Or with a tap gesture recognizer:
///
/// ```dart
/// tags: {
///   'url': TextSpanTag(
///     recognizerBuilder: (context, text, attributes) {
///       // gesture created by this builder is managed by the span tag's node
///       // so you don't have to actively dispose of it.
///       return TapGestureRecognizer()
///         ..onTap = () {
///           final url = attributes['url'];
///           if (url == null) {
///             // handle missing url case
///             return;
///           }
///           openUrl(url);
///         };
///     },
///   ),
/// },
/// ```
///
/// See also:
/// * [SpanTag] for the base interface definition.
class TextSpanTag extends SpanTag {
  const TextSpanTag({
    this.style,
    this.mouseCursor,
    this.onEnter,
    this.onExit,
    this.semanticsLabel,
    this.locale,
    this.spellOut,
    this.recognizerBuilder,
  });

  final TextStyle? style;
  final MouseCursor? mouseCursor;
  final PointerEnterEventListener? onEnter;
  final PointerExitEventListener? onExit;
  final String? semanticsLabel;
  final Locale? locale;
  final bool? spellOut;

  final SpanTagGestureRecognizerBuilder? recognizerBuilder;

  @override
  TagNode build(
    BuildContext context, {
    String? text,
    List<TagNode>? children,
    Map<String, String> attributes = const {},
  }) {
    return TextSpanTagNode(
      span: TextSpan(
        text: text,
        children: children?.map((e) => e.span).toList(),
        style: style,
        recognizer: recognizerBuilder?.call(context, text, attributes),
        mouseCursor: mouseCursor,
        onEnter: onEnter,
        onExit: onExit,
        semanticsLabel: semanticsLabel,
        locale: locale,
        spellOut: spellOut,
      ),
      children: children,
    );
  }
}

typedef SpanTagGestureRecognizerBuilder = GestureRecognizer? Function(
  BuildContext context,
  String? text,
  Map<String, String> attributes,
);
