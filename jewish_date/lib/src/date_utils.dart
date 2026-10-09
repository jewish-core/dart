// Copyright (c) Shmulik Kravitz. Licensed under the MIT license.
//
// Julian-day arithmetic for the Gregorian and Hebrew calendars. A line-by-line
// port of src/utils/dateUtils/dateUtils.ts. Julian days are doubles ending in .5,
// as in the original.

const double _gregorianEpoch = 1721425.5;
const double _hebrewEpoch = 347995.5;

/// Floor modulo, like the npm package's mod() (JS % keeps the sign of a).
double mod(double a, double b) => a - b * (a / b).floorToDouble();

int _floor(num x) => x.floor();

bool _leapGregorian(int year) => year % 4 == 0 && !(year % 100 == 0 && year % 400 != 0);

double gregorianToJd(int year, int month, int day) {
  return _gregorianEpoch -
      1 +
      365 * (year - 1) +
      _floor((year - 1) / 4) -
      _floor((year - 1) / 100) +
      _floor((year - 1) / 400) +
      _floor(
        (367 * month - 362) / 12 +
            (month <= 2
                ? 0
                : _leapGregorian(year)
                ? -1
                : -2) +
            day,
      );
}

/// Returns (year, month, day).
(int, int, int) jdToGregorian(double jd) {
  final wjd = (jd - 0.5).floorToDouble() + 0.5;
  final depoch = wjd - _gregorianEpoch;
  final quadricent = _floor(depoch / 146097);
  final dqc = mod(depoch, 146097);
  final cent = _floor(dqc / 36524);
  final dcent = mod(dqc, 36524);
  final quad = _floor(dcent / 1461);
  final dquad = mod(dcent, 1461);
  final yindex = _floor(dquad / 365);
  var year = quadricent * 400 + cent * 100 + quad * 4 + yindex;
  if (!(cent == 4 || yindex == 4)) year++;
  final yearday = wjd - gregorianToJd(year, 1, 1);
  final leapadj = wjd < gregorianToJd(year, 3, 1)
      ? 0
      : _leapGregorian(year)
      ? 1
      : 2;
  final month = _floor(((yearday + leapadj) * 12 + 373) / 367);
  final day = (wjd - gregorianToJd(year, month, 1) + 1).round();
  return (year, month, day);
}

bool _hebrewLeap(int year) => mod(year * 7.0 + 1, 19) < 7;

int _hebrewYearMonths(int year) => _hebrewLeap(year) ? 13 : 12;

int _calculateHebrewYearStartDelay(int year) {
  final months = _floor((235 * year - 234) / 19);
  final parts = 12084 + 13753 * months;
  var day = months * 29 + _floor(parts / 25920);
  if (mod(3.0 * (day + 1), 7) < 3) day++;
  return day;
}

int _calculateHebrewYearAdjacentDelay(int year) {
  final last = _calculateHebrewYearStartDelay(year - 1);
  final present = _calculateHebrewYearStartDelay(year);
  final next = _calculateHebrewYearStartDelay(year + 1);
  return next - present == 356
      ? 2
      : present - last == 382
      ? 1
      : 0;
}

double _hebrewYearDays(int year) => hebrewToJd(year + 1, 7, 1) - hebrewToJd(year, 7, 1);

/// Days in a Hebrew month, by the npm package's month index (Nisan = 1,
/// Tishri = 7, Adar II = 13).
int hebrewMonthDays(int year, int month) {
  if (month == 2 || month == 4 || month == 6 || month == 10 || month == 13) return 29;
  if (month == 12 && !_hebrewLeap(year)) return 29;
  if (month == 8 && !(mod(_hebrewYearDays(year), 10) == 5)) return 29;
  if (month == 9 && mod(_hebrewYearDays(year), 10) == 3) return 29;
  return 30;
}

double hebrewToJd(int year, int month, int day) {
  final months = _hebrewYearMonths(year);
  var jd = _hebrewEpoch + _calculateHebrewYearStartDelay(year) + _calculateHebrewYearAdjacentDelay(year) + day + 1;
  if (month < 7) {
    for (var mon = 7; mon <= months; mon++) {
      jd += hebrewMonthDays(year, mon);
    }
    for (var mon = 1; mon < month; mon++) {
      jd += hebrewMonthDays(year, mon);
    }
  } else {
    for (var mon = 7; mon < month; mon++) {
      jd += hebrewMonthDays(year, mon);
    }
  }
  return jd;
}

/// Returns (year, month index, day).
(int, int, int) jdToHebrew(double julianDate) {
  final jd = julianDate.floorToDouble() + 0.5;
  final count = _floor(((jd - _hebrewEpoch) * 98496.0) / 35975351.0);
  var year = count - 1;
  for (var i = count; jd >= hebrewToJd(i, 7, 1); i++) {
    year++;
  }
  final first = jd < hebrewToJd(year, 1, 1) ? 7 : 1;
  var month = first;
  for (var i = first; jd > hebrewToJd(year, i, hebrewMonthDays(year, i)); i++) {
    month++;
  }
  final day = (jd - hebrewToJd(year, month, 1) + 1).round();
  return (year, month, day);
}
