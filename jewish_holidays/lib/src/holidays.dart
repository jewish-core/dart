// Copyright (c) Shmulik kravitz. All rights reserved. Licensed under the MIT license.
//
// Ported from src/*/*.ts of jewish-holidays 2.0.1. The npm functions accept a
// Date or a BasicJewishDate; here they take a BasicJewishDate.

import 'package:jewish_date/jewish_date.dart';

/// The language of holiday names.
enum Language {
  /// English transliteration: "Rosh Hashanah".
  en,

  /// Hebrew: "ראש השנה".
  he,
}

/// A day in a holiday list: a fixed day and month, with its names.
class Holiday {
  /// A holiday on [day] of [monthName].
  const Holiday(this.day, this.monthName, this.name, this.hebrewName);

  /// Day of the month.
  final int day;

  /// The month.
  final JewishMonth monthName;

  /// The English name.
  final String name;

  /// The Hebrew name.
  final String hebrewName;

  /// [name] or [hebrewName], by [language].
  String nameIn(Language language) => language == Language.he ? hebrewName : name;
}

/// Where a fast moves when its date falls on Shabbat.
enum TzomShift {
  /// To the next day, Sunday.
  postponed,

  /// Back to Thursday.
  advanced,
}

/// A fast day in [getTzomotList].
class Tzom extends Holiday {
  /// A fast on [day] of [monthName] that moves by [shiftOnShabbat].
  const Tzom(super.day, super.monthName, super.name, super.hebrewName, this.shiftOnShabbat);

  /// Where the fast moves when it falls on Shabbat; null if it never moves.
  final TzomShift? shiftOnShabbat;
}

/// The fast observed on a date, from [getTzomInfo].
class TzomInfo {
  /// A fast named [name], moved by [shift] or on its own date.
  const TzomInfo(this.name, this.shift);

  /// The fast's name, in the requested language.
  final String name;

  /// How the fast moved off Shabbat to this date; null if it is on its own date.
  final TzomShift? shift;

  @override
  bool operator ==(Object other) => other is TzomInfo && other.name == name && other.shift == shift;

  @override
  int get hashCode => Object.hash(name, shift);
}

// ─── holiday ──────────────────────────────────────────────────────────────────

/// The name of [holiday] in [language].
String getHolidayName(Holiday holiday, [Language language = Language.en]) => holiday.nameIn(language);

/// The entries of [list] that fall on [date] (same day and month, any year).
List<Holiday> getHolidaysForDate(BasicJewishDate date, List<Holiday> list) =>
    list.where((h) => h.day == date.day && h.monthName == date.monthName).toList();

/// Whether any entry of [list] falls on [date].
bool isDateInHolidayList(BasicJewishDate date, List<Holiday> list) => getHolidaysForDate(date, list).isNotEmpty;

// ─── shabbat, rosh chodesh ────────────────────────────────────────────────────

/// Whether [date] is a Saturday. The whole calendar day: for the moment
/// Shabbat starts and ends, use `Zmanim.restStatusAt` from jewish_zmanim.
bool isShabbat(BasicJewishDate date) => toGregorianDate(date).weekday == DateTime.saturday;

/// Whether [date] is a Friday.
bool isErevShabbat(BasicJewishDate date) => toGregorianDate(date).weekday == DateTime.friday;

/// Day 30 of a month and day 1 of the next — as in npm, including 1 Tishri.
bool isRoshChodesh(BasicJewishDate date) => date.day == 1 || date.day == 30;

// ─── yom tov ──────────────────────────────────────────────────────────────────

const _yomTovIsrael = [
  Holiday(1, JewishMonth.tishri, 'Rosh Hashanah', 'ראש השנה'),
  Holiday(2, JewishMonth.tishri, 'Rosh Hashanah', 'ראש השנה'),
  Holiday(10, JewishMonth.tishri, 'Yom Kippur', 'יום הכיפורים'),
  Holiday(15, JewishMonth.tishri, 'Sukkot', 'סוכות'),
  Holiday(22, JewishMonth.tishri, 'Simchat Torah', 'שמחת תורה'),
  Holiday(15, JewishMonth.nisan, 'Pesach', 'פסח'),
  Holiday(21, JewishMonth.nisan, 'Shevii Shel Pesach', 'שביעי של פסח'),
  Holiday(6, JewishMonth.sivan, 'Shavuot', 'שבועות'),
];

const _yomTovChutzLaaretzOnly = [
  Holiday(16, JewishMonth.tishri, 'Sukkot', 'סוכות'),
  Holiday(23, JewishMonth.tishri, 'Simchat Torah', 'שמחת תורה'),
  Holiday(16, JewishMonth.nisan, 'Pesach', 'פסח'),
  Holiday(22, JewishMonth.nisan, 'Acharon Shel Pesach', 'אחרון של פסח'),
  Holiday(7, JewishMonth.sivan, 'Shavuot', 'שבועות'),
];

/// The festival days on which work is forbidden: Rosh Hashanah, Yom Kippur,
/// Sukkot, Simchat Torah, Pesach and Shavuot. With [isChutzLaaretz], the
/// diaspora's second days are included.
List<Holiday> getYomTovList({bool isChutzLaaretz = false}) => [
  ..._yomTovIsrael,
  if (isChutzLaaretz) ..._yomTovChutzLaaretzOnly,
];

/// Whether [date] is in [getYomTovList]. Shabbat alone is not Yom Tov.
bool isYomTov(BasicJewishDate date, {bool isChutzLaaretz = false}) =>
    isDateInHolidayList(date, getYomTovList(isChutzLaaretz: isChutzLaaretz));

const _erevYomTov = [
  Holiday(29, JewishMonth.elul, 'Erev Rosh Hashanah', 'ערב ראש השנה'),
  Holiday(9, JewishMonth.tishri, 'Erev Yom Kippur', 'ערב יום הכיפורים'),
  Holiday(14, JewishMonth.tishri, 'Erev Sukkot', 'ערב סוכות'),
  Holiday(21, JewishMonth.tishri, 'Erev Simchat Torah', 'ערב שמחת תורה'),
  Holiday(14, JewishMonth.nisan, 'Erev Pesach', 'ערב פסח'),
  Holiday(20, JewishMonth.nisan, "Erev Shvi'i Shel Pesach", 'ערב שביעי של פסח'),
  Holiday(5, JewishMonth.sivan, 'Erev Shavuot', 'ערב שבועות'),
];

/// Only the eve of a first festival day, in Israel and the diaspora alike.
bool isErevYomTov(BasicJewishDate date) => isDateInHolidayList(date, _erevYomTov);

// ─── chol hamoed ──────────────────────────────────────────────────────────────

List<Holiday> _days(JewishMonth month, List<int> days, String name, String hebrewName) => [
  for (final d in days) Holiday(d, month, name, hebrewName),
];

final _cholHaMoedIsrael = [
  ..._days(JewishMonth.tishri, [16, 17, 18, 19, 20, 21], 'Chol HaMoed', 'חול המועד'),
  ..._days(JewishMonth.nisan, [16, 17, 18, 19, 20], 'Chol HaMoed', 'חול המועד'),
];

final _cholHaMoedChutzLaaretz = [
  ..._days(JewishMonth.tishri, [17, 18, 19, 20, 21], 'Chol HaMoed', 'חול המועד'),
  ..._days(JewishMonth.nisan, [17, 18, 19, 20], 'Chol HaMoed', 'חול המועד'),
];

/// Whether [date] is one of the intermediate days of Sukkot or Pesach, which
/// are fewer in the diaspora ([isChutzLaaretz]).
bool isCholHaMoed(BasicJewishDate date, {bool isChutzLaaretz = false}) =>
    isDateInHolidayList(date, isChutzLaaretz ? _cholHaMoedChutzLaaretz : _cholHaMoedIsrael);

// ─── chanukah, purim ──────────────────────────────────────────────────────────

List<Holiday> _chanukahList(int jewishYear) => [
  ..._days(JewishMonth.kislev, [25, 26, 27, 28, 29, 30], 'Chanukah', 'חנוכה'),
  ..._days(JewishMonth.tevet, [1, 2], 'Chanukah', 'חנוכה'),
  if (calcDaysInMonth(jewishYear, JewishMonth.kislev) == 29) ..._days(JewishMonth.tevet, [3], 'Chanukah', 'חנוכה'),
];

/// Whether [date] is one of the eight days of Chanukah, from 25 Kislev. They
/// end on 2 or 3 Tevet, depending on the length of Kislev.
bool isChanukah(BasicJewishDate date) => isDateInHolidayList(date, _chanukahList(date.year));

/// Purim and Shushan Purim, on 14 and 15 of Adar, or of Adar II in a leap year.
List<Holiday> getPurimList() => const [
  Holiday(14, JewishMonth.adar, 'Purim', 'פורים'),
  Holiday(15, JewishMonth.adar, 'Shushan Purim', 'שושן פורים'),
  Holiday(14, JewishMonth.adarII, 'Purim', 'פורים'),
  Holiday(15, JewishMonth.adarII, 'Shushan Purim', 'שושן פורים'),
];

/// Whether [date] is Purim or Shushan Purim.
bool isPurim(BasicJewishDate date) => isDateInHolidayList(date, getPurimList());

// ─── fasts ────────────────────────────────────────────────────────────────────

/// The fast days on their calendar dates, each with where it moves when that
/// date is Shabbat. [getTzomInfo] applies the move.
List<Tzom> getTzomotList() => const [
  Tzom(3, JewishMonth.tishri, 'Tzom Gdalia', 'צום גדליה', TzomShift.postponed),
  // Yom Kippur is fasted even when it falls on Shabbat
  Tzom(10, JewishMonth.tishri, 'Yom Kippur', 'יום הכיפורים', null),
  // Asara BeTevet can fall on Friday but never on Shabbat
  Tzom(10, JewishMonth.tevet, 'Asara BeTevet', 'עשרה בטבת', null),
  // The Sunday after 13 Adar is Purim itself, so the fast moves back to Thursday
  Tzom(13, JewishMonth.adar, 'Taanit Esther', 'תענית אסתר', TzomShift.advanced),
  Tzom(13, JewishMonth.adarII, 'Taanit Esther', 'תענית אסתר', TzomShift.advanced),
  // 14 Nisan is Erev Pesach, so the fast moves back to Thursday
  Tzom(14, JewishMonth.nisan, 'Taanit Bechorot', 'תענית בכורות', TzomShift.advanced),
  Tzom(17, JewishMonth.tammuz, 'Shiva Asar BeTamuz', 'שבעה עשר בתמוז', TzomShift.postponed),
  Tzom(9, JewishMonth.av, 'Tisha BeAv', 'תשעה באב', TzomShift.postponed),
];

int _observedDay(Tzom tzom, int year) {
  final shift = tzom.shiftOnShabbat;
  if (shift == null) return tzom.day;
  if (!isShabbat(BasicJewishDate(day: tzom.day, monthName: tzom.monthName, year: year))) return tzom.day;
  return shift == TzomShift.postponed ? tzom.day + 1 : tzom.day - 2;
}

/// The fast observed on [date], after moving fasts off Shabbat, or null.
TzomInfo? getTzomInfo(BasicJewishDate date, [Language language = Language.en]) {
  for (final tzom in getTzomotList()) {
    if (tzom.monthName != date.monthName) continue;
    final observed = _observedDay(tzom, date.year);
    if (observed != date.day) continue;
    return TzomInfo(tzom.nameIn(language), observed == tzom.day ? null : tzom.shiftOnShabbat);
  }
  return null;
}

/// Whether a fast is observed on [date].
bool isTzom(BasicJewishDate date) => getTzomInfo(date) != null;

// ─── date info ────────────────────────────────────────────────────────────────

/// Everything about one Hebrew date, from [getDateInfo].
class DateInfo {
  /// Usually built by [getDateInfo].
  const DateInfo({
    required this.jewishDate,
    required this.isYomTov,
    required this.isErevYomTov,
    required this.isCholHaMoed,
    required this.isShabbat,
    required this.isErevShabbat,
    required this.isRoshChodesh,
    required this.isChanukah,
    required this.isPurim,
    required this.isTzom,
    required this.tzom,
    required this.holidays,
  });

  /// The date described.
  final BasicJewishDate jewishDate;

  /// A festival day in [getYomTovList] (Shabbat alone is not).
  final bool isYomTov;

  /// The eve of a first festival day.
  final bool isErevYomTov;

  /// An intermediate day of Sukkot or Pesach.
  final bool isCholHaMoed;

  /// Saturday.
  final bool isShabbat;

  /// Friday.
  final bool isErevShabbat;

  /// Rosh Chodesh: day 30 of a month or day 1 of the next.
  final bool isRoshChodesh;

  /// One of the eight days of Chanukah.
  final bool isChanukah;

  /// Purim or Shushan Purim.
  final bool isPurim;

  /// A fast is observed; see [tzom].
  final bool isTzom;

  /// The fast observed, or null.
  final TzomInfo? tzom;

  /// Each observance of the day, named once, in a fixed order.
  final List<String> holidays;
}

const _labels = {
  'cholHaMoed': {Language.en: 'Chol HaMoed', Language.he: 'חול המועד'},
  'roshChodesh': {Language.en: 'Rosh Chodesh', Language.he: 'ראש חודש'},
  'chanukah': {Language.en: 'Chanukah', Language.he: 'חנוכה'},
};

/// Everything about [date]: its flags and the names of its observances in
/// [language]. With [isChutzLaaretz], the diaspora calendar is used.
DateInfo getDateInfo(BasicJewishDate date, {bool isChutzLaaretz = false, Language language = Language.en}) {
  final cholHaMoed = isCholHaMoed(date, isChutzLaaretz: isChutzLaaretz);
  final roshChodesh = isRoshChodesh(date);
  final chanukah = isChanukah(date);
  final tzom = getTzomInfo(date, language);
  final yomTovNames = getHolidaysForDate(
    date,
    getYomTovList(isChutzLaaretz: isChutzLaaretz),
  ).map((h) => h.nameIn(language));
  final purimNames = getHolidaysForDate(date, getPurimList()).map((h) => h.nameIn(language)).toList();

  // A date can carry several observances, but each is named only once - Yom
  // Kippur, for instance, is both a Yom Tov and a fast
  final holidays = <String>{
    ...yomTovNames,
    if (cholHaMoed) _labels['cholHaMoed']![language]!,
    if (roshChodesh) _labels['roshChodesh']![language]!,
    if (chanukah) _labels['chanukah']![language]!,
    ...purimNames,
    if (tzom != null) tzom.name,
  }.toList();

  return DateInfo(
    jewishDate: date,
    isYomTov: isYomTov(date, isChutzLaaretz: isChutzLaaretz),
    isErevYomTov: isErevYomTov(date),
    isCholHaMoed: cholHaMoed,
    isShabbat: isShabbat(date),
    isErevShabbat: isErevShabbat(date),
    isRoshChodesh: roshChodesh,
    isChanukah: chanukah,
    isPurim: purimNames.isNotEmpty,
    isTzom: tzom != null,
    tzom: tzom,
    holidays: holidays,
  );
}

/// [getDateInfo] for a Gregorian calendar date (its time of day is ignored).
DateInfo getDateInfoForGregorian(DateTime date, {bool isChutzLaaretz = false, Language language = Language.en}) =>
    getDateInfo(toJewishDate(date), isChutzLaaretz: isChutzLaaretz, language: language);
