import 'package:jewish_zmanim/jewish_zmanim.dart';

void main() {
  initializeZmanim(); // once, before any zmanim

  final z = Zmanim(NpmCities.jerusalem, 2025, 10, 17);
  print('Candle lighting: ${Zmanim.hms(z.candleLighting)}');
  print('Sunset:          ${Zmanim.hms(z.shkiah)}');

  final status = Zmanim.restStatusAt(NpmCities.brooklyn, DateTime.now());
  print('Shabbat or Yom Tov in Brooklyn now: ${status.isRest}');
}
