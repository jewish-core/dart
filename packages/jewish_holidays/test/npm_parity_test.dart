// Parity with the npm package: fixtures from tools/npm-parity/generate.mjs.
import 'dart:convert';
import 'dart:io';

import 'package:jewish_holidays/jewish_holidays.dart';
import 'package:test/test.dart';

void main() {
  final fx = jsonDecode(File('test/fixtures/npm_jewish_holidays.json').readAsStringSync()) as Map<String, dynamic>;

  String bits(DateInfo i) => [
    i.isYomTov,
    i.isErevYomTov,
    i.isCholHaMoed,
    i.isShabbat,
    i.isErevShabbat,
    i.isRoshChodesh,
    i.isChanukah,
    i.isPurim,
    i.isTzom,
  ].map((b) => b ? '1' : '0').join();

  test('getDateInfo matches npm every day for 13 years, Israel and diaspora', () {
    final rows = fx['rows'] as List;
    expect(rows.length, greaterThan(4700));
    for (final r in rows) {
      final d = DateTime.parse(r[0] as String);
      final il = getDateInfoForGregorian(d);
      final cl = getDateInfoForGregorian(d, isChutzLaaretz: true);
      final he = getDateInfoForGregorian(d, isChutzLaaretz: true, language: Language.he);
      final actual = [r[0], bits(il), bits(cl), il.holidays, cl.holidays, he.holidays, cl.tzom?.shift?.name];
      expect(actual, r, reason: r[0] as String);
    }
  });
}
