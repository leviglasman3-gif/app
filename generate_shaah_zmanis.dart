import 'package:kosher_dart/kosher_dart.dart';

void main() {
  // Coordinates: -37.81666666666667, 144.96666666666667 (Melbourne area)
  final double latitude = -37.81666666666667;
  final double longitude = 144.96666666666667;
  final String locationName = 'Lat: $latitude, Lng: $longitude';

  // Date range: July 1–31, 2026
  final DateTime startDate = DateTime(2026, 7, 1);
  final DateTime endDate = DateTime(2027, 7, 1);

  // Print markdown table header
  print('| Date | Shaah Zmanis (Baal Hatanya) |');
  print('|------|-----------------------------|');

  // Iterate through each day
  DateTime currentDate = startDate;
  while (!currentDate.isAfter(endDate)) {
    // Timezone-adjusted DateTime (kosher_dart uses the DateTime's own timezone)
    final tzOffset = DateTime.now().timeZoneOffset;
    final now = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
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

    // Get Shaah Zmanis Baal Hatanya in milliseconds
    final shaahZmanisMs = calendar.getShaahZmanisBaalHatanya();

    // Convert to minutes and seconds
    final minutes = shaahZmanisMs > 0 ? (shaahZmanisMs / 60000).floor() : 0;
    final seconds = shaahZmanisMs > 0 ? ((shaahZmanisMs % 60000) / 1000).round() : 0;

    // Format date
    final String dateStr = '${currentDate.month}/${currentDate.day}/${currentDate.year}';

    // Format shaah zmanis display
    final String shaahDisplay = shaahZmanisMs > 0
        ? '${minutes.toString().padLeft(2, '0')} min ${seconds.toString().padLeft(2, '0')} sec'
        : '--:--';

    // Print table row
    print('| $dateStr | $shaahDisplay |');

    // Move to next day
    currentDate = currentDate.add(const Duration(days: 1));
  }
}