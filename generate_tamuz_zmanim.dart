import 'package:kosher_dart/kosher_dart.dart';

void main() {
  // Coordinates: -37, 144 (latitude, longitude)
  final double latitude = -37;
  final double longitude = 144;
  final String locationName = 'Lat: $latitude, Lng: $longitude';
  
  // Date range: Tamuz 5786 (June 16 - July 14, 2026)
  final DateTime startDate = DateTime(2026, 6, 16);
  final DateTime endDate = DateTime(2026, 7, 14);
  
  // Print markdown table header
  print('| Date | Alot Hashachar (Dawn) | Netz HaChama (Sunrise) | Sof Zman K"S (Latest Shema) | Sof Zman Tefilah (Latest Tefillah) | Mincha Gedola | Mincha Ketanah | Plag HaMincha | Shkiah (Sunset) | Tzeit Hakochavim (Nightfall) | Tzeit 8.5° | Sof Zman Achilas Chametz | Sof Zman Biur Chametz | Shaah Zmanit |');
  print('|------|----------------------|------------------------|-----------------------------|------------------------------------|---------------|----------------|---------------|-----------------|------------------------------|------------|--------------------------|------------------------|--------------|');
  
  // Iterate through each day
  DateTime currentDate = startDate;
  while (!currentDate.isAfter(endDate)) {
    // Create timezone-adjusted DateTime (kosher_dart uses the DateTime's own timezone)
    final tzOffset = DateTime.now().timeZoneOffset;
    final now = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      currentDate.hour,
      currentDate.minute,
      currentDate.second,
      currentDate.millisecond,
    ).add(tzOffset);
    
    // Create GeoLocation
    final location = GeoLocation.setLocation(
      locationName,
      latitude,
      longitude,
      now,
      0, // elevation
    );
    location.setLocationName(locationName);
    
    // Create calendar for today
    final calendar = ComplexZmanimCalendar();
    calendar.setGeoLocation(location);
    
    // Get tomorrow's netz amiti for midnight calculation
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowCalendar = ComplexZmanimCalendar();
    tomorrowCalendar.setGeoLocation(location);
    tomorrowCalendar.setCalendar(tomorrow);
    final netzAmitiTomorrow = tomorrowCalendar.getSunriseBaalHatanya();
    
    // Helper function: add temporal hours to a DateTime
    DateTime? addTemporalHours(DateTime? start, double hours) {
      if (start == null) return null;
      final shaahZmanisMs = calendar.getShaahZmanisBaalHatanya();
      if (shaahZmanisMs <= 0) return null;
      return start.add(Duration(milliseconds: (shaahZmanisMs * hours).toInt()));
    }
    
    // Calculate all zmanim using native Baal Hatanya methods
    final netzAmiti = calendar.getSunriseBaalHatanya(); // Sunrise (netz amiti)
    final shkiahAmitis = calendar.getSunsetBaalHatanya(); // Sunset (shkiah amiti)
    final shaahZmanisMs = calendar.getShaahZmanisBaalHatanya();
    
    final zmanim = {
      'Alot Hashachar': calendar.getAlosBaalHatanya(),
      'Netz HaChama': netzAmiti,
      'Sof Zman K"S': calendar.getSofZmanShmaBaalHatanya(),
      'Sof Zman Tefilah': calendar.getSofZmanTfilaBaalHatanya(),
      'Mincha Gedola': calendar.getMinchaGedolaBaalHatanya(),
      'Mincha Ketanah': calendar.getMinchaKetanaBaalHatanya(),
      'Plag HaMincha': calendar.getPlagHaminchaBaalHatanya(),
      'Shkiah': shkiahAmitis,
      'Tzeit Hakochavim': calendar.getTzaisBaalHatanya(),
      'Tzeit 8.5°': calendar.getTzaisGeonim8Point5Degrees(),
      'Sof Zman Achilas Chametz': calendar.getSofZmanAchilasChametzBaalHatanya(),
      'Sof Zman Biur Chametz': calendar.getSofZmanBiurChametzBaalHatanya(),
      'Midnight': _midnightBetween(shkiahAmitis, netzAmitiTomorrow),
      'Shaah Zmanit': shaahZmanisMs > 0 ? 
          DateTime.fromMillisecondsSinceEpoch(
            shaahZmanisMs.toInt()
          ) : null,
    };
    
    // Format time helper
    String formatTime(DateTime? time) {
      if (time == null) return '--:--';
      final hour = time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final second = time.second.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
      final hourStr = displayHour.toString().padLeft(2, '0');
      return '$hourStr:$minute:$second $period';
    }
    
    // Format date
    final String dateStr = '${currentDate.month}/${currentDate.day}/${currentDate.year}';
    
    // Print table row
    print('| $dateStr | ${formatTime(zmanim['Alot Hashachar'])} | ${formatTime(zmanim['Netz HaChama'])} | ${formatTime(zmanim['Sof Zman K"S'])} | ${formatTime(zmanim['Sof Zman Tefilah'])} | ${formatTime(zmanim['Mincha Gedola'])} | ${formatTime(zmanim['Mincha Ketanah'])} | ${formatTime(zmanim['Plag HaMincha'])} | ${formatTime(zmanim['Shkiah'])} | ${formatTime(zmanim['Tzeit Hakochavim'])} | ${formatTime(zmanim['Tzeit 8.5°'])} | ${formatTime(zmanim['Sof Zman Achilas Chametz'])} | ${formatTime(zmanim['Sof Zman Biur Chametz'])} | ${formatTime(zmanim['Shaah Zmanit'])} |');
    
    // Move to next day
    currentDate = currentDate.add(const Duration(days: 1));
  }
}

DateTime? _midnightBetween(DateTime? a, DateTime? b) {
  if (a == null || b == null) return null;
  final midpointMs = (a.millisecondsSinceEpoch + b.millisecondsSinceEpoch) ~/ 2;
  return DateTime.fromMillisecondsSinceEpoch(midpointMs);
}