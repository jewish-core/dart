// Copyright (c) Shmulik Kravitz. Licensed under the MIT license.
//
// Ported from src/jewishDate.ts.

import 'date_utils.dart';
import 'format.dart';
import 'interfaces.dart';

/// Whether Hebrew [year] has thirteen months (Adar I and Adar II): years 3, 6,
/// 8, 11, 14, 17 and 19 of the 19-year cycle.
bool isLeapYear(int year) => const {0, 3, 6, 8, 11, 14, 17}.contains(year % 19);

/// The npm package's month index: Nisan = 1 … Elul = 6, Tishri = 7 … Adar = 12,
/// Adar II = 13. Adar I shares 12 with Adar.
int getIndexByJewishMonth(JewishMonth month) => switch (month) {
  JewishMonth.none => 0,
  JewishMonth.tishri => 7,
  JewishMonth.cheshvan => 8,
  JewishMonth.kislev => 9,
  JewishMonth.tevet => 10,
  JewishMonth.shevat => 11,
  JewishMonth.adar || JewishMonth.adarI => 12,
  JewishMonth.adarII => 13,
  JewishMonth.nisan => 1,
  JewishMonth.iyyar => 2,
  JewishMonth.sivan => 3,
  JewishMonth.tammuz => 4,
  JewishMonth.av => 5,
  JewishMonth.elul => 6,
};

const _monthsByIndex = [
  JewishMonth.none,
  JewishMonth.nisan,
  JewishMonth.iyyar,
  JewishMonth.sivan,
  JewishMonth.tammuz,
  JewishMonth.av,
  JewishMonth.elul,
  JewishMonth.tishri,
  JewishMonth.cheshvan,
  JewishMonth.kislev,
  JewishMonth.tevet,
  JewishMonth.shevat,
  JewishMonth.adar,
  JewishMonth.adarII,
];

/// The month at the npm month [index] (Nisan = 1, see [getIndexByJewishMonth]).
/// Index 12 is [JewishMonth.adarI] in a leap [jewishYear], [JewishMonth.adar]
/// otherwise; an unknown index gives [JewishMonth.none].
JewishMonth getJewishMonthByIndex(int index, int jewishYear) {
  final month = index >= 0 && index < _monthsByIndex.length ? _monthsByIndex[index] : JewishMonth.none;
  if (month == JewishMonth.adar && isLeapYear(jewishYear)) return JewishMonth.adarI;
  return month;
}

/// Months in year order from Tishri, with [JewishMonth.none] at index 0.
/// A regular year has Adar; a leap year has Adar I and Adar II.
List<JewishMonth> getJewishMonthsInOrder(int year) {
  const inOrder = [
    JewishMonth.none,
    JewishMonth.tishri,
    JewishMonth.cheshvan,
    JewishMonth.kislev,
    JewishMonth.tevet,
    JewishMonth.shevat,
    JewishMonth.adarI,
    JewishMonth.adarII,
    JewishMonth.nisan,
    JewishMonth.iyyar,
    JewishMonth.sivan,
    JewishMonth.tammuz,
    JewishMonth.av,
    JewishMonth.elul,
  ];
  if (isLeapYear(year)) return inOrder;
  return [
    for (final m in inOrder)
      if (m != JewishMonth.adarII) m == JewishMonth.adarI ? JewishMonth.adar : m,
  ];
}

/// [date] in English, by [pattern] (default `d MMMM yyyy`: "10 Tishri 5786").
///
/// Tokens: `d`/`D` day, `dd` zero-padded day, `M`/`MM` month position from
/// Tishri, `MMMM` month name, `yyyy`/`YYYY` year, `yy`/`YY` its last two digits.
String formatJewishDate(JewishDate date, [String? pattern]) => formatWithPattern(pattern ?? defaultPattern, (
  day: date.day,
  month: date.month,
  monthName: date.monthName.npmName,
  year: date.year,
), englishFormatters);

/// The Hebrew date of the Gregorian [date].
///
/// Only the calendar date of [date] is used (year, month, day), whatever its
/// time zone. The Hebrew day changes at nightfall, not at midnight: after
/// nightfall, pass the next day.
JewishDate toJewishDate(DateTime date) {
  final jd = gregorianToJd(date.year, date.month, date.day);
  final (year, monthIndex, day) = jdToHebrew(jd);
  final monthName = getJewishMonthByIndex(monthIndex, year);
  return JewishDate(year: year, monthName: monthName, month: getJewishMonthsInOrder(year).indexOf(monthName), day: day);
}

/// The Gregorian calendar date, as a UTC midnight [DateTime].
///
/// The npm package returns a local-time Date and resets its hours only when
/// they are non-zero, so a call made between 00:00 and 00:59 keeps the minutes.
/// Here the time is always midnight.
DateTime toGregorianDate(BasicJewishDate date) {
  final jd = hebrewToJd(date.year, getIndexByJewishMonth(date.monthName), date.day);
  final (y, m, d) = jdToGregorian(jd);
  return DateTime.utc(y, m, d);
}

/// The number of days, 29 or 30, in [month] of [jewishYear].
int calcDaysInMonth(int jewishYear, JewishMonth month) => hebrewMonthDays(jewishYear, getIndexByJewishMonth(month));
