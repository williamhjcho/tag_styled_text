import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';

import 'span_tags.dart';
import 'tag_nodes.dart';

const _xmlEntities = XmlDefaultEntityMapping.xml();

String unescapeXML(String input) => _xmlEntities.decode(input);

/// Parses and builds the [InlineSpan]s and (if any) [GestureRecognizer]s.
///
/// It will fallback to a [TextSpan] instance, even if [input] was empty.
/// the [tags] table will be consulted while parsing to generate appropriate
/// [InlineSpan]s if needed. If a parsed tag is not present in [tags], it will
/// simply be ignored.
TagNode parseText(
  BuildContext context,
  String input, {
  Map<String, SpanTag> tags = const {},
  // TODO: on error handler?
}) {
  TagNode? tagNode;
  try {
    final document = XmlDocument.parse(
      '<?xml version="1.0"?><root>$input</root>',
    );
    tagNode = _buildNodes(
      context,
      document.rootElement,
      tags,
    );
  } catch (error, stackTrace) {
    assert(false, 'Failed to parse XML: $input\n$error\n$stackTrace');
  }
  return tagNode ?? TagNode(span: TextSpan(text: unescapeXML(input)));
}

// TODO: convert to (iterable) decoder
// TODO: convert to non-recursive with ListQueue
TagNode? _buildNodes(
  BuildContext context,
  XmlNode node,
  Map<String, SpanTag> tags,
) {
  if (node is XmlText) {
    return TextSpanTagNode(
      span: TextSpan(text: unescapeXML(node.value)),
    );
  }
  if (node is! XmlElement) {
    return null;
  }

  final tagName = node.name.local;
  var tag = tags[tagName];
  String? text;
  List<TagNode>? children;

  if (node.children case [final XmlElement child] when tag == null) {
    // small optimization reduction for single nested unknown tag(s)
    return _buildNodes(context, child, tags);
  } else if (node.children case [XmlText(:final value)]) {
    // small optimization for single child text nodes
    text = unescapeXML(value);
  } else if (node.children.isNotEmpty) {
    children = node.children
        .map((child) => _buildNodes(context, child, tags))
        .whereNotNull()
        .toList();
  }

  final attributes = <String, String>{
    for (final attribute in node.attributes)
      attribute.name.local: attribute.value,
  };

  tag ??= const TextSpanTag();
  return tag.build(
    context,
    text: text,
    children: children,
    attributes: attributes,
  );
}
