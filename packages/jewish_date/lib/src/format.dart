// Copyright (c) Shmulik Kravitz. Licensed under the MIT license.
//
// Pattern formatting, ported from src/utils/formatUtils/formatUtils.ts.

/// Tokens, longest first: the first one found at a position wins.
const _tokenPatterns = ['yyyy', 'YYYY', 'yy', 'YY', 'MMMM', 'MM', 'M', 'dd', 'D', 'd'];

typedef FormatComponents = ({int day, int month, String monthName, int year});
typedef TokenFormatter = String Function(FormatComponents c);

String toLength(int n, int len) => n.toString().padLeft(len, '0');

final Map<String, TokenFormatter> englishFormatters = {
  'd': (c) => '${c.day}',
  'dd': (c) => toLength(c.day, 2),
  'D': (c) => '${c.day}',
  'M': (c) => '${c.month}',
  'MM': (c) => toLength(c.month, 2),
  'MMMM': (c) => c.monthName,
  'yy': (c) => toLength(c.year % 100, 2),
  'YY': (c) => toLength(c.year % 100, 2),
  'yyyy': (c) => '${c.year}',
  'YYYY': (c) => '${c.year}',
};

Map<String, TokenFormatter> createHebrewFormatters(
  String Function(int) convertToHebrew,
  String Function(String) getHebrewMonthName,
  String Function(int) getShortYearHebrew,
) => {
  'd': (c) => '${c.day}',
  'dd': (c) => toLength(c.day, 2),
  'D': (c) => convertToHebrew(c.day),
  'M': (c) => '${c.month}',
  'MM': (c) => toLength(c.month, 2),
  'MMMM': (c) => getHebrewMonthName(c.monthName),
  'yy': (c) => toLength(c.year % 100, 2),
  'YY': (c) => getShortYearHebrew(c.year),
  'yyyy': (c) => '${c.year}',
  'YYYY': (c) => convertToHebrew(c.year),
};

String formatWithPattern(String pattern, FormatComponents components, Map<String, TokenFormatter> formatters) {
  final out = StringBuffer();
  var i = 0;
  while (i < pattern.length) {
    final token = _tokenPatterns.where((t) => pattern.startsWith(t, i)).firstOrNull;
    if (token == null) {
      out.write(pattern[i]);
      i++;
    } else {
      out.write(formatters[token]!(components));
      i += token.length;
    }
  }
  return out.toString();
}

const defaultPattern = 'd MMMM yyyy';
const defaultPatternHebrew = 'D MMMM YYYY';
