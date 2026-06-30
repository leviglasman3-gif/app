import 'package:kosher_dart/kosher_dart.dart';

void main() {
  // Test with 770 Eastern Parkway (Chabad HQ) coordinates from the article
  String locationName = "770 Eastern Parkway";
  double latitude = 40.669;
  double longitude = -73.943;
  double elevation = 30;
  
  GeoLocation location = GeoLocation.setLocation(
    locationName,
    latitude,
    longitude,
    DateTime.now(),
    elevation,
  );
  
  ComplexZmanimCalendar czc = ComplexZmanimCalendar();
  czc.setGeoLocation(location);
  
  print('=== Testing Baal Hatanya Zmanim (KosherDart) ===');
  print('Location: $locationName');
  print('');
  
  // Test all Baal Hatanya methods - call them to see if they work
  try {
    var alos = czc.getAlosBaalHatanya();
    print('getAlosBaalHatanya: $alos');
  } catch (e) {
    print('getAlosBaalHatanya ERROR: $e');
  }
  
  try {
    var sofZmanShma = czc.getSofZmanShmaBaalHatanya();
    print('getSofZmanShmaBaalHatanya: $sofZmanShma');
  } catch (e) {
    print('getSofZmanShmaBaalHatanya ERROR: $e');
  }
  
  try {
    var sofZmanTfila = czc.getSofZmanTfilaBaalHatanya();
    print('getSofZmanTfilaBaalHatanya: $sofZmanTfila');
  } catch (e) {
    print('getSofZmanTfilaBaalHatanya ERROR: $e');
  }
  
  try {
    var minchaGedola = czc.getMinchaGedolaBaalHatanya();
    print('getMinchaGedolaBaalHatanya: $minchaGedola');
  } catch (e) {
    print('getMinchaGedolaBaalHatanya ERROR: $e');
  }
  
  try {
    var minchaKetana = czc.getMinchaKetanaBaalHatanya();
    print('getMinchaKetanaBaalHatanya: $minchaKetana');
  } catch (e) {
    print('getMinchaKetanaBaalHatanya ERROR: $e');
  }
  
  try {
    var plagHamincha = czc.getPlagHaminchaBaalHatanya();
    print('getPlagHaminchaBaalHatanya: $plagHamincha');
  } catch (e) {
    print('getPlagHaminchaBaalHatanya ERROR: $e');
  }
  
  try {
    var tzaisBaalHatanya = czc.getTzaisBaalHatanya();
    print('getTzaisBaalHatanya: $tzaisBaalHatanya');
  } catch (e) {
    print('getTzaisBaalHatanya ERROR: $e');
  }
  
  try {
    var shaahZmanis = czc.getShaahZmanisBaalHatanya();
    print('getShaahZmanisBaalHatanya: $shaahZmanis');
  } catch (e) {
    print('getShaahZmanisBaalHatanya ERROR: $e');
  }
  
  try {
    var netzAmiti = czc.getSunriseBaalHatanya();
    print('getSunriseBaalHatanya: $netzAmiti');
  } catch (e) {
    print('getSunriseBaalHatanya ERROR: $e');
  }
  
  try {
    var shkiahAmitis = czc.getSunsetBaalHatanya();
    print('getSunsetBaalHatanya: $shkiahAmitis');
  } catch (e) {
    print('getSunsetBaalHatanya ERROR: $e');
  }
  
  try {
    var tzais85 = czc.getTzaisGeonim8Point5Degrees();
    print('getTzaisGeonim8Point5Degrees: $tzais85');
  } catch (e) {
    print('getTzaisGeonim8Point5Degrees ERROR: $e');
  }
}