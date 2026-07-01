# Release Checklist — Auto-Update System (Download Link)

## Critical: VersionCode Management

Android uses **versionCode (integer)** to determine if an update is available. The versionName string is ignored.
- Current versionCode: **2** (`pubspec.yaml` → `version: 1.0.1+2`)
- For every new release, **increment the build number** (the part after `+`):
  - `version: 1.0.2+3` → versionCode = 3
  - `version: 1.0.3+4` → versionCode = 4

The `version.json` file on GitHub must have a `buildNumber` field that matches this integer.

## Signing Key — MUST BE IDENTICAL

⚠️ **You must use the exact same Keystore (.jks file) for every release.**

If you change the signing key:
- Android will reject the APK with: `INSTALL_FAILED_UPDATE_INCOMPATIBLE`
- Users would need to uninstall the old app first, losing all local data

**Always back up your keystore file in a safe place.**

## Version Check: Creating version.json

1. Create a file named `version.json` in the root of your GitHub repository (`brdsllg/app`)
2. Push it to the `main` branch so it's accessible at:
   ```
   https://raw.githubusercontent.com/brdsllg/app/main/version.json
   ```

**Format:**
```json
{
  "version": "1.0.1",
  "buildNumber": 2,
  "releaseNotes": "Bug fixes and improvements",
  "downloadUrl": "https://github.com/brdsllg/app/releases/download/v2/app-release.apk"
}
```

- `buildNumber` must match the versionCode in your Android build (the integer after `+` in pubspec.yaml)
- `downloadUrl` is the direct link to the APK file — this opens in the device browser for instant download
- The auto-update system compares `buildNumber` against the local versionCode

## Release Process (Step by Step)

1. **Bump version** in `pubspec.yaml`:
   - Increment the build number: `1.0.1+2` → `1.0.2+3`

2. **Update `version.json`** on GitHub:
   - Set `buildNumber` to match the new versionCode
   - Update `version`, `releaseNotes`, and `downloadUrl`

3. **Build the release APK:**
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`

4. **Create a GitHub Release:**
   - Tag: `v{versionCode}` (e.g., `v3` for versionCode 3)
   - Upload `app-release.apk` (or rename the generated APK to this name)
   - The `downloadUrl` in `version.json` becomes: `https://github.com/brdsllg/app/releases/download/v{versionCode}/app-release.apk`

5. **Test the update** by running the previous version on a device

## How the Update Flow Works

1. App launches → checks `version.json` once per day
2. If `buildNumber` > local versionCode → shows dialog with version and release notes
3. User taps **"Download"** → opens the `downloadUrl` in the device browser
4. APK downloads directly → user taps the notification to install

## Update Frequency

- Checks for updates **once per day** (using date-based cooldown in SharedPreferences)
- Checks silently on app launch
- Only prompts the user if a newer version is available
