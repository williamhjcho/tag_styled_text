import 'package:flutter_test/flutter_test.dart';
import 'package:tag_styled_text/src/utils.dart';

void main() {
  test('mergeMaps', () {
    final lhs = {'first': 0, 'conflict': 0};
    final rhs = {'second': 1, 'conflict': 1};

    expect(mergeMaps({}, {}), isEmpty);
    expect(mergeMaps(lhs, {}), same(lhs));
    expect(mergeMaps({}, rhs), same(rhs));

    expect(mergeMaps(lhs, lhs), isNot(same(lhs)));
    expect(mergeMaps(lhs, lhs), equals(lhs));

    expect(mergeMaps(lhs, rhs), {'first': 0, 'second': 1, 'conflict': 1});
  });
}
