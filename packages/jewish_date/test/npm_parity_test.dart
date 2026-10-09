// Parity with the npm package: fixtures from tools/npm-parity/generate.mjs.
import 'dart:convert';
import 'dart:io';

import 'package:jewish_date/jewish_date.dart';
import 'package:test/test.dart';

String iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() {
  final fx = jsonDecode(File('test/fixtures/npm_jewish_date.json').readAsStringSync()) as Map<String, dynamic>;

  test('toJewishDate and Hebrew formatting match npm', () {
    final rows = fx['toJewish'] as List;
    expect(rows.length, greaterThan(5000));
    for (final r in rows) {
      final d = DateTime.parse(r[0] as String);
      final j = toJewishDate(d);
      final actual = [iso(d), j.year, j.monthName.npmName, j.month, j.day, formatJewishDateInHebrew(j)];
      expect(actual, r, reason: r[0] as String);
    }
  });

  test('toGregorianDate and calcDaysInMonth match npm', () {
    for (final r in fx['toGregorian'] as List) {
      final month = JewishMonth.fromNpmName(r[1] as String);
      final date = BasicJewishDate(year: r[0] as int, monthName: month, day: r[2] as int);
      expect(iso(toGregorianDate(date)), r[3], reason: '$date');
      expect(calcDaysInMonth(r[0] as int, month), r[4], reason: '$date');
    }
  });

  test('gematria matches npm', () {
    for (final r in fx['gematria'] as List) {
      final n = r[0] as int;
      expect(convertNumberToHebrew(n), r[1], reason: '$n');
      expect(convertNumberToHebrew(n, addGeresh: false, addPunctuate: false), r[2], reason: '$n');
      expect(convertYearToShortHebrew(n), r[3], reason: '$n');
    }
  });

  test('pattern formatting matches npm', () {
    final f = fx['formats'] as Map<String, dynamic>;
    final j = toJewishDate(DateTime.parse(f['date'] as String));
    for (final r in f['rows'] as List) {
      expect(formatJewishDate(j, r[0] as String), r[1], reason: r[0] as String);
      expect(formatJewishDateInHebrew(j, r[0] as String), r[2], reason: r[0] as String);
    }
  });
}
