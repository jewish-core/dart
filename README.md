# jewish-core for Dart

[![CI](https://github.com/jewish-core/dart/actions/workflows/ci.yaml/badge.svg)](https://github.com/jewish-core/dart/actions/workflows/ci.yaml)

Hebrew calendar, Jewish holidays and zmanim in pure Dart. They work in Flutter, on the server and on the
web. Part of [jewish-core](https://github.com/jewish-core): the same libraries are on
[npm](https://www.npmjs.com/~shmulik.kravitz) and pub.dev, and both are tested against the same data.

## Which package do I need?

| Package | | Use it to |
|---|---|---|
| [`jewish_date`](packages/jewish_date) | [![pub](https://img.shields.io/pub/v/jewish_date.svg)](https://pub.dev/packages/jewish_date) | convert between Gregorian and Hebrew dates, and write them in Hebrew letters |
| [`jewish_holidays`](packages/jewish_holidays) | [![pub](https://img.shields.io/pub/v/jewish_holidays.svg)](https://pub.dev/packages/jewish_holidays) | tell whether a day is Shabbat, Yom Tov, Chol HaMoed, Rosh Chodesh, Chanukah, Purim or a fast day |
| [`jewish_zmanim`](packages/jewish_zmanim) | [![pub](https://img.shields.io/pub/v/jewish_zmanim.svg)](https://pub.dev/packages/jewish_zmanim) | compute sunrise, sunset, nightfall and candle lighting, and tell whether it is Shabbat now |

`jewish_holidays` depends on `jewish_date`, and `jewish_zmanim` depends on both. Add only the ones you
import:

```sh
dart pub add jewish_date jewish_holidays jewish_zmanim
```

## Getting started

```dart
import 'package:jewish_date/jewish_date.dart';
import 'package:jewish_holidays/jewish_holidays.dart';
import 'package:jewish_zmanim/jewish_zmanim.dart';

void main() {
  initializeZmanim(); // once, before any zmanim

  final today = DateTime(2025, 10, 17);

  // The Hebrew date
  final date = toJewishDate(today);
  print(formatJewishDate(date));         // 25 Tishri 5786
  print(formatJewishDateInHebrew(date)); // כ״ה תשרי התשפ״ו

  // What day it is
  final info = getDateInfo(date);
  print(info.isErevShabbat);             // true

  // The times in Jerusalem
  final z = Zmanim(NpmCities.jerusalem, today.year, today.month, today.day);
  print(Zmanim.hms(z.candleLighting));   // 17:28:32
  print(Zmanim.hms(z.shabbosExit));      // havdalah on Saturday

  // Is it Shabbat in Jerusalem right now?
  print(Zmanim.restStatusAt(NpmCities.jerusalem, DateTime.now()).isRest);
}
```

Each package README has the full guide:
[jewish_date](packages/jewish_date/README.md), [jewish_holidays](packages/jewish_holidays/README.md) and
[jewish_zmanim](packages/jewish_zmanim/README.md).

## Parity with npm

The JavaScript packages are the reference implementation. Each Dart package has a `test/npm_parity_test.dart`
that checks it against JSON fixtures generated from its npm counterpart. Each CHANGELOG entry names the npm
version it was checked against. Where the Dart package differs on purpose, its README lists each difference
and the reason for it.

## Halachic note

These libraries compute times and dates by fixed, documented rules. They are not a substitute for a halachic
ruling. Check the method in each README against your community's practice.

## Development

Dart 3.9 or later. This repository is a [pub workspace](https://dart.dev/tools/pub/workspaces):

```sh
dart pub get                 # once, at the root: links the three packages
dart format .
dart analyze --fatal-infos
for p in packages/*/; do (cd "$p" && dart test); done
```

Run the tests from inside each package, as the loop does, because the tests load their fixtures from
`test/fixtures/`. See [CONTRIBUTING.md](CONTRIBUTING.md) for pull requests and releases.

## License

[MIT](LICENSE)
