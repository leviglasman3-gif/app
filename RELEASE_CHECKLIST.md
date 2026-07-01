# Release Checklist — Auto-Update System

## Critical: VersionCode Management

Android uses **versionCode (integer)** to determine if an update is available. The versionName string is ignored.
- Current versionCode: **1** (`pubspec.yaml` → `version: 1.0.0+1`)
- For every new release, **increment the build number** (the part after `+`):
  - `version: 1.0.1+2` → versionCode = 2
  - `version: 1.0.2+3` → versionCode = 3

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
  "releaseNotes": "Bug fixes and improvements"
}
```

- `buildNumber` must match the versionCode in your Android build (the integer after `+` in pubspec.yaml)
- The auto-update system compares `buildNumber` against the local versionCode

## Release Process (Step by Step)

1. **Bump version** in `pubspec.yaml`:
   - Increment the build number: `1.0.0+1` → `1.0.1+2`

2. **Update `version.json`** on GitHub:
   - Set `buildNumber` to match the new versionCode
   - Update `version` and `releaseNotes`

3. **Build the release APK:**
   ```bash
   flutter build apk --target-platform android-arm64 --release
   ```
   Output: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

4. **Create a GitHub Release:**
   - Tag: `v2` (must match the buildNumber, e.g., `v2` for versionCode 2)
   - Upload `app-arm64-v8a-release.apk`
   - The APK URL becomes: `https://github.com/brdsllg/app/releases/download/v{X}/app-arm64-v8a-release.apk`
   - Where `{X}` is the build number

5. **Test the update** by running the previous version on a device

## FileProvider Note

The app uses Android's `FileProvider` to safely share the downloaded APK with the system installer.
- Provider authority: `${applicationId}.fileprovider`
- Path config: `android/app/src/main/res/xml/provider_paths.xml`
- Cache directory is used for temporary APK storage

## APK Cleanup

The `UpdateService` automatically deletes the downloaded APK:
- After the installation intent is triggered
- If the download fails
- If the user cancels

No manual cleanup needed.

## Update Frequency

- Checks for updates **once per day** (using date-based cooldown in SharedPreferences)
- Checks silently on app launch
- Only prompts the user if a newer version is available