# jewish_holidays

[![pub package](https://img.shields.io/pub/v/jewish_holidays.svg)](https://pub.dev/packages/jewish_holidays)
[![CI](https://github.com/jewish-core/dart/actions/workflows/ci.yaml/badge.svg)](https://github.com/jewish-core/dart/actions/workflows/ci.yaml)

Find out what a day is in the Jewish calendar: Shabbat, Yom Tov, Chol HaMoed, Rosh Chodesh, Chanukah, Purim
or a fast day. Covers Israel and the diaspora, with names in English or Hebrew. Pure Dart, works in Flutter,
on the server and on the web.

Part of [jewish-core](https://github.com/jewish-core). Also on npm as [`jewish-holidays`](https://www.npmjs.com/package/jewish-holidays).

## Install

```sh
dart pub add jewish_holidays
```

## Quick start

```dart
import 'package:jewish_holidays/jewish_holidays.dart';

void main() {
  final info = getDateInfoForGregorian(DateTime(2025, 10, 2));

  print(info.jewishDate); // 10 Tishri 5786
  print(info.holidays);   // [Yom Kippur]
  print(info.isYomTov);   // true
}
```

## Usage

### Israel or the diaspora

The default is Israel. Pass `isChutzLaaretz: true` for the diaspora, where some festivals have a second day:

```dart
final day = DateTime(2025, 10, 8); // 16 Tishri

getDateInfoForGregorian(day).holidays;                       // [Chol HaMoed]
getDateInfoForGregorian(day, isChutzLaaretz: true).holidays; // [Sukkot]
```

### Hebrew names

```dart
getDateInfoForGregorian(day, language: Language.he).holidays; // [חול המועד]
```

### Everything about a day

`getDateInfo` (for a Hebrew date) and `getDateInfoForGregorian` (for a `DateTime`) return a `DateInfo`:

| Field | |
|---|---|
| `jewishDate` | the Hebrew date |
| `holidays` | the name of each observance of the day, in a fixed order |
| `isShabbat`, `isErevShabbat` | Saturday, Friday |
| `isYomTov`, `isErevYomTov`, `isCholHaMoed` | festival days and their eves |
| `isRoshChodesh`, `isChanukah`, `isPurim` | |
| `isTzom`, `tzom` | a fast day, and its name and whether it was moved because of Shabbat |

```dart
final info = getDateInfoForGregorian(DateTime(2025, 8, 3));
info.holidays;    // [Tisha BeAv]
info.tzom!.shift; // TzomShift.postponed: 9 Av fell on Shabbat
```

### Single checks

Each check takes a Hebrew date. Get one with `toJewishDate` from
[`jewish_date`](https://pub.dev/packages/jewish_date), or build a `BasicJewishDate` yourself:

```dart
import 'package:jewish_date/jewish_date.dart';
import 'package:jewish_holidays/jewish_holidays.dart';

final date = toJewishDate(DateTime(2025, 12, 21)); // 1 Tevet 5786

isChanukah(date);                     // true
isRoshChodesh(date);                  // true
isYomTov(date, isChutzLaaretz: true); // false
getTzomInfo(date);                    // null
```

Also available: `isShabbat`, `isErevShabbat`, `isErevYomTov`, `isCholHaMoed`, `isPurim` and `isTzom`.
`getYomTovList`, `getPurimList` and `getTzomotList` return the underlying lists.

To use `jewish_date` directly, add it too: `dart pub add jewish_date`.

### Which day starts when

These functions work with whole calendar days. A Jewish day starts at nightfall, and Shabbat starts at
candle lighting. To find out whether it is Shabbat or Yom Tov at a given moment, use
`Zmanim.restStatusAt` from [`jewish_zmanim`](https://pub.dev/packages/jewish_zmanim).

## Coming from npm

The API is a port of [`jewish-holidays`](https://www.npmjs.com/package/jewish-holidays) **2.0.1**. Function
names are the same, apart from these changes:

| npm | Dart |
|---|---|
| `isYomTov(date: Date \| BasicJewishDate, isChutzLaaretz)` | `isYomTov(BasicJewishDate, isChutzLaaretz:)`: convert a `DateTime` with `toJewishDate` |
| `getDateInfo(date, isChutzLaaretz, language)` | `getDateInfo(BasicJewishDate, ...)` or `getDateInfoForGregorian(DateTime, ...)` |
| `tzom.shift: "postponed"` | `TzomShift.postponed` |
| `Language "en" \| "he"` | `Language.en` / `Language.he` |

The holiday lists and their quirks are the same as in npm, so the two packages stay interchangeable. For
example, 1 Tishri counts as Rosh Chodesh, and in the diaspora 22 Tishri is named "Simchat Torah".

`test/npm_parity_test.dart` compares `getDateInfo` with the npm package's output for every day of 13 years.
It covers Israel and the diaspora, in English and in Hebrew.

## License

[MIT](https://github.com/jewish-core/dart/blob/main/LICENSE)
