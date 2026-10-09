/// Dart port of the `jewish-holidays` npm package, version 2.0.1.
///
/// Pure Dart, no Flutter. Every check takes a Hebrew date; convert a
/// Gregorian one with `toJewishDate` from `jewish_date`, or use
/// [getDateInfoForGregorian]. See README.md for the name mapping.
library;

export 'src/holidays.dart';
