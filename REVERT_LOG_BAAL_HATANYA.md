# Revert Log: Baal Hatanya Native Implementation

## Date: 2026-06-30

## What was changed:
Replaced manual `getSunriseOffsetByDegrees(90 + 1.583)` calculations in `lib/zmanim_screen.dart` 
with native `kosher_dart` Baal Hatanya methods that match Chabad.org.

Files modified:
- `lib/zmanim_screen.dart` - replaced `_calculateZmanim()` method
- `REVERT_LOG_BAAL_HATANYA.md` - this file
- `progress.md` - updated

## Git Revert Command:
```bash
git checkout -- lib/zmanim_screen.dart
```

## Changes made to `lib/zmanim_screen.dart`:

### File: `lib/zmanim_screen.dart`
### Method: `_calculateZmanim()` (was lines 94-213)

**What changed:**
1. `getSunriseOffsetByDegrees(90 + 1.583)` → `getSunriseBaalHatanya()` / `getSunsetBaalHatanya()`
2. Manual shaah zmanis calculation (diff between netz/shkiah / 12) → `getShaahZmanisBaalHatanya()`
3. `addTemporalHours(netzAmiti, 3)` → `getSofZmanShmaBaalHatanya()`
4. `addTemporalHours(netzAmiti, 4)` → `getSofZmanTfilaBaalHatanya()`
5. `addTemporalHours(netzAmiti, 6.5)` → `getMinchaGedolaBaalHatanya()`
6. `subtractTemporalHours(shkiahAmitis, 2.5)` → `getMinchaKetanaBaalHatanya()`
7. `subtractTemporalHours(shkiahAmitis, 1.25)` → `getPlagHaminchaBaalHatanya()`
8. `getSunsetOffsetByDegrees(90 + 6.0)` → `getTzaisBaalHatanya()`
9. `getSunriseOffsetByDegrees(90 + 16.9)` → `getAlosBaalHatanya()`
10. Added: `getTzaisGeonim8Point5Degrees()` as "Nightfall 8.5° (Tzeit L'Chumra)"
11. Added: `getSofZmanAchilasChametzBaalHatanya()` as "Sof Zman Achilas Chametz"
12. Added: `getSofZmanBiurChametzBaalHatanya()` as "Sof Zman Biur Chametz"
13. Removed: Manual `addTemporalHours` and `subtractTemporalHours` helper usage for Baal Hatanya zmanim (still used for Chatzot calculation)

**OLD CODE (full original method):**
```dart
  void _calculateZmanim() {
    final lat = _currentLatitude;
    final lng = _currentLongitude;

    try {
      // kosher_dart uses the DateTime's own timezone offset for all calculations,
      // so make sure the selected date is represented in the device's timezone.
      final tzOffset = DateTime.now().timeZoneOffset;
      final now = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedDate.hour,
        _selectedDate.minute,
        _selectedDate.second,
        _selectedDate.millisecond,
      ).add(tzOffset);

      // Create GeoLocation for current position.
      // kosher_dart 2.0.20 GeoLocation.setLocation takes:
      // locationName, latitude, longitude, dateTime, [elevation]
      final location = GeoLocation.setLocation(
        _locationName ?? 'Current Location',
        lat!, // latitude (negative = South)
        lng!, // longitude (negative = West, positive = East)
        now,
        0, // elevation
      );
      location.setLocationName(_locationName ?? 'Current Location');

      final calendar = ComplexZmanimCalendar();
      calendar.setGeoLocation(location);

      // Core Baal HaTanya / Chabad values
      final netzAmiti = calendar.getSunriseOffsetByDegrees(90 + 1.583); // Baal HaTanya sunrise
      final shkiahAmitis = calendar.getSunsetOffsetByDegrees(90 + 1.583); // Baal HaTanya sunset

      double shaahZmanisMs = 0;
      if (netzAmiti != null && shkiahAmitis != null) {
        shaahZmanisMs = (shkiahAmitis.millisecondsSinceEpoch - netzAmiti.millisecondsSinceEpoch).toDouble();
        shaahZmanisMs /= 12;
      }

      // Tomorrow morning's netz amiti for correct midnight calculation
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowCalendar = ComplexZmanimCalendar();
      tomorrowCalendar.setGeoLocation(location);
      tomorrowCalendar.setCalendar(tomorrow);
      final netzAmitiTomorrow = tomorrowCalendar.getSunriseOffsetByDegrees(90 + 1.583);

      // Helper function: add temporal hours to a DateTime
      DateTime? addTemporalHours(DateTime? start, double hours) {
        if (start == null) return null;
        return start.add(Duration(milliseconds: (shaahZmanisMs * hours).toInt()));
      }

      DateTime? subtractTemporalHours(DateTime? start, double hours) {
        if (start == null) return null;
        return start.subtract(Duration(milliseconds: (shaahZmanisMs * hours).toInt()));
      }

      final sunrise = calendar.getSunrise();
      final sunset = calendar.getSunset();

      // Calculate each zman
      final zmanim = <String, Object?>{
        ' Dawn (Alot Hashachar)':
            calendar.getSunriseOffsetByDegrees(90 + 16.9),

        ' Earliest Tallit and Tefillin (Misheyakir)':
            calendar.getSunriseOffsetByDegrees(90 + 10.2),

        ' Sunrise (Hanetz Hachamah)':
            sunrise,

        ' Latest Shema (Sof Zman Krias Shema)':
            addTemporalHours(netzAmiti, 3),

        ' Latest Shacharit (Sof Zman Shachris)':
            addTemporalHours(netzAmiti, 4),

        ' Midday (Chatzot Hayom)':
            addTemporalHours(netzAmiti, 6),

        ' Earliest Mincha (Mincha Gedolah)':
            addTemporalHours(netzAmiti, 6.5),

        ' Mincha Ketanah ("Small Mincha")':
            subtractTemporalHours(shkiahAmitis, 2.5),

        ' Plag Hamincha ("Half of Mincha")':
            subtractTemporalHours(shkiahAmitis, 1.25),

        ' Sunset (Shkiah)':
            sunset,

        ' Nightfall (Tzeit Hakochavim)':
            calendar.getSunsetOffsetByDegrees(90 + 6.0),

        // Midnight: midpoint between tonight's shkiah amitis and tomorrow's netz amiti
        ' Midnight (Chatzot HaLailah)':
            _midnightBetween(shkiahAmitis, netzAmitiTomorrow),
      };

      // Format shaah zmanis as minutes and seconds string
      final shaahMinutes = (shaahZmanisMs / 60000).floor();
      final shaahSeconds = ((shaahZmanisMs % 60000) / 1000).round();

      setState(() {
        _zmanim.addAll(zmanim);
        _shaahZmanisDisplay = ' Shaah Zmanit (proportional hour): $shaahMinutes min $shaahSeconds sec';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
```

**NEW CODE (replacement):**
```dart
  // BAAL_HATANYA_NATIVE: Replaced manual degree-offset calculations with native kosher_dart
  // Baal Hatanya methods that match Chabad.org. See REVERT_LOG_BAAL_HATANYA.md to revert.
  void _calculateZmanim() {
    final lat = _currentLatitude;
    final lng = _currentLongitude;

    try {
      // kosher_dart uses the DateTime's own timezone offset for all calculations,
      // so make sure the selected date is represented in the device's timezone.
      final tzOffset = DateTime.now().timeZoneOffset;
      final now = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedDate.hour,
        _selectedDate.minute,
        _selectedDate.second,
        _selectedDate.millisecond,
      ).add(tzOffset);

      // Create GeoLocation for current position.
      // kosher_dart 2.0.20 GeoLocation.setLocation takes:
      // locationName, latitude, longitude, dateTime, [elevation]
      final location = GeoLocation.setLocation(
        _locationName ?? 'Current Location',
        lat!, // latitude (negative = South)
        lng!, // longitude (negative = West, positive = East)
        now,
        0, // elevation
      );
      location.setLocationName(_locationName ?? 'Current Location');

      // BAAL_HATANYA_NATIVE: Using native ComplexZmanimCalendar Baal Hatanya methods
      final calendar = ComplexZmanimCalendar();
      calendar.setGeoLocation(location);

      // BAAL_HATANYA_NATIVE: Use native getSunriseBaalHatanya / getSunsetBaalHatanya (1.583° offset)
      final netzAmiti = calendar.getSunriseBaalHatanya();
      final shkiahAmitis = calendar.getSunsetBaalHatanya();

      // BAAL_HATANYA_NATIVE: Use native shaah zmanis (milliseconds double) for the day
      final shaahZmanisMs = calendar.getShaahZmanisBaalHatanya();

      // Tomorrow morning's netz amiti for correct midnight calculation
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowCalendar = ComplexZmanimCalendar();
      tomorrowCalendar.setGeoLocation(location);
      tomorrowCalendar.setCalendar(tomorrow);
      // BAAL_HATANYA_NATIVE: Use native method for tomorrow
      final netzAmitiTomorrow = tomorrowCalendar.getSunriseBaalHatanya();

      // Helper function: add temporal hours to a DateTime
      DateTime? addTemporalHours(DateTime? start, double hours) {
        if (start == null || shaahZmanisMs <= 0) return null;
        return start.add(Duration(milliseconds: (shaahZmanisMs * hours).toInt()));
      }

      DateTime? subtractTemporalHours(DateTime? start, double hours) {
        if (start == null || shaahZmanisMs <= 0) return null;
        return start.subtract(Duration(milliseconds: (shaahZmanisMs * hours).toInt()));
      }

      final sunrise = calendar.getSunrise();
      final sunset = calendar.getSunset();

      // BAAL_HATANYA_NATIVE: All zmanim use native Baal Hatanya methods
      final zmanim = <String, Object?>{
        // BAAL_HATANYA_NATIVE: 16.9° - 72 min before netz amiti
        ' Dawn (Alot Hashachar)':
            calendar.getAlosBaalHatanya(),

        ' Earliest Tallit and Tefillin (Misheyakir)':
            calendar.getSunriseOffsetByDegrees(90 + 10.2),

        ' Sunrise (Hanetz Hachamah)':
            sunrise,

        // BAAL_HATANYA_NATIVE: 3 shaos zmaniyos after netz amiti
        ' Latest Shema (Sof Zman Krias Shema)':
            calendar.getSofZmanShmaBaalHatanya(),

        // BAAL_HATANYA_NATIVE: 4 shaos zmaniyos after netz amiti
        ' Latest Shacharit (Sof Zman Shachris)':
            calendar.getSofZmanTfilaBaalHatanya(),

        ' Midday (Chatzot Hayom)':
            addTemporalHours(netzAmiti, 6),

        // BAAL_HATANYA_NATIVE: 6.5 shaos zmaniyos after netz amiti
        ' Earliest Mincha (Mincha Gedolah)':
            calendar.getMinchaGedolaBaalHatanya(),

        // BAAL_HATANYA_NATIVE: 9.5 shaos zmaniyos after netz amiti
        ' Mincha Ketanah ("Small Mincha")':
            calendar.getMinchaKetanaBaalHatanya(),

        // BAAL_HATANYA_NATIVE: 10.75 shaos zmaniyos after netz amiti
        ' Plag Hamincha ("Half of Mincha")':
            calendar.getPlagHaminchaBaalHatanya(),

        ' Sunset (Shkiah)':
            sunset,

        // BAAL_HATANYA_NATIVE: 6° below horizon
        ' Nightfall (Tzeit Hakochavim)':
            calendar.getTzaisBaalHatanya(),

        // BAAL_HATANYA_NATIVE: 8.5° lechumra
        ' Nightfall 8.5° (Tzeit L\'Chumra)':
            calendar.getTzaisGeonim8Point5Degrees(),

        // BAAL_HATANYA_NATIVE: 4 shaos - Erev Pesach relevant
        ' Sof Zman Achilas Chametz':
            calendar.getSofZmanAchilasChametzBaalHatanya(),

        // BAAL_HATANYA_NATIVE: 5 shaos - Erev Pesach relevant
        ' Sof Zman Biur Chametz':
            calendar.getSofZmanBiurChametzBaalHatanya(),

        // Midnight: midpoint between tonight's shkiah amitis and tomorrow's netz amiti
        ' Midnight (Chatzot HaLailah)':
            _midnightBetween(shkiahAmitis, netzAmitiTomorrow),
      };

      // Format shaah zmanis as minutes and seconds string
      final shaahMinutes = (shaahZmanisMs / 60000).floor();
      final shaahSeconds = ((shaahZmanisMs % 60000) / 1000).round();

      setState(() {
        _zmanim.addAll(zmanim);
        // BAAL_HATANYA_NATIVE: Shaah zmanis now from getShaahZmanisBaalHatanya()
        _shaahZmanisDisplay = ' Shaah Zmanit (Baal Hatanya): $shaahMinutes min $shaahSeconds sec';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }