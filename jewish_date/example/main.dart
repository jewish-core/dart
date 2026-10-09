import 'package:jewish_date/jewish_date.dart';

void main() {
  final today = toJewishDate(DateTime(2025, 10, 2));
  print(formatJewishDate(today)); // English, default pattern
  print(formatJewishDateInHebrew(today)); // Hebrew letters

  final roshHashanah = BasicJewishDate(year: 5787, monthName: JewishMonth.tishri, day: 1);
  print(toGregorianDate(roshHashanah)); // UTC midnight

  print(convertNumberToHebrew(5786)); // gematria
  print(calcDaysInMonth(5786, JewishMonth.kislev));
}
