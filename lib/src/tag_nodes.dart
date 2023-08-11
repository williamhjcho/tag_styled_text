import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

/// A node containing all of the [SpanTag]'s parsed value(s).
/// This instance is managed (i.e. attached to) the [TagStyledText] widget's
/// lifecycle.
///
/// See [TextSpanTagNode] for the base example of a [TagNode] that is
/// associated to the most basic [TextSpan].
class TagNode {
  const TagNode({
    required this.span,
    this.children,
  });

  final InlineSpan span;
  final List<TagNode>? children;

  @mustCallSuper
  void dispose() {
    for (final child in children ?? []) {
      child.dispose();
    }
  }

  @override
  String toString() => 'TagNode($span)';

  String toStringDeep({
    String prefixLineOne = '',
    String? prefixOtherLines,
    DiagnosticLevel minLevel = DiagnosticLevel.debug,
  }) {
    return 'TagNode(${span.toStringDeep(
      prefixLineOne: prefixLineOne,
      prefixOtherLines: prefixOtherLines,
      minLevel: minLevel,
    )})';
  }
}

/// A specialized [TagNode] for [TextSpan]s.
///
/// It is aware of the [gestureRecognizer] in [span].
class TextSpanTagNode extends TagNode {
  const TextSpanTagNode({
    required TextSpan super.span,
    super.children,
  });

  GestureRecognizer? get gestureRecognizer => (span as TextSpan).recognizer;

  @override
  void dispose() {
    gestureRecognizer?.dispose();
    super.dispose();
  }
}
