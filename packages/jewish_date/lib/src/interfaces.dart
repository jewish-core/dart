// Copyright (c) Shmulik Kravitz. Licensed under the MIT license.

/// Hebrew months. [npmName] is the string the npm package uses.
enum JewishMonth {
  /// Not a month: the placeholder at index 0 of `getJewishMonthsInOrder`.
  none('None'),

  /// The first month of the year, with Rosh Hashanah and Yom Kippur.
  tishri('Tishri'),

  /// Cheshvan (Marcheshvan), 29 or 30 days.
  cheshvan('Cheshvan'),

  /// Kislev, 29 or 30 days; Chanukah starts on the 25th.
  kislev('Kislev'),

  /// Tevet.
  tevet('Tevet'),

  /// Shevat.
  shevat('Shevat'),

  /// Adar of a regular year. A leap year has [adarI] and [adarII] instead.
  adar('Adar'),

  /// Nisan, the month of Pesach.
  nisan('Nisan'),

  /// Iyyar.
  iyyar('Iyyar'),

  /// Sivan, the month of Shavuot.
  sivan('Sivan'),

  /// Tammuz.
  tammuz('Tammuz'),

  /// Av.
  av('Av'),

  /// Elul, the last month of the year.
  elul('Elul'),

  /// The first Adar of a leap year.
  adarI('AdarI'),

  /// The second Adar of a leap year, with Purim.
  adarII('AdarII');

  const JewishMonth(this.npmName);

  /// The month's name in the npm package ("Tishri", "AdarII").
  final String npmName;

  /// The month whose [npmName] is [name], or [none].
  static JewishMonth fromNpmName(String name) => values.firstWhere((m) => m.npmName == name, orElse: () => none);
}

/// A Hebrew date: day of month, month and year.
class BasicJewishDate {
  /// A Hebrew date; nothing checks that [day] exists in that month.
  const BasicJewishDate({required this.day, required this.monthName, required this.year});

  /// Day of the month, 1 to 30.
  final int day;

  /// The month. In a leap year Adar is [JewishMonth.adarI] or
  /// [JewishMonth.adarII]; in a regular year, [JewishMonth.adar].
  final JewishMonth monthName;

  /// The year from creation: 5786 began in September 2025.
  final int year;

  @override
  bool operator ==(Object other) =>
      other is BasicJewishDate && other.day == day && other.monthName == monthName && other.year == year;

  @override
  int get hashCode => Object.hash(day, monthName, year);

  @override
  String toString() => '$day ${monthName.npmName} $year';
}

/// A Hebrew date with [month], the month's position in the year starting
/// from Tishri = 1 (see getJewishMonthsInOrder).
class JewishDate extends BasicJewishDate {
  const JewishDate({required super.day, required super.monthName, required super.year, required this.month});

  /// The month's position from Tishri = 1, as in `getJewishMonthsInOrder`.
  final int month;

  @override
  bool operator ==(Object other) => other is JewishDate && super == other && other.month == month;

  @override
  int get hashCode => Object.hash(super.hashCode, month);
}

/// A Hebrew date written in Hebrew letters.
class BasicJewishDateHebrew {
  const BasicJewishDateHebrew({required this.day, required this.monthName, required this.year});

  /// The day in letters: י׳.
  final String day;

  /// The Hebrew month name: תשרי.
  final String monthName;

  /// The year in letters: התשפ״ו.
  final String year;

  @override
  bool operator ==(Object other) =>
      other is BasicJewishDateHebrew && other.day == day && other.monthName == monthName && other.year == year;

  @override
  int get hashCode => Object.hash(day, monthName, year);

  @override
  String toString() => '$day $monthName $year';
}
