# jewish_date

[![pub package](https://img.shields.io/pub/v/jewish_date.svg)](https://pub.dev/packages/jewish_date)
[![CI](https://github.com/jewish-core/dart/actions/workflows/ci.yaml/badge.svg)](https://github.com/jewish-core/dart/actions/workflows/ci.yaml)

Convert between Gregorian and Hebrew (Jewish) dates, and format them in English or Hebrew letters. Pure Dart,
works in Flutter, on the server and on the web.

Part of [jewish-core](https://github.com/jewish-core). Also on npm as [`jewish-date`](https://www.npmjs.com/package/jewish-date).

## Install

```sh
dart pub add jewish_date
```

## Quick start

```dart
import 'package:jewish_date/jewish_date.dart';

void main() {
  final date = toJewishDate(DateTime(2025, 10, 2));

  print(date);                           // 10 Tishri 5786
  print(formatJewishDate(date));         // 10 Tishri 5786
  print(formatJewishDateInHebrew(date)); // י׳ תשרי התשפ״ו
}
```

## Usage

### Gregorian → Hebrew

`toJewishDate` reads only the calendar date of the `DateTime`; the time of day and time zone are ignored.
(To decide whether it is already evening, and so the next Hebrew day, use the sunset time from
[`jewish_zmanim`](https://pub.dev/packages/jewish_zmanim).)

```dart
final date = toJewishDate(DateTime(2025, 10, 2));
date.day;       // 10
date.monthName; // JewishMonth.tishri
date.month;     // 1, the month's position in the year, counting from Tishri
date.year;      // 5786
```

### Hebrew → Gregorian

```dart
final roshHashanah = BasicJewishDate(year: 5787, monthName: JewishMonth.tishri, day: 1);
toGregorianDate(roshHashanah); // 2026-09-12 00:00:00.000Z
```

The result is always midnight UTC; read `.year`, `.month` and `.day` from it.

### Formatting

```dart
formatJewishDate(date, 'dd/MM/yyyy');     // 10/01/5786
formatJewishDateInHebrew(date, 'D MMMM'); // י׳ תשרי
```

| Token | English | Hebrew |
|---|---|---|
| `d` / `dd` | day, `10` / zero-padded | same |
| `D` | day, `10` | day in letters, `י׳` |
| `M` / `MM` | month number from Tishri, `1` / `01` | month number from Nisan, `7` / `07` |
| `MMMM` | month name, `Tishri` | month name, `תשרי` |
| `yyyy` | year, `5786` | same |
| `YYYY` | year, `5786` | year in letters, `התשפ״ו` |
| `yy` / `YY` | last two digits, `86` | `86` / `פ״ו` |

The defaults are `d MMMM yyyy` and `D MMMM YYYY`.

### Numbers in Hebrew letters (gematria)

```dart
convertNumberToHebrew(5786);                   // התשפ״ו
convertNumberToHebrew(5786, addGeresh: false); // התשפ"ו
convertYearToShortHebrew(5786);                // פ״ו
```

### Months and years

```dart
isLeapYear(5787);                             // true: has Adar I and Adar II
calcDaysInMonth(5786, JewishMonth.kislev);    // 30
getJewishMonthsInOrder(5787);                 // [none, tishri, cheshvan, …, adarI, adarII, nisan, …]
getJewishMonthInHebrew(JewishMonth.adarII);   // אדר ב
```

In a common year the twelfth month is `JewishMonth.adar`. In a leap year it is `adarI` and `adarII`.

## Coming from npm

The API is a port of [`jewish-date`](https://www.npmjs.com/package/jewish-date) **2.0.29**. Function names are
the same, apart from these changes:

| npm | Dart |
|---|---|
| `JewishMonth.Tishri` (string) | `JewishMonth.tishri` (enum); `.npmName` gives `"Tishri"` |
| `toJewishDate(date)` | `toJewishDate(DateTime)`: only the calendar date is read |
| `toGregorianDate(jd)` | `toGregorianDate(BasicJewishDate)`: returns a UTC-midnight `DateTime` |
| `convertNumberToHebrew(n, geresh, punctuate)` | `convertNumberToHebrew(n, addGeresh:, addPunctuate:)` |

**Deliberate difference:** npm's `toGregorianDate` keeps the minutes of the time it was called if that time
falls between 00:00 and 00:59, because it only resets the hours when they are not zero. Here the time is
always midnight.

`test/npm_parity_test.dart` compares the output with the npm package's for about 7,800 dates. Those dates
cover Hebrew years 5560–5994. The test also checks month lengths, gematria and every format token.

## License

[MIT](https://github.com/jewish-core/dart/blob/main/LICENSE)
