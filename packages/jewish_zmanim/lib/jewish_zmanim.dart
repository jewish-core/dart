/// Dart port of the `jewish-zmanim` npm package, version 1.0.6.
///
/// Pure Dart, no Flutter. Differences from the npm package, all deliberate:
///
/// 1. Every moment is read in the city's time zone, never the device's.
/// 2. A time the sun never reaches is `null`, not `"NaN:NaN:NaN"`, and the
///    rest window falls back to a stringent rule ([ZmanimSettings]).
/// 3. Times are fractional hours and [TZDateTime]s, not `"H:MM:SS"` strings.
/// 4. Nightfall degrees and candle-lighting minutes are parameters.
/// 5. A city must name its IANA time zone; there is no silent fallback to UTC.
///
/// Call [initializeZmanim] once before use.
library;

export 'src/city.dart';
export 'src/solar.dart' show calcSunTimes, sunriseZenith, elevatedZenith;
export 'src/zmanim.dart';
