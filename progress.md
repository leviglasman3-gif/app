# Progress: Elevation Fix for 3-4 Second Discrepancy

## Investigation Completed: 2026-06-30

### Root Cause Identified
The GeoLocation object in `_calculateZmanim()` was hardcoded with elevation=0 (sea level), but chabad.org's calculations account for the actual ground elevation via the kosher_dart elevation adjustment.

### Changes Made
**File:** `lib/zmanim_screen.dart`

Three changes were made:

1. **Line 21** - Added `double? _currentAltitude;` instance variable to store the GPS altitude alongside latitude/longitude.

2. **Line 78** - Added `_currentAltitude = position.altitude;` to capture the GPS-reported altitude when the device location is obtained.

3. **Line 122** - Changed `0, // elevation` to `_currentAltitude ?? 0, // elevation` to use the actual GPS altitude instead of hardcoded sea level, with a fallback to 0 if altitude data is unavailable.

### How It Works
- The `position.altitude` from `Geolocator.getCurrentPosition()` returns the altitude in meters above sea level
- For Melbourne/St Kilda East, this is approximately 31 meters
- The elevation affects the horizon dip calculation, which shifts sunrise/sunset times slightly
- Expected correction: approximately 3-4 seconds per shaah zmanis, bringing our calculations in line with chabad.org

### Files Referenced During Investigation
- `lib/zmanim_screen.dart` - App zmanim calculation UI
- `C:\Users\levi\AppData\Local\Pub\Cache\hosted\pub.dev\kosher_dart-2.0.20\lib\src\complex_zmanim_calendar.dart` - Baal Hatanya calculation methods
- `C:\Users\levi\AppData\Local\Pub\Cache\hosted\pub.dev\kosher_dart-2.0.20\lib\src\astronomical_calendar.dart` - Base calculation engine
- `C:\Users\levi\AppData\Local\Pub\Cache\hosted\pub.dev\kosher_dart-2.0.20\lib\src\util\noaa_calculator.dart` - NOAA sunset/sunrise algorithm
- `C:\Users\levi\AppData\Local\Pub\Cache\hosted\pub.dev\kosher_dart-2.0.20\lib\src\util\astronomical_calculator.dart` - Elevation adjustment logic
- `C:\Users\levi\AppData\Local\Pub\Cache\hosted\pub.dev\kosher_dart-2.0.20\lib\src\util\geo_location.dart` - GeoLocation class (elevation parameter)