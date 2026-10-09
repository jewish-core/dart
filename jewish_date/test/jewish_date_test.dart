// The npm package's own unit tests (__tests__/jewishDate*.test.ts), ported.
import 'package:jewish_date/jewish_date.dart';
import 'package:test/test.dart';

void main() {
  group('jewishDate', () {
    test('index by month', () => expect(getIndexByJewishMonth(JewishMonth.cheshvan), 8));
    test('5782 is a leap year', () => expect(isLeapYear(5782), isTrue));
    test('5781 is not a leap year', () => expect(isLeapYear(5781), isFalse));
    test('month 12 of 5781 is Elul', () => expect(getJewishMonthsInOrder(5781)[12], JewishMonth.elul));
    test('month 12 of 5782 is Av', () => expect(getJewishMonthsInOrder(5782)[12], JewishMonth.av));

    final tishri = toJewishDate(DateTime(2022, 9, 26));
    final iyyar = toJewishDate(DateTime(2023, 4, 26));
    test('format', () {
      expect(formatJewishDate(tishri), '1 Tishri 5783');
      expect(formatJewishDate(iyyar, 'dd/MM/yyyy'), '05/08/5783');
      expect(formatJewishDate(iyyar, 'MMMM d, yyyy'), 'Iyyar 5, 5783');
      expect(formatJewishDate(iyyar, 'd/M/yy'), '5/8/83');
      expect(formatJewishDate(iyyar, 'yyyy-MM-dd'), '5783-08-05');
    });

    test('round trip', () {
      final g = toGregorianDate(const BasicJewishDate(day: 1, monthName: JewishMonth.tishri, year: 5783));
      expect(g, DateTime.utc(2022, 9, 26));
    });

    test('the date of the sicha: Shabbos Bereishis 5752', () {
      final j = toJewishDate(DateTime(1991, 10, 5));
      expect(j, const JewishDate(day: 27, monthName: JewishMonth.tishri, year: 5752, month: 1));
      expect(formatJewishDateInHebrew(j), 'כ״ז תשרי התשנ״ב');
    });
  });

  group('jewishDateHebrew', () {
    test('number to Hebrew', () => expect(convertNumberToHebrew(5783), 'התשפ״ג'));
    test('month in Hebrew', () => expect(getJewishMonthInHebrew(JewishMonth.iyyar), 'אייר'));
    test('to Hebrew date', () {
      expect(
        toHebrewJewishDate(toJewishDate(DateTime(2022, 9, 26))),
        const BasicJewishDateHebrew(day: 'א׳', monthName: 'תשרי', year: 'התשפ״ג'),
      );
    });
    test('short year', () => expect(convertYearToShortHebrew(5783), 'פ״ג'));
    test('15 and 16 avoid the Name', () {
      expect(convertNumberToHebrew(15), 'ט״ו');
      expect(convertNumberToHebrew(16), 'ט״ז');
    });
    test('Hebrew patterns', () {
      final j = toJewishDate(DateTime(2023, 4, 26));
      expect(formatJewishDateInHebrew(j, 'dd/MM/yyyy'), '05/02/5783');
      expect(formatJewishDateInHebrew(j, 'D/MM/YY'), 'ה׳/02/פ״ג');
      expect(formatJewishDateInHebrew(j, 'd MMMM yyyy'), '5 אייר 5783');
    });
  });
}
