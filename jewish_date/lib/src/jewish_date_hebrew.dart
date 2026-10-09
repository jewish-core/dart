// Copyright (c) Shmulik Kravitz. Licensed under the MIT license.
//
// Ported from src/jewishDateHebrew.ts.

import 'format.dart';
import 'gematria.dart';
import 'interfaces.dart';
import 'jewish_date.dart';

/// The Hebrew name of [month]: תשרי, אדר א.
String getJewishMonthInHebrew(JewishMonth month) => switch (month) {
  JewishMonth.none => 'ללא',
  JewishMonth.tishri => 'תשרי',
  JewishMonth.cheshvan => 'חשון',
  JewishMonth.kislev => 'כסלו',
  JewishMonth.tevet => 'טבת',
  JewishMonth.shevat => 'שבט',
  JewishMonth.adar => 'אדר',
  JewishMonth.adarI => 'אדר א',
  JewishMonth.adarII => 'אדר ב',
  JewishMonth.nisan => 'ניסן',
  JewishMonth.iyyar => 'אייר',
  JewishMonth.sivan => 'סיון',
  JewishMonth.tammuz => 'תמוז',
  JewishMonth.av => 'אב',
  JewishMonth.elul => 'אלול',
};

/// [n] in Hebrew letters: 5786 → התשפ״ו.
///
/// With [addGeresh] the mark is the Hebrew geresh or gershayim (׳ ״);
/// without it, an ASCII apostrophe or quote. [addPunctuate] false leaves
/// the letters bare.
String convertNumberToHebrew(int n, {bool addGeresh = true, bool addPunctuate = true}) =>
    toGematria(n, geresh: addGeresh, punctuate: addPunctuate);

/// The last two digits of the year: 5783 ⟵ פ״ג.
String convertYearToShortHebrew(int year) => toGematria(year % 100);

/// [date] with each part in Hebrew letters: day י׳, month תשרי, year התשפ״ו.
BasicJewishDateHebrew toHebrewJewishDate(BasicJewishDate date) => BasicJewishDateHebrew(
  day: convertNumberToHebrew(date.day),
  monthName: getJewishMonthInHebrew(date.monthName),
  year: convertNumberToHebrew(date.year),
);

/// [date] in Hebrew, by [pattern] (default `D MMMM YYYY`: "י׳ תשרי התשפ״ו").
///
/// `D` and `YYYY` are in Hebrew letters, `YY` is the short year (פ״ו) and
/// `MMMM` the Hebrew month name; the other tokens are as in [formatJewishDate].
///
/// Unlike [formatJewishDate], M and MM here are the npm month index
/// (Nisan = 1), not the position from Tishri — as in the npm package.
String formatJewishDateInHebrew(BasicJewishDate date, [String? pattern]) => formatWithPattern(
  pattern ?? defaultPatternHebrew,
  (day: date.day, month: getIndexByJewishMonth(date.monthName), monthName: date.monthName.npmName, year: date.year),
  createHebrewFormatters(
    convertNumberToHebrew,
    (name) => getJewishMonthInHebrew(JewishMonth.fromNpmName(name)),
    convertYearToShortHebrew,
  ),
);
