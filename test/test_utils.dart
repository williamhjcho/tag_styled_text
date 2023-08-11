import 'dart:math';

final Random random = Random();

extension RandomExtensions on Random {
  /// Assumes that the list is not empty
  T nextItem<T>(Iterable<T> items) {
    final index = nextInt(items.length);
    return items.elementAt(index);
  }
}
