import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents the remote version info fetched from GitHub.
class _RemoteVersionInfo {
  final String version;
  final int buildNumber;
  final String releaseNotes;

  _RemoteVersionInfo({
    required this.version,
    required this.buildNumber,
    required this.releaseNotes,
  });

  factory _RemoteVersionInfo.fromJson(Map<String, dynamic> json) {
    return _RemoteVersionInfo(
      version: json['version'] as String? ?? '0.0.0',
      buildNumber: json['buildNumber'] as int? ?? 0,
      releaseNotes: json['releaseNotes'] as String? ?? '',
    );
  }
}

/// Service that checks for updates on GitHub, downloads APKs, and triggers
/// installation via the Android system installer.
class UpdateService {
  static const String _versionUrl =
      'https://raw.githubusercontent.com/brdsllg/app/main/version.json';
  static const String _releaseBaseUrl =
      'https://github.com/brdsllg/app/releases/download';

  static const String _lastCheckKey = 'update_last_check_date';
  static const String _lastBuildKey = 'update_last_available_build';

  /// Checks for an update at most once per day (by date).
  /// Returns the remote build number if an update is available, or null if
  /// the app is up to date or the check fails.
  static Future<int?> checkForUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // --- daily cooldown --------------------------------------------------
      final lastCheck = prefs.getString(_lastCheckKey);
      final today = DateTime.now().toIso8601String().split('T').first;
      if (lastCheck == today) {
        // Already checked today — use cached result
        final cachedBuild = prefs.getInt(_lastBuildKey);
        return cachedBuild;
      }

      // --- fetch remote version.json ---------------------------------------
      final response = await http.get(Uri.parse(_versionUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final remote = _RemoteVersionInfo.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      // --- compare build numbers -------------------------------------------
      final local = await PackageInfo.fromPlatform();
      final localBuild = int.tryParse(local.buildNumber) ?? 0;

      final updateAvailable = remote.buildNumber > localBuild;

      // --- persist check date and result -----------------------------------
      await prefs.setString(_lastCheckKey, today);
      if (updateAvailable) {
        await prefs.setInt(_lastBuildKey, remote.buildNumber);
        return remote.buildNumber;
      } else {
        await prefs.remove(_lastBuildKey);
        return null;
      }
    } catch (_) {
      return null; // network / parse error — fail silently
    }
  }

  /// Downloads the APK for [remoteBuildNumber] from GitHub Releases to a temp
  /// file and returns the [File] reference.  Throws on failure.
  static Future<File> downloadApk(int remoteBuildNumber) async {
    final apkUrl =
        '$_releaseBaseUrl/v$remoteBuildNumber/app-arm64-v8a-release.apk';

    final dir = await Directory.systemTemp.createTemp('app_update_');
    final file = File('${dir.path}/app-update.apk');

    final dio = Dio();
    await dio.download(
      apkUrl,
      file.path,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
    );

    return file;
  }

  /// Requests the "Install unknown apps" permission if needed.
  /// Shows a custom Material dialog before opening system settings.
  /// Returns `true` once permission is granted, `false` otherwise.
  static Future<bool> requestInstallPermission(BuildContext context) async {
    // On modern Android (API 26+), REQUEST_INSTALL_PACKAGES is granted at
    // install-time, but there is also the system-level "Install unknown apps"
    // toggle for each app that the user may need to enable.
    //
    // permission_handler exposes this as Permission.requestInstallPackages.
    final status = await Permission.requestInstallPackages.status;

    if (status.isGranted) return true;

    // Show custom Flutter dialog
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'To update the app, you need to enable "Install unknown apps" '
              'in your settings.\n\n'
              'Tap OK to open Settings, then toggle the switch on.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );

    if (shouldOpenSettings != true) return false;

    // Open the system Settings page for this app
    await openAppSettings();
    return false; // we can't know when/if the user toggled it
  }

  /// Installs the downloaded APK using the system package installer.
  /// Returns `true` if the install intent was sent successfully.
  static Future<bool> installApk(File apkFile) async {
    try {
      final result = await OpenFilex.open(
        apkFile.path,
        type: 'application/vnd.android.package-archive',
      );
      return result.type == ResultType.done;
    } catch (_) {
      return false;
    }
  }

  /// Cleans up the downloaded APK file if it still exists.
  static Future<void> deleteApk(File? apkFile) async {
    try {
      if (apkFile != null && await apkFile.exists()) {
        await apkFile.delete();
      }
    } catch (_) {
      // best-effort cleanup
    }
  }

  /// Runs the full update flow:
  /// 1. Check for update (respects daily cooldown).
  /// 2. If available, ask the user.
  /// 3. Download with progress.
  /// 4. Request install permission.
  /// 5. Install.
  /// 6. Cleanup.
  static Future<void> runUpdateFlow(BuildContext context) async {
    // -- Step 1: Check ----------------------------------------------------
    final buildNumber = await checkForUpdate();
    if (buildNumber == null) return; // up-to-date or error

    // -- Step 2: Ask user --------------------------------------------------
    final shouldUpdate = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Update Available'),
          content: const Text(
            'A new version of the app is available.\n\n'
            'Would you like to download and install it now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Later'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (shouldUpdate != true) return;

    // -- Step 3: Download --------------------------------------------------
    // Show a progress indicator dialog while downloading
    final apkFile = await showDialog<File?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // Kick off the download; capture result in the dialog
        final future = downloadApk(buildNumber);
        future.then((file) {
          if (ctx.mounted) Navigator.of(ctx).pop(file);
        }).catchError((_) {
          if (ctx.mounted) Navigator.of(ctx).pop(null);
        });
        return const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );

    if (apkFile == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download failed. Please try again later.'),
          ),
        );
      }
      return;
    }

    // -- Step 4: Permission + Install + Cleanup ---------------------------
    try {
      final hasPermission = await requestInstallPermission(context);
      if (!hasPermission) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permission denied. Enable "Install unknown apps" in Settings '
                'and try again.',
              ),
            ),
          );
        }
        return;
      }

      final installed = await installApk(apkFile);
      if (!installed && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Installation failed.')),
        );
      }
    } finally {
      // Always clean up — even on success
      await deleteApk(apkFile);
    }
  }
}