import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Encapsulates the platform storage-permission flow.
///
/// Android: broad PDF scanning needs MANAGE_EXTERNAL_STORAGE (PDFs aren't
/// "media", so READ_MEDIA_* doesn't cover them). iOS: sandboxed — no device
/// scan, so access is always "granted" for the import-only flow.
class PermissionService {
  const PermissionService();

  /// Short, user-facing rationale shown before requesting (Step 7.3).
  String get rationaleText =>
      'Comfy Reader scans your Downloads, Documents, and Books folders to find '
      'PDFs. We never upload or share your files — everything stays on your '
      'device.';

  bool get supportsDeviceScan => Platform.isAndroid;

  /// True if we already have broad file access (Android) or don't need it (iOS).
  Future<bool> hasBroadAccess() async {
    if (!Platform.isAndroid) return true;
    return Permission.manageExternalStorage.isGranted;
  }

  /// Requests broad storage access. Returns true if granted. Never throws;
  /// callers degrade to file-picker import on false.
  Future<bool> ensureStorageAccess() async {
    if (!Platform.isAndroid) return true;
    try {
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// True if the user permanently denied access (offer "Open settings").
  Future<bool> isPermanentlyDenied() async {
    if (!Platform.isAndroid) return false;
    return Permission.manageExternalStorage.isPermanentlyDenied;
  }

  /// Opens the system app settings (for permanently-denied recovery).
  Future<bool> openSettings() => openAppSettings();
}
