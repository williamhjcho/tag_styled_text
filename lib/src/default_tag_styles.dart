import 'package:flutter/widgets.dart';
import 'package:tag_styled_text/src/utils.dart';

import 'span_tags.dart';

/// Inserts default properties for [TagStyledText] in a widget subtree.
///
/// To insert more common styles in parts of the application, use [merge] so
/// all descendants can include all of the ancestor's values as well.
class DefaultTagStyles extends InheritedTheme {
  const DefaultTagStyles({
    super.key,
    required this.tags,
    required super.child,
  });

  const DefaultTagStyles.fallback({super.key})
      : tags = const {},
        super(child: const _NullWidget());

  /// Merges the current (parent) [DefaultTagStyles] with the values
  /// from this new node.
  ///
  /// If there are any conflicting values, they are overridden in favor of the
  /// new instance, while maintaining the ancestors' as is.
  static Widget merge({
    Key? key,
    required Map<String, SpanTag> tags,
    required Widget child,
  }) {
    return Builder(builder: (context) {
      final parent = DefaultTagStyles.of(context);

      return DefaultTagStyles(
        key: key,
        tags: mergeMaps(parent.tags, tags),
        child: child,
      );
    });
  }

  /// A collection of default [SpanTag] builders that are provided to the
  /// [TagStyledText] descendants from this widget.
  ///
  /// Defaults to empty.
  final Map<String, SpanTag> tags;

  @override
  Widget wrap(BuildContext context, Widget child) {
    final current = context.findAncestorWidgetOfExactType<DefaultTagStyles>();
    return identical(this, current)
        ? child
        : DefaultTagStyles(tags: tags, child: child);
  }

  @override
  bool updateShouldNotify(DefaultTagStyles oldWidget) {
    return tags != oldWidget.tags;
  }

  /// Retrieves the closest vales in the widget tree.
  ///
  /// If none are found in [context], then returns
  /// [DefaultTagStyles.fallback].
  static DefaultTagStyles of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DefaultTagStyles>() ??
        const DefaultTagStyles.fallback();
  }
}

class _NullWidget extends StatelessWidget {
  const _NullWidget();

  @override
  Widget build(BuildContext context) {
    throw FlutterError(
      'A $DefaultTagStyles constructed with '
      '$DefaultTagStyles.fallback cannot be incorporated into the '
      'widget tree, it is meant only to provide a fallback value returned by '
      'DefaultTagStyles.of() when no enclosing default value is '
      'present in a BuildContext.',
    );
  }
}
