import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tag_styled_text/src/tag_nodes.dart';

class MockTagNode extends Mock implements TagNode {}

void main() {
  test('disposes of all children', () {
    final children = List<TagNode>.generate(3, (_) => MockTagNode());

    final root = TagNode(
      span: const TextSpan(),
      children: children,
    );
    root.dispose();

    for (final child in children) {
      verify(() => child.dispose()).called(1);
    }
  });
}
