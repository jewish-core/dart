import 'package:jewish_holidays/jewish_holidays.dart';

void main() {
  final day = DateTime(2025, 10, 8);

  final israel = getDateInfoForGregorian(day);
  final diaspora = getDateInfoForGregorian(day, isChutzLaaretz: true);
  print('Israel:   ${israel.holidays}'); // Chol HaMoed
  print('Diaspora: ${diaspora.holidays}'); // second day of Sukkot

  final hebrew = getDateInfoForGregorian(day, language: Language.he);
  print(hebrew.holidays);
}
