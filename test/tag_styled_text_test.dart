import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag_styled_text/src/tag_styled_text.dart';

void main() {
  testWidgets('given malformed xml', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: TagStyledText('<a>'),
    ));
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets('given valid xml', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: TagStyledText('<bold>Some text in bold</bold>'),
    ));
    expect(tester.takeException(), isNull);

    expect(find.byType(TagStyledText), findsOneWidget);
    // plaintext matcher
    expect(find.text('Some text in bold'), findsOneWidget);
  });
}
