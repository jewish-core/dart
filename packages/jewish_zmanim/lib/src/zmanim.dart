// Copyright (c) Shmulik Kravitz. Licensed under the MIT license.
//
// Ported from src/zmanim.ts of jewish-zmanim 1.0.6. The arithmetic is the
// same; the differences are listed in lib/jewish_zmanim.dart.

import 'dart:math' as math;

import 'package:jewish_date/jewish_date.dart';
import 'package:jewish_holidays/jewish_holidays.dart' as holidays;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'city.dart';
import 'solar.dart';

bool _timeZonesReady = false;

/// Loads the IANA time-zone database. Safe to call more than once.
void initializeZmanim() {
  if (_timeZonesReady) return;
  tzdata.initializeTimeZones();
  _timeZonesReady = true;
}

tz.Location _location(City city) {
  if (!_timeZonesReady) {
    throw StateError('Call initializeZmanim() before computing zmanim.');
  }
  return tz.getLocation(city.timeZone);
}

/// The values that were constants in the npm package. The defaults are the
/// npm values; the high-latitude fallbacks are stringent.
class ZmanimSettings {
  /// Settings with the npm defaults; override only what your community differs on.
  const ZmanimSettings({
    this.alosDegrees = 16.1,
    this.tzeisDegrees = 8.5,
    this.tefillinDegreesIsrael = 11.5,
    this.tefillinDegreesDiaspora = 10.2,
    this.fallbackCandleLightingHour = 12,
    this.fallbackRestEndHour = 24,
  });

  /// The sun's depth below the horizon at dawn ([Zmanim.alosHashachar]).
  final double alosDegrees;

  /// The sun's depth below the horizon at nightfall ([Zmanim.tzeis]).
  final double tzeisDegrees;

  /// The sun's depth for the earliest tefillin ([Zmanim.tefillin]) in Israel.
  final double tefillinDegreesIsrael;

  /// The sun's depth for the earliest tefillin outside Israel.
  final double tefillinDegreesDiaspora;

  /// Where the sun does not set (high latitudes in summer), candle lighting
  /// has no time. The rest window then starts at this local hour. The npm
  /// package never starts Shabbat in that case.
  final double fallbackCandleLightingHour;

  /// Where the sun does not reach nightfall depth, tzeis has no time. The rest
  /// window then lasts until this local hour (24 = the whole day). The npm
  /// package ends Shabbat at midnight of Friday night in that case.
  final double fallbackRestEndHour;
}

/// Whether a moment is inside Shabbat or Yom Tov: from candle lighting on
/// the eve to tzeis at the end, in the city's own time zone.
class RestStatus {
  /// Usually from [Zmanim.restStatusAt].
  const RestStatus({required this.isShabbat, required this.isYomTov});

  /// Inside Shabbat.
  final bool isShabbat;

  /// Inside Yom Tov.
  final bool isYomTov;

  /// Inside Shabbat or Yom Tov.
  bool get isRest => isShabbat || isYomTov;

  @override
  String toString() => 'RestStatus(shabbat: $isShabbat, yomTov: $isYomTov)';
}

double? _n(double v) => v.isNaN ? null : v;

/// The zmanim of one civil date in one city. Times are fractional hours from
/// local midnight, or null where the sun never reaches the angle.
class Zmanim {
  /// The zmanim of [year]-[month]-[day] in [city].
  ///
  /// Throws a [StateError] before [initializeZmanim], and a
  /// `LocationNotFoundException` if the city's time zone is unknown.
  Zmanim(this.city, this.year, this.month, this.day, {this.settings = const ZmanimSettings()})
    : location = _location(city) {
    utcOffsetHours = _offsetHours(year, month, day);
    final elevation = city.elevation;

    _alos = _sunTimes(90 + settings.alosDegrees).sunrise;
    final tefillinDeg = city.isIsrael ? settings.tefillinDegreesIsrael : settings.tefillinDegreesDiaspora;
    _tefillin = _sunTimes(90 + tefillinDeg).sunrise;

    final std = _sunTimes(sunriseZenith(elevation));
    _sunrise = std.sunrise;
    _sunset = std.sunset;
    _shaah = (_sunset - _sunrise) / 12;

    _tzeis = _sunTimes(90 + settings.tzeisDegrees).sunset;

    final elevated = _sunTimes(elevatedZenith(elevation));
    _shkiahElevated = elevated.sunset;

    final tomorrow = DateTime.utc(year, month, day + 1);
    final next = _sunTimes(sunriseZenith(elevation), tomorrow.year, tomorrow.month, tomorrow.day);
    final night = 24 - _sunset + next.sunrise;
    var layla = _sunset + night / 2;
    if (layla >= 24) layla -= 24;
    _chatzosLayla = layla;

    // Shabbat of this week: the coming Friday (today, if today is Friday).
    // Unlike npm, Friday and Saturday use their own UTC offset.
    final dow = DateTime.utc(year, month, day).weekday % 7; // 0 = Sunday
    final friday = DateTime.utc(year, month, day + (5 - dow + 7) % 7);
    final saturday = DateTime.utc(friday.year, friday.month, friday.day + 1);
    shabbosEnterDate = friday;
    shabbosExitDate = saturday;
    _shabbosEnter =
        _sunTimes(
          elevatedZenith(elevation),
          friday.year,
          friday.month,
          friday.day,
          _offsetHours(friday.year, friday.month, friday.day),
        ).sunset -
        city.candleMinutes / 60.0;
    _shabbosExit = _sunTimes(
      90 + settings.tzeisDegrees,
      saturday.year,
      saturday.month,
      saturday.day,
      _offsetHours(saturday.year, saturday.month, saturday.day),
    ).sunset;
  }

  /// The place.
  final City city;

  /// The Gregorian year.
  final int year;

  /// The Gregorian month, 1 to 12.
  final int month;

  /// The day of the month.
  final int day;

  /// The angles and fallbacks used.
  final ZmanimSettings settings;

  /// The city's time zone.
  final tz.Location location;

  /// The city's UTC offset on this date, read at local noon.
  late final double utcOffsetHours;

  /// This week's Friday: the date itself if it is a Friday, otherwise the next one.
  late final DateTime shabbosEnterDate;

  /// The Saturday after [shabbosEnterDate].
  late final DateTime shabbosExitDate;

  late final double _alos, _tefillin, _sunrise, _sunset, _shaah, _tzeis, _shkiahElevated, _chatzosLayla;
  late final double _shabbosEnter, _shabbosExit;

  double _offsetHours(int y, int m, int d) => tz.TZDateTime(location, y, m, d, 12).timeZoneOffset.inSeconds / 3600;

  ({double sunrise, double sunset}) _sunTimes(double zenith, [int? y, int? m, int? d, double? offset]) {
    var tzOffset = offset ?? utcOffsetHours;
    // Past the date line (UTC+13, +14) Meeus's local noon falls on the next
    // day. npm maps 13 to -11; this generalizes it.
    if (tzOffset >= 13) tzOffset -= 24;
    return calcSunTimes(y ?? year, m ?? month, d ?? day, city.latitude, city.longitude, tzOffset, zenith);
  }

  // ─── the times, in the npm order ───────────────────────────────────────────

  /// Dawn: the sun at [ZmanimSettings.alosDegrees] below the horizon.
  double? get alosHashachar => _n(_alos);

  /// Earliest tallis and tefillin (misheyakir), by the tefillin degrees of
  /// [ZmanimSettings].
  double? get tefillin => _n(_tefillin);

  /// Sunrise (netz hachama), with refraction adjusted for the city's elevation.
  double? get sunrise => _n(_sunrise);

  /// Sunset, with refraction adjusted for the city's elevation.
  double? get sunset => _n(_sunset);

  /// A seasonal hour, sunrise to sunset / 12 (GRA; also the Alter Rebbe's
  /// in the Siddur for Shema and Tefila).
  double? get shaahZmanis => _n(_shaah);

  /// Latest Shema, GRA: three seasonal hours after sunrise.
  double? get sofZmanShema => _n(_sunrise + _shaah * 3);

  /// Latest Shacharit, GRA: four seasonal hours after sunrise.
  double? get sofZmanTefila => _n(_sunrise + _shaah * 4);

  /// Midday: halfway between sunrise and sunset.
  double? get chatzos => _n(_sunrise + _shaah * 6);

  /// Earliest Mincha: half a seasonal hour after midday, at least 30 minutes.
  double? get minchaGedola => _n(_sunrise + _shaah * 6 + math.max(1, _shaah) / 2);

  /// Mincha ketana: nine and a half seasonal hours after sunrise.
  double? get minchaKetana => _n(_sunrise + _shaah * 9.5);

  /// Plag hamincha: ten and three-quarter seasonal hours after sunrise.
  double? get plagHamincha => _n(_sunrise + _shaah * 10.75);

  /// Sunset; the same as [sunset].
  double? get shkiah => sunset;

  /// Sunset seen from the city's elevation over a sea-level horizon. Candle
  /// lighting is counted back from it.
  double? get shkiahElevated => _n(_shkiahElevated);

  /// Nightfall: the sun at [ZmanimSettings.tzeisDegrees] below the horizon.
  double? get tzeis => _n(_tzeis);

  double get _alos72 => _sunrise - 72 / 60;
  double get _shaahMGA => ((_sunset + 72 / 60) - _alos72) / 12;

  /// Dawn as 72 minutes before sunrise (Magen Avraham).
  double? get alos72 => _n(_alos72);

  /// Latest Shema, Magen Avraham: three hours of the day from [alos72] to
  /// 72 minutes after sunset.
  double? get sofZmanShemaMGA => _n(_alos72 + _shaahMGA * 3);

  /// Latest Shacharit, Magen Avraham.
  double? get sofZmanTefilaMGA => _n(_alos72 + _shaahMGA * 4);

  /// Nightfall per Rabbeinu Tam: 72 minutes after [shkiahElevated].
  double? get tzeisRabbeinuTam => _n(_shkiahElevated + 72 / 60);

  /// Midnight: halfway between sunset and the next sunrise. When that is
  /// after 24:00 it wraps to the early hours (0.5 = 00:30).
  double? get chatzosLayla => _n(_chatzosLayla);

  /// Candle lighting if today is an eve: elevated sunset minus the city's minutes.
  double? get candleLighting => _n(_shkiahElevated - city.candleMinutes / 60);

  /// On [shabbosEnterDate] (a Friday).
  double? get shabbosEnter => _n(_shabbosEnter);

  /// On [shabbosExitDate] (a Saturday).
  double? get shabbosExit => _n(_shabbosExit);

  // ─── conversions ───────────────────────────────────────────────────────────

  /// [hours] on this date (or [on]) as a moment in the city's time zone,
  /// rounded up to the second like the npm strings.
  tz.TZDateTime? at(double? hours, {DateTime? on, bool floor = false}) {
    if (hours == null) return null;
    final date = on ?? DateTime.utc(year, month, day);
    final offset = _offsetHours(date.year, date.month, date.day);
    final seconds = floor ? (hours * 3600).floor() : (hours * 3600).ceil();
    final utc = DateTime.utc(date.year, date.month, date.day).add(Duration(seconds: seconds - (offset * 3600).round()));
    return tz.TZDateTime.from(utc, location);
  }

  /// The npm string form, "H:MM:SS", rounded up (or down with [floor]).
  static String? hms(double? hours, {bool floor = false}) {
    if (hours == null) return null;
    final total = floor ? (hours * 3600).floor() : (hours * 3600).ceil();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ─── the rest window ───────────────────────────────────────────────────────

  /// Shabbat and Yom Tov at [moment], read in [city]'s time zone whatever the
  /// device's. As npm: from candle lighting (elevated sunset minus minutes) on
  /// the eve to tzeis; a Yom Tov followed by another Yom Tov day runs on.
  static RestStatus restStatusAt(City city, DateTime moment, {ZmanimSettings settings = const ZmanimSettings()}) {
    final local = tz.TZDateTime.from(moment, _location(city));
    final z = Zmanim(city, local.year, local.month, local.day, settings: settings);
    final refHours = local.hour + local.minute / 60 + local.second / 3600;
    final chutzLaaretz = !city.isIsrael;

    final today = toJewishDate(DateTime.utc(local.year, local.month, local.day));
    final tomorrow = toJewishDate(DateTime.utc(local.year, local.month, local.day + 1));

    final tzeis = z.tzeis;
    final beforeTzeis = refHours < (tzeis ?? settings.fallbackRestEndHour);
    final candles = z.candleLighting;
    final afterCandleLighting = refHours >= (candles ?? settings.fallbackCandleLightingHour);

    final isShabbat =
        (holidays.isShabbat(today) && beforeTzeis) || (holidays.isErevShabbat(today) && afterCandleLighting);

    final yomTovToday = holidays.isYomTov(today, isChutzLaaretz: chutzLaaretz);
    final continuesTonight = holidays.isYomTov(tomorrow, isChutzLaaretz: chutzLaaretz);
    final isYomTov =
        (yomTovToday && (continuesTonight || beforeTzeis)) || (holidays.isErevYomTov(today) && afterCandleLighting);

    return RestStatus(isShabbat: isShabbat, isYomTov: isYomTov);
  }
}
