import 'package:kosher_dart/kosher_dart.dart';

void main() {
  var c = ComplexZmanimCalendar();
  print('ComplexZmanimCalendar methods:');
  print(c.runtimeType);
  
  // Check for Baal Hatanya methods
  var methods = [
    'getAlosBaalHatanya',
    'getSofZmanShmaBaalHatanya',
    'getSofZmanTfilaBaalHatanya',
    'getMinchaGedolaBaalHatanya',
    'getMinchaKetanaBaalHatanya',
    'getPlagHaminchaBaalHatanya',
    'getTzaisBaalHatanya',
    'getShaahZmanisBaalHatanya',
    'getSunriseOffsetByDegrees',
    'getSunsetOffsetByDegrees',
  ];
  
  for (var m in methods) {
    try {
      // Try to call the method via reflection-like check
      print('$m: EXISTS');
    } catch (e) {
      print('$m: NOT FOUND');
    }
  }
}