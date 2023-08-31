import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tag_styled_text/tag_styled_text.dart';

/// Inserts the default [DefaultTagStyles] to the widget tree.
class CustomDefaultTagStyles extends StatelessWidget {
  const CustomDefaultTagStyles({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTagStyles(
      tags: {
        // by typography
        'displayLarge': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.displayLarge,
        ),
        'displayMedium': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.displayMedium,
        ),
        'displaySmall': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.displaySmall,
        ),
        'headlineLarge': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.headlineLarge,
        ),
        'headlineMedium': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.headlineMedium,
        ),
        'headlineSmall': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.headlineSmall,
        ),
        'titleLarge': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.titleLarge,
        ),
        'titleMedium': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.titleMedium,
        ),
        'titleSmall': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.titleSmall,
        ),
        'bodyLarge': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.bodyLarge,
        ),
        'bodyMedium': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.bodyMedium,
        ),
        'bodySmall': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.bodySmall,
        ),
        'labelLarge': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.labelLarge,
        ),
        'labelMedium': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.labelMedium,
        ),
        'labelSmall': _TextThemeTag(
          colorScheme: colorScheme,
          style: theme.textTheme.labelSmall,
        ),

        // by other known properties
        'bold': const TextSpanTag(
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        'italic': const TextSpanTag(
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        'strike': const TextSpanTag(
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
            decorationStyle: TextDecorationStyle.solid,
          ),
        ),
        'underline': const TextSpanTag(
          style: TextStyle(decoration: TextDecoration.underline),
        ),
        'tabular': const TextSpanTag(
          style: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
        ),

        // by generic tag naming
        'custom': _TextThemeTag(colorScheme: colorScheme),

        // icons
        'icon': const _IconSpanTag(),
        'column': const _ColumnWidgetSpanTag(),

        // gestures
        'snackbar': TextSpanTag(
          recognizerBuilder: (context, text, attributes) {
            return TapGestureRecognizer()
              ..onTap = () {
                final message = attributes['message'] ?? 'unknown message';
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(message)));
              };
          },
        ),
      },
      child: child,
    );
  }
}

class _ColumnWidgetSpanTag extends SpanTag {
  const _ColumnWidgetSpanTag();

  @override
  TagNode build(
    BuildContext context, {
    String? text,
    List<TagNode>? children,
    Map<String, String> attributes = const {},
  }) {
    return const TagNode(
      span: WidgetSpan(
        baseline: TextBaseline.alphabetic,
        alignment: PlaceholderAlignment.baseline,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item 1'),
            Text('Item 2'),
            Text('Item 3'),
          ],
        ),
      ),
    );
  }
}

class _IconSpanTag extends SpanTag {
  const _IconSpanTag();

  @override
  TagNode build(
    BuildContext context, {
    String? text,
    List<TagNode>? children,
    Map<String, String> attributes = const {},
  }) {
    final iconName = attributes['name'];
    final IconData icon = switch (iconName) {
      'alarm' => Icons.alarm,
      'star' => Icons.star,
      _ => Icons.device_unknown,
    };

    return TagNode(
      span: WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(icon),
      ),
    );
  }
}

/// Example of a [SpanTag] that has a base [style] and attempts to parse
/// a [TextStyle] from the associated tag's attributes.
class _TextThemeTag extends SpanTag {
  _TextThemeTag({
    required this.colorScheme,
    this.style,
  });

  final ColorScheme colorScheme;
  final TextStyle? style;

  @override
  TagNode build(
    BuildContext context, {
    String? text,
    List<TagNode>? children,
    Map<String, String> attributes = const {},
  }) {
    final parsedStyle = _parseTextStyle(attributes, colorScheme);
    final effectiveStyle = style?.merge(parsedStyle) ?? parsedStyle;

    return TextSpanTagNode(
      span: TextSpan(
        text: text,
        style: effectiveStyle,
        children: children?.map((e) => e.span).toList(),
      ),
      children: children,
    );
  }
}

/// Attempts to parse a [TextStyle] by looking into the values in [attributes].
///
/// Fallbacks to null.
TextStyle? _parseTextStyle(
  Map<String, String> attributes,
  ColorScheme colorScheme,
) {
  if (attributes.isEmpty) return null;

  return TextStyle(
    fontSize: _parseDouble(attributes['fontSize']),
    color: _parseColor(attributes['color'], colorScheme),
    backgroundColor: _parseColor(attributes['backgroundColor'], colorScheme),
    fontWeight: _fontWeights[attributes['fontWeight']],
    fontStyle: _fontStyles[attributes['fontStyle']],
    decoration: _textDecorations[attributes['decoration']],
    decorationStyle: _textDecorationStyles[attributes['decorationStyle']],
    letterSpacing: _parseDouble(attributes['letterSpacing']),
  );
}

const Map<String, FontWeight> _fontWeights = {
  '100': FontWeight.w100,
  '200': FontWeight.w200,
  '300': FontWeight.w300,
  '400': FontWeight.w400,
  '500': FontWeight.w500,
  '600': FontWeight.w600,
  '700': FontWeight.w700,
  '800': FontWeight.w800,
  '900': FontWeight.w900,
};

const Map<String, FontStyle> _fontStyles = {
  'normal': FontStyle.normal,
  'italic': FontStyle.italic,
};

const Map<String, TextDecoration> _textDecorations = {
  'none': TextDecoration.none,
  'lineThrough': TextDecoration.lineThrough,
  'underline': TextDecoration.underline,
  'overline': TextDecoration.overline,
};

const Map<String, TextDecorationStyle> _textDecorationStyles = {
  'dashed': TextDecorationStyle.dashed,
  'dotted': TextDecorationStyle.dotted,
  'solid': TextDecorationStyle.solid,
  'wavy': TextDecorationStyle.wavy,
  'double': TextDecorationStyle.double,
};

double? _parseDouble(String? value) {
  return value != null ? double.tryParse(value) : null;
}

/// Attempts to parse the [value] as a [colorScheme] named property
/// (e.g. primary, background), or attempts to parse it as a hex value.
///
/// Fallbacks to null.
Color? _parseColor(String? value, ColorScheme colorScheme) {
  return switch (value) {
    null || '' => null,
    'primary' => colorScheme.primary,
    'onPrimary' => colorScheme.onPrimary,
    'primaryContainer' => colorScheme.primaryContainer,
    'onPrimaryContainer' => colorScheme.onPrimaryContainer,
    'secondary' => colorScheme.secondary,
    'onSecondary' => colorScheme.onSecondary,
    'secondaryContainer' => colorScheme.secondaryContainer,
    'onSecondaryContainer' => colorScheme.onSecondaryContainer,
    'tertiary' => colorScheme.tertiary,
    'onTertiary' => colorScheme.onTertiary,
    'tertiaryContainer' => colorScheme.tertiaryContainer,
    'onTertiaryContainer' => colorScheme.onTertiaryContainer,
    'error' => colorScheme.error,
    'onError' => colorScheme.onError,
    'errorContainer' => colorScheme.errorContainer,
    'onErrorContainer' => colorScheme.onErrorContainer,
    'background' => colorScheme.background,
    'onBackground' => colorScheme.onBackground,
    'surface' => colorScheme.surface,
    'onSurface' => colorScheme.onSurface,
    'surfaceVariant' => colorScheme.surfaceVariant,
    'onSurfaceVariant' => colorScheme.onSurfaceVariant,
    'outline' => colorScheme.outline,
    'outlineVariant' => colorScheme.outlineVariant,
    'shadow' => colorScheme.shadow,
    'scrim' => colorScheme.scrim,
    'inverseSurface' => colorScheme.inverseSurface,
    'onInverseSurface' => colorScheme.onInverseSurface,
    'inversePrimary' => colorScheme.inversePrimary,
    'surfaceTint' => colorScheme.surfaceTint,
    _ => _parseColorByHex(value),
  };
}

final _hexPattern = RegExp('[a-zA-Z0-9]');

Color? _parseColorByHex(String hex) {
  var hexStr = hex.toUpperCase().trim();
  if (!_hexPattern.hasMatch(hexStr)) return null;

  // auto adding implicit alpha value
  if (hexStr.length < 8) {
    hexStr = 'FF$hexStr';
  }
  final colorValue = int.tryParse(hexStr, radix: 16);
  return colorValue != null ? Color(colorValue) : null;
}
