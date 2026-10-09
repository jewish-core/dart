import 'package:jewish_date/jewish_date.dart';
import 'package:jewish_holidays/jewish_holidays.dart';
import 'package:test/test.dart';

BasicJewishDate hd(int year, JewishMonth month, int day) => BasicJewishDate(year: year, monthName: month, day: day);

void main() {
  group('Yom Tov', () {
    test('16 Tishri is Yom Tov only in the diaspora, Chol HaMoed in Israel', () {
      final d = hd(5786, JewishMonth.tishri, 16);
      expect(isYomTov(d), isFalse);
      expect(isCholHaMoed(d), isTrue);
      expect(isYomTov(d, isChutzLaaretz: true), isTrue);
      expect(isCholHaMoed(d, isChutzLaaretz: true), isFalse);
    });

    test('Yom Kippur is a Yom Tov and a fast, named once', () {
      final info = getDateInfo(hd(5786, JewishMonth.tishri, 10));
      expect(info.isYomTov, isTrue);
      expect(info.isTzom, isTrue);
      expect(info.holidays, ['Yom Kippur']);
    });

    test('names in Hebrew', () {
      final info = getDateInfo(hd(5786, JewishMonth.nisan, 15), language: Language.he);
      expect(info.holidays, ['פסח']);
    });
  });

  group('Chanukah', () {
    test('lasts eight days every year, whatever the length of Kislev', () {
      for (var year = 5700; year <= 5900; year++) {
        final first = toGregorianDate(hd(year, JewishMonth.kislev, 25));
        var days = 0;
        while (isChanukah(toJewishDate(first.add(Duration(days: days))))) {
          days++;
        }
        expect(days, 8, reason: '$year');
      }
    });
  });

  group('fasts', () {
    test('Tisha BeAv 5782 fell on Shabbat and was postponed to Sunday', () {
      expect(getDateInfoForGregorian(DateTime(2022, 8, 6)).isTzom, isFalse);
      final sunday = getDateInfoForGregorian(DateTime(2022, 8, 7));
      expect(sunday.tzom, const TzomInfo('Tisha BeAv', TzomShift.postponed));
    });

    test('Tisha BeAv 5785 fell on Sunday and was not moved', () {
      final sunday = getDateInfoForGregorian(DateTime(2025, 8, 3));
      expect(sunday.tzom, const TzomInfo('Tisha BeAv', null));
    });

    test('no fast except Yom Kippur is ever observed on Shabbat', () {
      var day = DateTime.utc(2000, 1, 1);
      final end = DateTime.utc(2100, 1, 1);
      while (day.isBefore(end)) {
        final jd = toJewishDate(day);
        final tzom = getTzomInfo(jd);
        if (tzom != null && tzom.name != 'Yom Kippur') {
          expect(isShabbat(jd), isFalse, reason: '${tzom.name} on $day');
        }
        day = day.add(const Duration(days: 1));
      }
    });

    test('an advanced fast moves to Thursday', () {
      var day = DateTime.utc(2000, 1, 1);
      final end = DateTime.utc(2100, 1, 1);
      var seen = 0;
      while (day.isBefore(end)) {
        final tzom = getTzomInfo(toJewishDate(day));
        if (tzom?.shift == TzomShift.advanced) {
          expect(day.weekday, DateTime.thursday, reason: '${tzom!.name} on $day');
          seen++;
        }
        day = day.add(const Duration(days: 1));
      }
      expect(seen, greaterThan(0));
    });
  });

  group('kept as in npm', () {
    test('1 Tishri counts as Rosh Chodesh', () {
      expect(isRoshChodesh(hd(5786, JewishMonth.tishri, 1)), isTrue);
    });
  });
}
