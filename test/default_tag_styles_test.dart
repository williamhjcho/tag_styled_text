import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag_styled_text/src/default_tag_styles.dart';
import 'package:tag_styled_text/src/span_tags.dart';

void main() {
  const tags = <String, SpanTag>{
    'bold': TextSpanTag(style: TextStyle(fontWeight: FontWeight.bold)),
    'italic': TextSpanTag(style: TextStyle(fontStyle: FontStyle.italic)),
  };

  testWidgets('fallback cannot be used in the widget three', (tester) async {
    await tester.pumpWidget(const DefaultTagStyles.fallback());
    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('.of', (tester) async {
    const childKey = Key('child');

    late BuildContext context;
    await tester.pumpWidget(DefaultTagStyles(
      tags: tags,
      child: Builder(builder: (ctx) {
        context = ctx;
        return Container(key: childKey);
      }),
    ));

    expect(find.byKey(childKey), findsOneWidget);
    expect(DefaultTagStyles.of(context).tags, equals(tags));
  });

  testWidgets('.merge', (tester) async {
    const keyA = Key('tag style A'), keyB = Key('tag style B');
    const childKey = Key('child');

    late BuildContext context;
    await tester.pumpWidget(DefaultTagStyles(
      key: keyA,
      tags: tags,
      child: DefaultTagStyles.merge(
        key: keyB,
        tags: {
          // overriding bold
          'bold':
              const TextSpanTag(style: TextStyle(fontWeight: FontWeight.w900)),
          // new tag
          'pink': const TextSpanTag(style: TextStyle(color: Colors.pink)),
        },
        child: Builder(builder: (ctx) {
          context = ctx;
          return Container(key: childKey);
        }),
      ),
    ));

    expect(find.byKey(childKey), findsOneWidget);
    expect(find.byKey(keyA), findsOneWidget);
    expect(find.byKey(keyB), findsOneWidget);

    expect(
      DefaultTagStyles.of(context).tags,
      equals(const {
        'bold': TextSpanTag(style: TextStyle(fontWeight: FontWeight.w900)),
        'italic': TextSpanTag(style: TextStyle(fontStyle: FontStyle.italic)),
        'pink': TextSpanTag(style: TextStyle(color: Colors.pink)),
      }),
    );
  });

  group('.wrap', () {
    testWidgets('when ancestor is not the instance', (tester) async {
      final childA = Container(key: const Key('child A'));
      final instance = DefaultTagStyles(
        key: const Key('tag styles'),
        tags: tags,
        child: childA,
      );

      await tester.pumpWidget(Builder(builder: (context) {
        return instance.wrap(context, childA);
      }));

      expect(find.byKey(childA.key!), findsOneWidget);
      expect(find.byKey(instance.key!), findsNothing);
      expect(find.byType(DefaultTagStyles), findsOneWidget);
    });

    testWidgets('when ancestor is the same instance', (tester) async {
      final childA = Container(key: const Key('child A'));
      const instanceKey = Key('tag styles A');

      await tester.pumpWidget(DefaultTagStyles(
        key: const Key('tag styles A'),
        tags: tags,
        child: Builder(builder: (context) {
          // fallback will not be used on the widget tree
          return const DefaultTagStyles.fallback().wrap(context, childA);
        }),
      ));

      expect(find.byKey(childA.key!), findsOneWidget);
      expect(find.byKey(instanceKey), findsOneWidget);
    });
  });
}
