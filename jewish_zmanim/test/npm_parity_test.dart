// Parity with the npm package: fixtures from tools/npm-parity/generate.mjs.
//
// The fixtures were generated with the device time zone set to each city's
// (TZ=...), so npm's device-time bug does not show in them. What still differs
// on purpose is checked separately below: days whose UTC offset changes, and
// days where the sun never reaches an angle.
import 'dart:convert';
import 'dart:io';

import 'package:jewish_zmanim/jewish_zmanim.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' as tz;

/// Cities the fixtures add beyond the npm list: high latitude and south.
const extraCities = {
  'reykjavik': City(
    id: 'reykjavik',
    name: 'Reykjavik',
    latitude: 64.1466,
    longitude: -21.9426,
    timeZone: 'Atlantic/Reykjavik',
    isIsrael: false,
  ),
  'tromso': City(
    id: 'tromso',
    name: 'Tromso',
    latitude: 69.6492,
    longitude: 18.9553,
    timeZone: 'Europe/Oslo',
    isIsrael: false,
  ),
  'buenosAires': City(
    id: 'buenosAires',
    name: 'Buenos Aires',
    latitude: -34.6037,
    longitude: -58.3816,
    timeZone: 'America/Argentina/Buenos_Aires',
    isIsrael: false,
  ),
};

City cityById(String id) => NpmCities.all.where((c) => c.id == id).firstOrNull ?? extraCities[id]!;

/// npm rounding per key: most times round up, a few down (toTime 'floor').
const floorKeys = {'kriasShema', 'sofZmanShemaMGA', 'tefila', 'plagHamincha'};

double? portValue(Zmanim z, String key) => switch (key) {
  'alosHashachar' => z.alosHashachar,
  'tefillin' => z.tefillin,
  'netzHachama' => z.sunrise,
  'kriasShema' => z.sofZmanShema,
  'sofZmanShemaMGA' => z.sofZmanShemaMGA,
  'tefila' => z.sofZmanTefila,
  'chatzos' => z.chatzos,
  'minchaGedola' => z.minchaGedola,
  'plagHamincha' => z.plagHamincha,
  'shkiah' => z.shkiah,
  'shkiahElevated' => z.shkiahElevated,
  'tzesHakochavim' => z.tzeis,
  'tzeisRT' => z.tzeisRabbeinuTam,
  'shabbosEnter' => z.shabbosEnter,
  'shabbosExit' => z.shabbosExit,
  _ => throw ArgumentError(key),
};

int? seconds(double? hours, {required bool floor}) =>
    hours == null ? null : (floor ? (hours * 3600).floor() : (hours * 3600).ceil());

void main() {
  initializeZmanim();
  final fx = jsonDecode(File('test/fixtures/npm_jewish_zmanim.json').readAsStringSync()) as Map<String, dynamic>;
  final keys = (fx['timeKeys'] as List).cast<String>();
  final cities = fx['cities'] as Map<String, dynamic>;

  for (final MapEntry(key: id, value: data) in cities.entries) {
    final city = cityById(id);
    final rows = (data as Map<String, dynamic>)['times'] as List;

    test('$id: times match npm to the second', () {
      var compared = 0, offsetDays = 0;
      for (final r in rows) {
        final date = DateTime.parse(r[0] as String);
        final z = Zmanim(city, date.year, date.month, date.day);
        final npmOffset = (r[1] as num).toDouble();
        // npm reads the offset at 00:00 UTC, the port at local noon: they
        // differ only on the day the clocks change
        if (z.utcOffsetHours != npmOffset) {
          offsetDays++;
          continue;
        }
        final fridayOffset = Zmanim(
          city,
          z.shabbosEnterDate.year,
          z.shabbosEnterDate.month,
          z.shabbosEnterDate.day,
        ).utcOffsetHours;
        final saturdayOffset = Zmanim(
          city,
          z.shabbosExitDate.year,
          z.shabbosExitDate.month,
          z.shabbosExitDate.day,
        ).utcOffsetHours;
        for (var k = 0; k < keys.length; k++) {
          final key = keys[k];
          // npm computes Friday and Saturday with today's offset; the port with their own
          if (key == 'shabbosEnter' && fridayOffset != npmOffset) continue;
          if (key == 'shabbosExit' && saturdayOffset != npmOffset) continue;
          final expected = r[2 + k] as int?;
          final actual = seconds(portValue(z, key), floor: floorKeys.contains(key));
          if (expected == null || actual == null) {
            expect(actual, expected, reason: '$id ${r[0]} $key');
          } else {
            expect((actual - expected).abs(), lessThanOrEqualTo(1), reason: '$id ${r[0]} $key: $actual vs $expected');
          }
          compared++;
        }
        if (fridayOffset == npmOffset && z.shabbosEnter != null) {
          final unix = z.at(z.shabbosEnter, on: z.shabbosEnterDate)!;
          expect(
            (unix.millisecondsSinceEpoch ~/ 1000 - (r[2 + keys.length] as int)).abs(),
            lessThanOrEqualTo(1),
            reason: '$id ${r[0]} shabbosEnterUnix',
          );
        }
      }
      expect(compared, greaterThan(rows.length * 10));
      expect(offsetDays, lessThanOrEqualTo(8), reason: 'offset differs only around clock changes');
    });

    final rest = data['rest'] as List;
    if (rest.isEmpty) continue;

    test('$id: the Shabbat / Yom Tov window matches npm minute by minute', () {
      final loc = tz.getLocation(city.timeZone);
      final npmOffset = {for (final r in rows) r[0] as String: (r[1] as num).toDouble()};
      var checked = 0, compared = 0, fallbackDays = 0;
      for (final day in rest) {
        final date = DateTime.parse(day[0] as String);
        final z = Zmanim(city, date.year, date.month, date.day);
        if (z.tzeis == null || z.candleLighting == null) {
          fallbackDays++; // npm has NaN here; the port's fallback is tested in zmanim_test.dart
          continue;
        }
        // On the day the clocks change npm is an hour off; see zmanim_test.dart
        if (npmOffset[day[0]] != z.utcOffsetHours) continue;
        compared++;
        final transitions = (day[1] as List).cast<List>();
        bool npmShabbat(int minute) => transitions.lastWhere((t) => (t[0] as int) <= minute)[1] as bool;
        bool npmYomTov(int minute) => transitions.lastWhere((t) => (t[0] as int) <= minute)[2] as bool;
        final probes = <int>{
          for (var m = 0; m < 1440; m += 30) m,
          for (final t in transitions) ...[t[0] as int, (t[0] as int) - 1],
        }.where((m) => m >= 0 && m < 1440);
        for (final minute in probes) {
          final at = tz.TZDateTime(loc, date.year, date.month, date.day, 0, minute);
          if (at.day != date.day || at.hour * 60 + at.minute != minute) continue; // clock change
          final s = Zmanim.restStatusAt(city, at);
          expect(
            [s.isShabbat, s.isYomTov],
            [npmShabbat(minute), npmYomTov(minute)],
            reason: '$id ${day[0]} ${at.hour}:${at.minute.toString().padLeft(2, '0')}',
          );
          checked++;
        }
      }
      expect(checked, greaterThan(compared * 40));
      expect(compared + fallbackDays, greaterThan(rest.length - 20));
      if (id != 'reykjavik') expect(fallbackDays, 0);
    });
  }
}
