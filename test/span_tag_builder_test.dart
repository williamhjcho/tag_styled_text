import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tag_styled_text/src/span_tag_builder.dart';
import 'package:tag_styled_text/tag_styled_text.dart';

import 'test_utils.dart';

class MockBuildContext extends Mock implements BuildContext {}

class MockTapGestureRecognizer extends Mock implements TapGestureRecognizer {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class CustomSpanTag extends SpanTag {
  const CustomSpanTag(this.buildCallback);

  final TagNode Function({
    String? text,
    List<TagNode>? children,
    Map<String, String> attributes,
  }) buildCallback;

  @override
  TagNode build(
    BuildContext context, {
    String? text,
    List<TagNode>? children,
    Map<String, String> attributes = const {},
  }) {
    return buildCallback(
      text: text,
      children: children,
      attributes: attributes,
    );
  }
}

void main() {
  const boldStyle = TextStyle(fontWeight: FontWeight.bold);
  const pinkStyle = TextStyle(color: Colors.pink);
  const delStyle = TextStyle(decoration: TextDecoration.lineThrough);

  final customTags = <String, SpanTag>{
    'bold': const TextSpanTag(style: boldStyle),
    'pink': const TextSpanTag(style: pinkStyle),
    'del': const TextSpanTag(style: delStyle),
    // TODO: other SpanTags
  };

  for (final (input, expected) in [
    ('', const TextSpan()),
    ('<unknown></unknown>', const TextSpan()),
    ('<bold></bold>', const TextSpan(style: boldStyle)),
  ]) {
    testBuildSpan(
      'given empty text: "$input"',
      text: input,
      tags: customTags,
      expectedSpan: () => expected,
      expectedPlainText: () => '',
    );
  }

  testBuildSpan(
    'given untagged text',
    text: 'Some text with no tags',
    expectedSpan: () => const TextSpan(text: 'Some text with no tags'),
  );

  for (final (input, expected) in [
    // unmatched tags
    (
      '<a>Some text with a tag</a>',
      const TextSpan(text: 'Some text with a tag'),
    ),
    // matched tags
    (
      '<bold>Some text with a tag</bold>',
      const TextSpan(
        text: 'Some text with a tag',
        style: boldStyle,
      ),
    ),
    (
      'Some <bold>text with a tag</bold>',
      const TextSpan(children: [
        TextSpan(text: 'Some '),
        TextSpan(text: 'text with a tag', style: boldStyle),
      ]),
    ),
    (
      '<bold>Some text</bold> with a tag',
      const TextSpan(children: [
        TextSpan(text: 'Some text', style: boldStyle),
        TextSpan(text: ' with a tag'),
      ]),
    ),
    (
      'Some <bold>text</bold> with a tag',
      const TextSpan(children: [
        TextSpan(text: 'Some '),
        TextSpan(text: 'text', style: boldStyle),
        TextSpan(text: ' with a tag'),
      ]),
    ),
  ]) {
    testBuildSpan(
      'given simple tagged text: "$input"',
      text: input,
      tags: customTags,
      expectedSpan: () => expected,
      expectedPlainText: () => 'Some text with a tag',
    );
  }

  testBuildSpan(
    'given text with multiple un-nested matching tags',
    text: '<bold>First text</bold>\n'
        '<pink>Second text</pink>\n'
        '<del>Third text</del>',
    tags: customTags,
    expectedSpan: () => const TextSpan(children: [
      TextSpan(text: 'First text', style: boldStyle),
      TextSpan(text: '\n'),
      TextSpan(text: 'Second text', style: pinkStyle),
      TextSpan(text: '\n'),
      TextSpan(text: 'Third text', style: delStyle),
    ]),
    expectedPlainText: () => 'First text\nSecond text\nThird text',
  );

  for (final (input, expected) in [
    // all unmatching tags
    (
      '<a><b><c>this is a nested tag text.</c></b></a>',
      const TextSpan(text: 'this is a nested tag text.'),
    ),
    // all matching tags
    (
      '<bold><pink><del>this is a nested tag text.</del></pink></bold>',
      const TextSpan(
        style: boldStyle,
        children: [
          TextSpan(
            style: pinkStyle,
            children: [
              TextSpan(
                style: delStyle,
                text: 'this is a nested tag text.',
              ),
            ],
          ),
        ],
      ),
    ),

    // partially matching tags
    (
      '<bold><a><pink>this is a nested tag text.</pink></a></bold>',
      const TextSpan(
        style: boldStyle,
        children: [
          TextSpan(
            style: pinkStyle,
            text: 'this is a nested tag text.',
          ),
        ],
      ),
    ),
    // with texts leading & in-between tags
    (
      'this <bold>is <pink>a <del>nested</del> tag</pink> text</bold>.',
      const TextSpan(children: [
        TextSpan(text: 'this '),
        TextSpan(
          style: boldStyle,
          children: [
            TextSpan(text: 'is '),
            TextSpan(
              style: pinkStyle,
              children: [
                TextSpan(text: 'a '),
                TextSpan(
                  style: delStyle,
                  text: 'nested',
                ),
                TextSpan(text: ' tag'),
              ],
            ),
            TextSpan(text: ' text'),
          ],
        ),
        TextSpan(text: '.'),
      ]),
    ),
  ]) {
    testBuildSpan(
      'given text with simple nested tags: "$input"',
      text: input,
      tags: customTags,
      expectedSpan: () => expected,
      expectedPlainText: () => 'this is a nested tag text.',
    );
  }

  testBuildSpan(
    'given text with line breaks between enclosing tags',
    text: 'Some <bold>tagged text with\nline\nbreaks\n</bold>in it',
    tags: customTags,
    expectedSpan: () => const TextSpan(children: [
      TextSpan(text: 'Some '),
      TextSpan(
        text: 'tagged text with\nline\nbreaks\n',
        style: boldStyle,
      ),
      TextSpan(text: 'in it'),
    ]),
    expectedPlainText: () => 'Some tagged text with\nline\nbreaks\nin it',
  );

  for (final input in [
    // disjoint
    '<x><y>text</x></y>',
    // mismatched
    '<a><b>text</x></y>',
  ]) {
    test('given malformed tags: "$input"', () {
      final context = MockBuildContext();
      expect(() => parseText(context, input, tags: {}), throwsAssertionError);
    });
  }

  testBuildSpan(
    'given one level nested text-tag reduces it to a single TextSpan',
    text: '<bold>Some text</bold>',
    tags: customTags,
    expectedSpan: () => const TextSpan(style: boldStyle, text: 'Some text'),
    expectedPlainText: () => 'Some text',
  );

  testBuildSpan(
    'given tags with attributes, finds them',
    text: '<custom '
        'color="FFFF0000" '
        'name="some tag" '
        'url="https://localhost.com/">'
        'Some text'
        '</custom>',
    tags: {
      'custom': CustomSpanTag(({
        text,
        children,
        attributes = const {},
        recognizer,
      }) {
        final color = Color(int.parse(attributes['color']!, radix: 16));
        final name = attributes['name']!;
        final url = attributes['url'];
        expect(url, 'https://localhost.com/');

        return TagNode(
          span: TextSpan(
            style: TextStyle(color: color),
            text: name,
            children: children?.map((e) => e.span).toList(),
          ),
          children: children,
        );
      }),
    },
    expectedSpan: () => const TextSpan(
      style: TextStyle(color: Color(0xFFFF0000)),
      text: 'some tag',
    ),
  );

  group('$TextSpanTag', () {
    test('given all properties, passes them to the node span', () {
      const style = boldStyle;
      final mouseCursor = random.nextItem({
        MouseCursor.defer,
        MouseCursor.uncontrolled,
      });
      final PointerEnterEventListener onEnter =
          expectAsync1((event) {}, count: 0);
      final PointerExitEventListener onExit =
          expectAsync1((event) {}, count: 0);
      const semanticsLabel = 'Some semantic label';
      const locale = Locale('test');
      final spellOut = random.nextBool();

      final tag = TextSpanTag(
        style: style,
        mouseCursor: mouseCursor,
        onEnter: onEnter,
        onExit: onExit,
        semanticsLabel: semanticsLabel,
        locale: locale,
        spellOut: spellOut,
        // handled by another test
        recognizerBuilder: null,
      );
      const children = <TagNode>[
        TagNode(span: TextSpan(text: 'Child 1', style: pinkStyle)),
        TagNode(span: TextSpan(text: 'Child 2', style: delStyle)),
      ];
      final node = tag.build(
        MockBuildContext(),
        text: 'Some text',
        children: children,
        attributes: {},
      );

      expect(
        node.span,
        TextSpan(
          text: 'Some text',
          children: const [
            TextSpan(text: 'Child 1', style: pinkStyle),
            TextSpan(text: 'Child 2', style: delStyle),
          ],
          style: style,
          recognizer: null,
          mouseCursor: mouseCursor,
          onEnter: onEnter,
          onExit: onExit,
          semanticsLabel: semanticsLabel,
          locale: locale,
          spellOut: spellOut,
        ),
      );
      expect(node.children, children);
    });

    test('disposes of the gesture recognizer, if any', () {
      final context = MockBuildContext();
      final recognizer = MockTapGestureRecognizer();
      final tag = TextSpanTag(
        recognizerBuilder: expectAsync3((context, text, attributes) {
          return recognizer;
        }),
      );
      tag.build(context).dispose();
      verify(() => recognizer.dispose()).called(1);
    });
  });
}

@isTest
void testBuildSpan(
  String description, {
  required String text,
  Map<String, SpanTag> tags = const {},
  required dynamic Function() expectedSpan,
  String? Function()? expectedPlainText,
  // by default verifies that they are empty
  void Function(List<GestureRecognizer> gestuers)? verifyGestures,
}) {
  test(description, () {
    final context = MockBuildContext();

    final node = parseText(context, text, tags: tags);
    final span = node.span;
    final expectedResult = expectedSpan();

    expect(
      span,
      expectedResult,
      reason: span.toStringDeep(),
    );

    if (expectedPlainText != null) {
      final expectedText = expectedPlainText();
      expect(span.toPlainText(), equals(expectedText));
    }

    final gestures = <GestureRecognizer>[];
    final queue = ListQueue.of([node]);
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current case TextSpanTagNode(:final gestureRecognizer?)) {
        gestures.add(gestureRecognizer);
      }
    }
    if (verifyGestures == null) {
      expect(gestures, isEmpty);
    } else {
      verifyGestures(gestures);
    }
  });
}
