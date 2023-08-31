import 'package:example/custom_default_tag_styles.dart';
import 'package:flutter/material.dart';
import 'package:tag_styled_text/tag_styled_text.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(
        useMaterial3: true,
      ),
      builder: (context, child) {
        // inserting the application default tag styles here
        return CustomDefaultTagStyles(child: child!);
      },
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Examples'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        children: const [
          // no tags
          _ListTitle('No tags'),
          TagStyledText('Simple text with no tags'),
          TagStyledText('Simple text with <unknown>unknown tags</unknown>'),
          // typography
          _ListTitle('By typography'),
          TagStyledText('<displayMedium>Display medium text</displayMedium>'),
          TagStyledText('<headlineLarge>Headline large text</headlineLarge>'),
          TagStyledText('<bodyMedium>Body medium text</bodyMedium>'),
          TagStyledText('<labelSmall>Label small text</labelSmall>'),
          // color
          _ListTitle('By color'),
          TagStyledText(
            'Some text with <custom color="primary">primary</custom> color',
          ),
          TagStyledText(
            'Some text with <custom color="error">error</custom> color',
          ),
          TagStyledText(
            'Some text with <custom color="FF0000">red</custom> color',
          ),
          // nested tags
          _ListTitle('Nested tags'),
          TagStyledText(
            'Some text with a '
            '<strike><italic><bold>colored, '
            '<custom color="FF0000">bold</custom>, '
            '<custom color="00FF00">italic</custom>, and '
            '<custom color="0000FF">striked</custom>'
            '</bold></italic></strike> '
            'text',
          ),
          // icons & widgets
          _ListTitle('Icons & widgets'),
          TagStyledText(
            'Some text with <icon name="star"/> '
            'icons in between <icon name="alarm"/> them.',
          ),
          TagStyledText(
            'Some text with a column widget <column/> in between the text',
          ),

          // gestures
          _ListTitle('With gestures'),
          TagStyledText(
            // flutter issue: https://github.com/flutter/flutter/issues/75622
            // the gesture recognizer doesn't get triggered if it isn't on the
            // same TextSpan
            'Opens a <bold><snackbar message="Tapped!">snackbar</snackbar></bold> when tapped',
          ),
          SafeArea(
            top: false,
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ListTitle extends StatelessWidget {
  const _ListTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: theme.textTheme.headlineMedium!),
          const Divider(),
        ],
      ),
    );
  }
}
