# Progress — Auto-Update Implementation

## Completed

1. **pubspec.yaml** — Added 5 dependencies: dio, open_filex, package_info_plus, permission_handler, http
2. **AndroidManifest.xml** — Added INTERNET + REQUEST_INSTALL_PACKAGES permissions + FileProvider configuration
3. **provider_paths.xml** — Created at `android/app/src/main/res/xml/provider_paths.xml` (cache-path)
4. **UpdateService** — Created at `lib/services/update_service.dart`:
   - Daily cooldown check via SharedPreferences
   - Fetches version.json from `raw.githubusercontent.com/brdsllg/app/main/version.json`
   - Compares buildNumber (versionCode) with local app version
   - Downloads APK from GitHub Releases with Dio
   - Permission dialog → opens system settings for "Install unknown apps"
   - Installs via open_filex with FileProvider
   - APK cleanup in finally block (on success + failure)
5. **main.dart** — Added `UpdateService.runUpdateFlow(context)` call in `_AppGate._init()`
6. **RELEASE_CHECKLIST.md** — Documented versionCode management, signing key requirement, release process

## Key Design Decisions
- Update check is **non-blocking** — runs after UI is ready, doesn't delay app launch
- Uses **buildNumber (versionCode)** for comparison, not versionName string
- **3 snackbar messages** for user feedback: download failed, permission denied, installation failed
- Cleanup deletes APK in all cases (install success, failure, or user cancel)
- All network/parse errors fail **silently** — no crash if GitHub is unreachable

## Files Changed
- `pubspec.yaml` — dependencies added
- `android/app/src/main/AndroidManifest.xml` — permissions + provider
- `android/app/src/main/res/xml/provider_paths.xml` — NEW
- `lib/services/update_service.dart` — NEW
- `lib/main.dart` — import + runUpdateFlow call
- `RELEASE_CHECKLIST.md` — NEW