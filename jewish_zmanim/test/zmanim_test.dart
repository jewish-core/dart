// The port's deliberate differences from npm (lib/jewish_zmanim.dart, 1–5),
// and a few anchors. The parity with npm itself is in npm_parity_test.dart.
import 'package:jewish_zmanim/jewish_zmanim.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' as tz;

const reykjavik = City(
  id: 'reykjavik',
  name: 'Reykjavik',
  latitude: 64.1466,
  longitude: -21.9426,
  timeZone: 'Atlantic/Reykjavik',
  isIsrael: false,
);
const tromso = City(
  id: 'tromso',
  name: 'Tromso',
  latitude: 69.6492,
  longitude: 18.9553,
  timeZone: 'Europe/Oslo',
  isIsrael: false,
);

tz.TZDateTime local(City city, int y, int m, int d, int h, [int min = 0]) =>
    tz.TZDateTime(tz.getLocation(city.timeZone), y, m, d, h, min);

bool shabbat(City city, DateTime at) => Zmanim.restStatusAt(city, at).isShabbat;
bool yomTov(City city, DateTime at) => Zmanim.restStatusAt(city, at).isYomTov;

void main() {
  initializeZmanim();
  const jerusalem = NpmCities.jerusalem;
  const brooklyn = NpmCities.brooklyn;

  group('1. the city time zone, not the device', () {
    test('the same instant gives the same answer however it is expressed', () {
      // Friday 10 Jan 2025, 16:30 in Jerusalem: after candle lighting (~16:14)
      final inJerusalem = local(jerusalem, 2025, 1, 10, 16, 30);
      final asUtc = DateTime.utc(2025, 1, 10, 14, 30);
      final asNewYork = tz.TZDateTime.from(asUtc, tz.getLocation('America/New_York'));
      expect(shabbat(jerusalem, inJerusalem), isTrue);
      expect(shabbat(jerusalem, asUtc), isTrue);
      expect(shabbat(jerusalem, asNewYork), isTrue);
      expect(shabbat(jerusalem, local(jerusalem, 2025, 1, 10, 15, 30)), isFalse);
    });
  });

  group('the day the clocks change', () {
    test('Israel, Friday 28 Mar 2025: candle lighting in summer time', () {
      final z = Zmanim(jerusalem, 2025, 3, 28);
      expect(z.utcOffsetHours, 3);
      expect(z.candleLighting, inInclusiveRange(18.1, 18.4)); // npm: an hour earlier
      expect(shabbat(jerusalem, local(jerusalem, 2025, 3, 28, 17, 30)), isFalse);
      expect(shabbat(jerusalem, local(jerusalem, 2025, 3, 28, 18, 30)), isTrue);
    });
  });

  group('2. high latitudes: null, and a stringent rest window', () {
    test('Reykjavik in June: no tzeis, Shabbat lasts the whole Saturday', () {
      final z = Zmanim(reykjavik, 2025, 6, 21);
      expect(z.tzeis, isNull);
      expect(Zmanim.hms(z.tzeis), isNull);
      expect(shabbat(reykjavik, local(reykjavik, 2025, 6, 21, 23, 30)), isTrue);
      expect(shabbat(reykjavik, local(reykjavik, 2025, 6, 22, 0, 30)), isFalse);
    });

    test('Tromsø in June: no sunset, Shabbat starts at the fallback hour', () {
      final z = Zmanim(tromso, 2025, 6, 20);
      expect(z.sunset, isNull);
      expect(z.candleLighting, isNull);
      expect(shabbat(tromso, local(tromso, 2025, 6, 20, 11, 30)), isFalse);
      expect(shabbat(tromso, local(tromso, 2025, 6, 20, 12, 30)), isTrue);
    });
  });

  group('two-day Yom Tov', () {
    // 15 Nisan 5785 = Sunday 13 Apr 2025
    test('diaspora: the first night of Pesach runs on into the second day', () {
      expect(yomTov(brooklyn, local(brooklyn, 2025, 4, 13, 22)), isTrue);
      expect(yomTov(brooklyn, local(brooklyn, 2025, 4, 14, 22)), isFalse);
    });
    test('Israel: one day', () {
      expect(yomTov(jerusalem, local(jerusalem, 2025, 4, 13, 22)), isFalse);
    });
    test('erev Pesach after candle lighting', () {
      expect(yomTov(brooklyn, local(brooklyn, 2025, 4, 12, 21)), isTrue);
    });
  });

  group('4. parameters', () {
    test('tzeis follows the degrees setting', () {
      final npm = Zmanim(jerusalem, 2025, 1, 10);
      final earlier = Zmanim(jerusalem, 2025, 1, 10, settings: const ZmanimSettings(tzeisDegrees: 6));
      expect(earlier.tzeis!, lessThan(npm.tzeis!));
    });
    test('candle lighting minutes per city: 40 Jerusalem, 30 Israel, 18 elsewhere', () {
      expect(NpmCities.jerusalem.candleMinutes, 40);
      expect(NpmCities.telAviv.candleMinutes, 30);
      expect(NpmCities.london.candleMinutes, 18);
    });
  });

  group('5. no silent UTC', () {
    test('an unknown time zone throws', () {
      const bad = City(id: 'x', name: 'X', latitude: 0, longitude: 0, timeZone: 'Nowhere/City', isIsrael: false);
      expect(() => Zmanim(bad, 2025, 1, 1), throwsA(anything));
    });
  });

  test('Shabbos Bereishis 5752 in Brooklyn — the day of the sicha', () {
    // 5 Oct 1991
    expect(shabbat(brooklyn, local(brooklyn, 1991, 10, 5, 12)), isTrue);
    final z = Zmanim(brooklyn, 1991, 10, 4);
    expect(z.shabbosEnterDate, DateTime.utc(1991, 10, 4));
    expect(Zmanim.hms(z.shabbosEnter), startsWith('18:'));
  });

  test('conversions: at() and hms() agree', () {
    final z = Zmanim(jerusalem, 2025, 7, 4);
    final t = z.at(z.sunset)!;
    expect(
      '${t.hour}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}',
      Zmanim.hms(z.sunset),
    );
  });
}
