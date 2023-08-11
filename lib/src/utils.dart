/// Merges [lhs] and [rhs] into a single [Map].
///
/// Special cases:
/// * if either [lhs] or [rhs] is empty, returns the other value.
/// * otherwise merges both into a new map, with [rhs] overriding any conflicts.
Map<K, V> mergeMaps<K, V>(Map<K, V>? lhs, Map<K, V>? rhs) {
  if (lhs == null || lhs.isEmpty) return rhs ?? {};
  if (rhs == null || rhs.isEmpty) return lhs;
  return {...lhs, ...rhs};
}
