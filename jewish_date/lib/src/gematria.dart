// Copyright (c) Shmulik Kravitz. Licensed under the MIT license.
//
// Numbers in Hebrew letters, ported from src/utils/gematriaUtils/gematriaUtils.ts.

const _geresh = '\u05F3';
const _gershayim = '\u05F4';

const _numerals = <int, String>{
  0: '',
  1: 'א',
  2: 'ב',
  3: 'ג',
  4: 'ד',
  5: 'ה',
  6: 'ו',
  7: 'ז',
  8: 'ח',
  9: 'ט',
  10: 'י',
  20: 'כ',
  30: 'ל',
  40: 'מ',
  50: 'נ',
  60: 'ס',
  70: 'ע',
  80: 'פ',
  90: 'צ',
  100: 'ק',
  200: 'ר',
  300: 'ש',
  400: 'ת',
  500: 'תק',
  600: 'תר',
  700: 'תש',
  800: 'תת',
  900: 'תתק',
  1000: 'תתר',
};

int _pow10(int e) {
  var r = 1;
  for (var i = 0; i < e; i++) {
    r *= 10;
  }
  return r;
}

String _toNumeral(int digit, int place) {
  var folded = place;
  while (digit * _pow10(folded) > 1000) {
    folded -= 3;
  }
  return _numerals[digit * _pow10(folded)] ?? '';
}

/// [n] in Hebrew letters: 5786 → התשפ״ו (thousands as a single letter);
/// 15 and 16 are ט״ו and ט״ז.
///
/// [geresh] defaults to [punctuate], as in the npm package.
String toGematria(int n, {bool punctuate = true, bool? geresh}) {
  final useGeresh = geresh ?? punctuate;
  final digits = n.toString().split('').reversed.toList();
  final letters = [
    for (var place = 0; place < digits.length; place++) _toNumeral(int.parse(digits[place]), place),
  ].reversed.join();
  // 15 and 16 are written ט״ו and ט״ז, not with letters of the Name
  final word = letters.replaceAll('יה', 'טו').replaceAll('יו', 'טז');

  if (!(punctuate || useGeresh) || word.isEmpty) return word;
  if (word.length == 1) return word + (useGeresh ? _geresh : "'");
  return word.substring(0, word.length - 1) + (useGeresh ? _gershayim : '"') + word.substring(word.length - 1);
}
