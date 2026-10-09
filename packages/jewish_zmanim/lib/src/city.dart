// Copyright (c) Shmulik Kravitz. Licensed under the MIT license.

/// A place for zmanim. Unlike the npm `CityRow`, the IANA time zone is
/// required: the npm package falls back to UTC in silence when it is missing.
class City {
  /// A city at [latitude], [longitude] (degrees; south and west negative) in
  /// the IANA time zone [timeZone].
  const City({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timeZone,
    required this.isIsrael,
    this.elevation = 0,
    this.candleLightingMinutes,
  });

  /// A stable key for your own use; the calculations ignore it.
  final String id;

  /// The display name.
  final String name;

  /// Degrees north; south is negative.
  final double latitude;

  /// Degrees east; west is negative.
  final double longitude;

  /// IANA name, e.g. "Asia/Jerusalem".
  final String timeZone;

  /// Decides the festival calendar (one day or two) and the Israeli defaults.
  final bool isIsrael;

  /// Meters above sea level.
  final double elevation;

  /// Minutes before sunset. Null for the npm default: 30 in Israel, 18 elsewhere.
  /// Jerusalem is 40 — set it on the city.
  final int? candleLightingMinutes;

  /// The minutes before sunset used for candle lighting.
  int get candleMinutes => candleLightingMinutes ?? (isIsrael ? 30 : 18);
}

/// The cities of the npm package (src/cities.ts), with their time zones.
/// For any other place, create a [City].
abstract final class NpmCities {
  /// Jerusalem; candle lighting 40 minutes before sunset.
  static const jerusalem = City(
    id: 'jerusalem',
    name: 'Jerusalem',
    latitude: 31.7683,
    longitude: 35.2137,
    timeZone: 'Asia/Jerusalem',
    isIsrael: true,
    elevation: 650,
    candleLightingMinutes: 40,
  );

  /// Tel Aviv.
  static const telAviv = City(
    id: 'telAviv',
    name: 'Tel Aviv',
    latitude: 32.0853,
    longitude: 34.7818,
    timeZone: 'Asia/Jerusalem',
    isIsrael: true,
  );

  /// Haifa.
  static const haifa = City(
    id: 'haifa',
    name: 'Haifa',
    latitude: 32.794,
    longitude: 34.9896,
    timeZone: 'Asia/Jerusalem',
    isIsrael: true,
  );

  /// Safed.
  static const safed = City(
    id: 'safed',
    name: 'Safed',
    latitude: 32.9646,
    longitude: 35.496,
    timeZone: 'Asia/Jerusalem',
    isIsrael: true,
    elevation: 570,
  );

  /// Beit Shemesh.
  static const beitShemesh = City(
    id: 'beitShemesh',
    name: 'Beit Shemesh',
    latitude: 31.7514,
    longitude: 34.9886,
    timeZone: 'Asia/Jerusalem',
    isIsrael: true,
    elevation: 205,
  );

  /// Modiin.
  static const modiin = City(
    id: 'modiin',
    name: 'Modiin',
    latitude: 31.8978,
    longitude: 35.0104,
    timeZone: 'Asia/Jerusalem',
    isIsrael: true,
    elevation: 300,
  );

  /// Maaleh Adumim.
  static const maalehAdumim = City(
    id: 'maalehAdumim',
    name: 'Maaleh Adumim',
    latitude: 31.7771,
    longitude: 35.3088,
    timeZone: 'Asia/Jerusalem',
    isIsrael: true,
    elevation: 430,
  );

  /// Beer Sheva.
  static const beerSheva = City(
    id: 'beerSheva',
    name: 'Beer Sheva',
    latitude: 31.2518,
    longitude: 34.7913,
    timeZone: 'Asia/Jerusalem',
    isIsrael: true,
  );

  /// Eilat.
  static const eilat = City(
    id: 'eilat',
    name: 'Eilat',
    latitude: 29.5577,
    longitude: 34.9519,
    timeZone: 'Asia/Jerusalem',
    isIsrael: true,
  );

  /// Kiryat Malachi.
  static const kiryatMalachi = City(
    id: 'kiryatMalachi',
    name: 'Kiryat Malachi',
    latitude: 31.7326,
    longitude: 34.7449,
    timeZone: 'Asia/Jerusalem',
    isIsrael: true,
  );

  /// New York.
  static const newYork = City(
    id: 'newYork',
    name: 'New York',
    latitude: 40.7128,
    longitude: -74.006,
    timeZone: 'America/New_York',
    isIsrael: false,
  );

  /// Brooklyn.
  static const brooklyn = City(
    id: 'brooklyn',
    name: 'Brooklyn',
    latitude: 40.6782,
    longitude: -73.9442,
    timeZone: 'America/New_York',
    isIsrael: false,
  );

  /// Miami.
  static const miami = City(
    id: 'miami',
    name: 'Miami',
    latitude: 25.7617,
    longitude: -80.1918,
    timeZone: 'America/New_York',
    isIsrael: false,
  );

  /// Paris.
  static const paris = City(
    id: 'paris',
    name: 'Paris',
    latitude: 48.8566,
    longitude: 2.3522,
    timeZone: 'Europe/Paris',
    isIsrael: false,
  );

  /// Sarcelles.
  static const sarcelles = City(
    id: 'sarcelles',
    name: 'Sarcelles',
    latitude: 48.9955,
    longitude: 2.3808,
    timeZone: 'Europe/Paris',
    isIsrael: false,
  );

  /// London.
  static const london = City(
    id: 'london',
    name: 'London',
    latitude: 51.5074,
    longitude: -0.1278,
    timeZone: 'Europe/London',
    isIsrael: false,
  );

  /// Melbourne.
  static const melbourne = City(
    id: 'melbourne',
    name: 'Melbourne',
    latitude: -37.8136,
    longitude: 144.9631,
    timeZone: 'Australia/Melbourne',
    isIsrael: false,
  );

  /// Every city above.
  static const all = [
    jerusalem,
    telAviv,
    haifa,
    safed,
    beitShemesh,
    modiin,
    maalehAdumim,
    beerSheva,
    eilat,
    kiryatMalachi,
    newYork,
    brooklyn,
    miami,
    paris,
    sarcelles,
    london,
    melbourne,
  ];
}
