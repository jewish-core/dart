// Copyright (c) Shmulik Kravitz. Licensed under the MIT license.
//
// Jean Meeus solar position algorithm, ported line by line from src/solar.ts.
// Results are fractional hours; NaN where the sun never reaches the zenith.

import 'dart:math' as math;

const _d2r = math.pi / 180;
const _r2d = 180 / math.pi;

/// JS `%` keeps the sign of the dividend; Dart's `%` does not. The npm code
/// relies on the JS behavior before adding 360.
double _jsMod(double a, double b) => a.remainder(b);

double julianDay(int year, int month, int day) {
  var y = year, m = month;
  if (m <= 2) {
    y--;
    m += 12;
  }
  final a = (y / 100).floor();
  final b = 2 - a + (a / 4).floor();
  return (365.25 * (y + 4716)).floorToDouble() + (30.6001 * (m + 1)).floorToDouble() + day + b - 1524.5;
}

double julianCentury(double jd) => (jd - 2451545.0) / 36525.0;

double _sunMeanLong(double t) => (_jsMod(280.46646 + t * (36000.76983 + t * 0.0003032), 360) + 360) % 360;

double _sunMeanAnomaly(double t) => (_jsMod(357.52911 + t * (35999.05029 - t * 0.0001537), 360) + 360) % 360;

double _eccentricity(double t) => 0.016708634 - t * (0.000042037 + t * 0.0000001267);

double _sunEqOfCenter(double t) {
  final m = _sunMeanAnomaly(t) * _d2r;
  return math.sin(m) * (1.914602 - t * (0.004817 + t * 0.000014)) +
      math.sin(2 * m) * (0.019993 - t * 0.000101) +
      math.sin(3 * m) * 0.000289;
}

double _sunApparentLong(double t) {
  final omega = 125.04 - 1934.136 * t;
  return _sunMeanLong(t) + _sunEqOfCenter(t) - 0.00569 - 0.00478 * math.sin(omega * _d2r);
}

double _obliquityCorr(double t) {
  final sec = 21.448 - t * (46.815 + t * (0.00059 - t * 0.001813));
  final meanObliq = 23 + (26 + sec / 60) / 60;
  final omega = 125.04 - 1934.136 * t;
  return meanObliq + 0.00256 * math.cos(omega * _d2r);
}

double solarDeclination(double t) =>
    math.asin(math.sin(_obliquityCorr(t) * _d2r) * math.sin(_sunApparentLong(t) * _d2r)) * _r2d;

/// Minutes.
double equationOfTime(double t) {
  final obliq = _obliquityCorr(t) * _d2r;
  final l0 = _sunMeanLong(t) * _d2r;
  final e = _eccentricity(t);
  final m = _sunMeanAnomaly(t) * _d2r;
  var y = math.tan(obliq / 2);
  y *= y;
  final eot =
      y * math.sin(2 * l0) -
      2 * e * math.sin(m) +
      4 * e * y * math.sin(m) * math.cos(2 * l0) -
      0.5 * y * y * math.sin(4 * l0) -
      1.25 * e * e * math.sin(2 * m);
  return 4 * eot * _r2d;
}

double hourAngleDeg(double lat, double dec, double zenith) {
  final latRad = lat * _d2r;
  final decRad = dec * _d2r;
  final zenRad = zenith * _d2r;
  final denom = math.cos(latRad) * math.cos(decRad);
  if (denom.abs() < 1e-12) return double.nan;
  final cosHA = (math.cos(zenRad) - math.sin(latRad) * math.sin(decRad)) / denom;
  if (cosHA.abs() > 1) return double.nan;
  return math.acos(cosHA) * _r2d;
}

/// Geometric dip of the horizon, in degrees, for an observer [h] meters up.
double elevationDip(double h) => h <= 0 ? 0 : math.acos(6371000 / (6371000 + h)) * _r2d;

/// Atmospheric pressure at elevation [h] meters, in hPa.
double pressureAtElevation(double h) => 1013.25 * math.pow(1 - 2.25577e-5 * h, 5.25588);

/// Sunrise/sunset zenith: 90° + 16' semi-diameter + 34' refraction, with the
/// refraction scaled down by the pressure at elevation [h].
double sunriseZenith(double h) {
  const semiDiameter = 16 / 60;
  const seaLevelRefraction = 34 / 60;
  if (h <= 0) return 90 + semiDiameter + seaLevelRefraction;
  return 90 + semiDiameter + seaLevelRefraction * (pressureAtElevation(h) / 1013.25);
}

/// Zenith for an observer at [h] meters looking at a sea-level horizon.
double elevatedZenith(double h) => 90 + 50 / 60 + elevationDip(h);

typedef SunTimes = ({double sunrise, double sunset});

/// Sunrise and sunset in fractional local hours for UTC offset [tz] hours.
SunTimes calcSunTimes(int year, int month, int day, double lat, double lon, double tz, double zenith) {
  final jd = julianDay(year, month, day);

  // First pass: at local solar noon
  final approxNoonUT = 12 - tz - lon / 15;
  final t0 = julianCentury(jd + approxNoonUT / 24);
  final eot0 = equationOfTime(t0);
  final dec0 = solarDeclination(t0);
  final ha0 = hourAngleDeg(lat, dec0, zenith);
  if (ha0.isNaN) return (sunrise: double.nan, sunset: double.nan);
  final noon0 = 720 - 4 * lon - eot0 + tz * 60;
  final rise0 = (noon0 - ha0 * 4) / 60;
  final set0 = (noon0 + ha0 * 4) / 60;

  // Second pass: refine at the event times
  final tr = julianCentury(jd + (rise0 - tz) / 24);
  final eotR = equationOfTime(tr);
  final haR = hourAngleDeg(lat, solarDeclination(tr), zenith);
  final ts = julianCentury(jd + (set0 - tz) / 24);
  final eotS = equationOfTime(ts);
  final haS = hourAngleDeg(lat, solarDeclination(ts), zenith);
  if (haR.isNaN || haS.isNaN) return (sunrise: rise0, sunset: set0);

  final noonR = 720 - 4 * lon - eotR + tz * 60;
  final noonS = 720 - 4 * lon - eotS + tz * 60;
  return (sunrise: (noonR - haR * 4) / 60, sunset: (noonS + haS * 4) / 60);
}
