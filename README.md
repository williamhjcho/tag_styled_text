# xml_styled_text package

[![build](https://github.com/williamhjcho/xml_styled_text/actions/workflows/build.yaml/badge.svg)](https://github.com/williamhjcho/xml_styled_text/actions/workflows/build.yaml) [![codecov](https://codecov.io/gh/williamhjcho/xml_styled_text/graph/badge.svg?token=9E7L28K3AV)](https://codecov.io/gh/williamhjcho/xml_styled_text)

Straightforward xml tag based (rich) styling on `Text` widgets

## Getting started

Add this library to your pubspec.yaml file by either running

`flutter pub add xml_styled_text`

or by manually inserting

```yaml
#(...)
dependencies:
  xml_styled_text: ^<desired version here>
#(...)
```

## Usage

By itself, the package doesn't offer any default tags, you will have to add them
yourself like so:

> for a full showcase of functionalities take a look at the `example` app

```dart
    // in your material app definition
    MaterialApp(
      // (...)
      builder: (context, child) {
        // inserting the application default tag styles here
        return DefaultTagStyles(
          tags: {
            'bold': const TextSpanTag(
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            'italic': const TextSpanTag(
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          },
          child: child!,
        );
      },
      // (...)
    );
```

Then instead of using normally `Text` widgets, we would instead use:

```dart
// simple tag usage
TagStyledText('Some <bold>bold text</bold>!');

// nested tag usage
TagStyledText('Some <bold>bold and <italic>italic text</italic></bold>!');

// if you need to add special tags only on specific instaces
TagStyledText(
  'Some text with <bold><special>a special text</special></bold>',
  // tags here will be merged with any existing DefaultTagStyles on the widget tree
  // allowing both <special> and <bold> to be used without re-declaration.
  // if you add a tag here that is already present on the DefaultTagStyles, 
  // it will take  priority.
  tags: {
    'special': const TextSpanTag(style: TextStyle(color: Colors.pink)),
  },
);
```
