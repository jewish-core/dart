# jewish_zmanim

[![pub package](https://img.shields.io/pub/v/jewish_zmanim.svg)](https://pub.dev/packages/jewish_zmanim)
[![CI](https://github.com/jewish-core/dart/actions/workflows/ci.yaml/badge.svg)](https://github.com/jewish-core/dart/actions/workflows/ci.yaml)

Compute halachic times (zmanim) for a city: dawn, sunrise, the latest times for Shema and Tefila, midday,
sunset, nightfall and candle lighting. It can also tell you whether it is Shabbat or Yom Tov at a given
moment. Every time is in the city's own time zone, whatever the device's time zone. Pure Dart, works in
Flutter, on the server and on the web.

Part of [jewish-core](https://github.com/jewish-core). Also on npm as [`jewish-zmanim`](https://www.npmjs.com/package/jewish-zmanim).

## Install

```sh
dart pub add jewish_zmanim
```

## Quick start

```dart
import 'package:jewish_zmanim/jewish_zmanim.dart';

void main() {
  initializeZmanim(); // once, at startup: loads the time-zone database

  final z = Zmanim(NpmCities.jerusalem, 2025, 10, 17); // Friday, Shabbos Bereishis 5786

  print(Zmanim.hms(z.sunrise));        // 6:44:03
  print(Zmanim.hms(z.shkiah));         // 18:04:25
  print(Zmanim.hms(z.candleLighting)); // 17:28:32

  final now = Zmanim.restStatusAt(NpmCities.brooklyn, DateTime.now());
  print(now.isRest); // true during Shabbat or Yom Tov in Brooklyn
}
```

If you call `Zmanim` before `initializeZmanim()`, it throws a `StateError`.

## Usage

### Times

A `Zmanim` holds one Gregorian date in one city. Each time is a `double?`: hours since local midnight in
the city's time zone (`18.07…` means about 18:04). It is `null` when the sun never reaches the angle that
time needs, which happens at high latitudes. Convert a time as you need it:

```dart
z.shkiah;              // 18.0734… (hours)
Zmanim.hms(z.shkiah);  // "18:04:25"
z.at(z.shkiah);        // TZDateTime 2025-10-17 18:04:25 +0300
```

| Getter | |
|---|---|
| `alosHashachar`, `alos72` | dawn, at 16.1° below the horizon / 72 minutes before sunrise |
| `tefillin` | earliest tallis and tefillin, at 11.5° (Israel) or 10.2° (diaspora) |
| `sunrise` | sunrise (netz) |
| `sofZmanShema`, `sofZmanTefila` | latest Shema / Tefila, GRA |
| `sofZmanShemaMGA`, `sofZmanTefilaMGA` | latest Shema / Tefila, Magen Avraham |
| `chatzos`, `chatzosLayla` | midday, midnight |
| `minchaGedola`, `minchaKetana`, `plagHamincha` | |
| `shkiah` (= `sunset`), `shkiahElevated` | sunset at sea level / at the city's elevation |
| `tzeis`, `tzeisRabbeinuTam` | nightfall at 8.5° / 72 minutes after sunset |
| `candleLighting` | `shkiahElevated` minus the city's candle-lighting minutes |
| `shabbosEnter`, `shabbosExit` | this week's candle lighting (Friday) and havdalah (Saturday) |
| `shaahZmanis` | one seasonal hour (GRA) |

### Is it Shabbat or Yom Tov now?

```dart
final status = Zmanim.restStatusAt(NpmCities.jerusalem, DateTime.now());
status.isShabbat;
status.isYomTov;
status.isRest; // either one
```

The rest period runs from candle lighting on the eve until nightfall (`tzeis`). When one Yom Tov day is
followed by another, it continues through both. The moment you pass in is converted to the city's time
zone first, so a server or a traveller's phone gets the right answer.

### Your own city

`NpmCities` contains the npm package's cities (`NpmCities.all`): Jerusalem, Tel Aviv, Haifa, New York,
Brooklyn, Paris, London, Melbourne and others. To use another place, create a `City`:

```dart
const manchester = City(
  id: 'manchester',
  name: 'Manchester',
  latitude: 53.48,
  longitude: -2.24,
  timeZone: 'Europe/London', // IANA name, required
  isIsrael: false,           // one or two Yom Tov days; default candle lighting
  elevation: 0,              // meters, optional
  candleLightingMinutes: 18, // optional: 30 in Israel, 18 elsewhere (Jerusalem uses 40)
);

final z = Zmanim(manchester, 2025, 10, 17);
```

An unknown time-zone name throws instead of silently falling back to UTC.

### Settings

The angles have defaults. Change them with `ZmanimSettings`, which you can pass to both `Zmanim` and
`restStatusAt`:

```dart
final z = Zmanim(manchester, 2025, 10, 17, settings: const ZmanimSettings(tzeisDegrees: 7.083));
```

| Setting | Default | |
|---|---|---|
| `alosDegrees` | 16.1 | dawn |
| `tzeisDegrees` | 8.5 | nightfall |
| `tefillinDegreesIsrael` / `tefillinDegreesDiaspora` | 11.5 / 10.2 | earliest tefillin |
| `fallbackCandleLightingHour` | 12 | when there is no sunset, Shabbat starts at this local hour |
| `fallbackRestEndHour` | 24 | when there is no nightfall, Shabbat lasts until this hour (24 = the whole day) |

The last two settings only apply at high latitudes in summer, where the sun does not set or does not go
low enough for nightfall. The defaults are stringent. Check them with your rabbi.

### The Hebrew date

`Zmanim` takes a Gregorian date. To find the Hebrew date or the holidays of that date, add
[`jewish_date`](https://pub.dev/packages/jewish_date) or [`jewish_holidays`](https://pub.dev/packages/jewish_holidays).

## Coming from npm

The API is a port of [`jewish-zmanim`](https://www.npmjs.com/package/jewish-zmanim) **1.0.6**.

| npm | Dart |
|---|---|
| `Zmanim.fromCityRow(row, date)` | `Zmanim(City, year, month, day)` |
| `getTimes().shkiah` = `"17:19:21"` | `z.shkiah` = `17.3225…` (hours), `Zmanim.hms(z.shkiah)`, `z.at(z.shkiah)` → `TZDateTime` |
| `getTimes().isShabbat` (for the time of the `Date`) | `Zmanim.restStatusAt(city, moment).isShabbat` |
| `CityRow.tz_name` (optional) | `City.timeZone` (required) |
| constants 8.5°, 16.1°, 11.5° / 10.2° | `ZmanimSettings` (same defaults) |

### Deliberate differences

1. **The city's time zone.** npm reads the hour of the `Date` in the device's time zone, but compares it with
   times computed in the city's time zone. Here the moment is converted to the city's time zone first.
2. **High latitudes.** Where the sun never reaches an angle, npm returns `"NaN:NaN:NaN"`. Its rest period
   then either never starts (no candle lighting) or ends at midnight (no tzeis). Here the time is `null`,
   and the rest period uses the stringent fallbacks in `ZmanimSettings`.
3. **Days the clocks change.** npm reads the UTC offset at 00:00 UTC. In Israel that is before the change,
   so on the Friday the clocks move forward, npm gives candle lighting an hour early. Here the offset is
   read at local noon, and Friday and Saturday each use their own offset.
4. **Settings, not constants.** The angles npm hardcodes can be changed through `ZmanimSettings`.
5. **No silent UTC.** npm uses offset 0 when a city has no valid time zone. Here an unknown time zone throws.

`test/npm_parity_test.dart` compares every time with npm's, to the second, for 20 cities over 2025–2026. It
also checks the Shabbat and Yom Tov period on every eve and holy day of 2025 in six cities. It probes every
transition minute, the minute before it, and every half hour. `test/zmanim_test.dart` covers each deliberate
difference.

## License

[MIT](https://github.com/jewish-core/dart/blob/main/LICENSE)
