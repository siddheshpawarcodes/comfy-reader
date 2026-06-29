import 'package:flutter/material.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../services/permission_service.dart';

/// The pre-request rationale shown before any Android storage prompt (higher
/// grant rate + transparency). Returns true if the user chose to continue.
class PermissionRationaleDialog extends StatelessWidget {
  const PermissionRationaleDialog({super.key, required this.message});

  final String message;

  static Future<bool> show(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => PermissionRationaleDialog(message: message),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      icon: const Icon(Icons.folder_open_rounded),
      title: Text(l10n.findPdfsTitle),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.notNow),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.continueLabel),
        ),
      ],
    );
  }
}

/// Orchestrates the whole Android storage-access flow so Home and Settings share
/// one path: rationale → OS request → (if permanently denied) an "Open settings"
/// prompt. Returns whether broad access is granted. No-ops to `true` on
/// platforms without device scan (iOS), so callers can just gate on the result.
class StoragePermissionFlow {
  const StoragePermissionFlow([this.perm = const PermissionService()]);

  final PermissionService perm;

  Future<bool> ensure(BuildContext context) async {
    if (!perm.supportsDeviceScan) return true;
    if (await perm.hasBroadAccess()) return true;
    if (!context.mounted) return false;

    final proceed =
        await PermissionRationaleDialog.show(context, perm.rationaleText);
    if (!proceed) return false;

    final granted = await perm.ensureStorageAccess();
    if (granted) return true;

    // Denied. If the OS won't prompt again, point the user to Settings.
    final permanentlyDenied = await perm.isPermanentlyDenied();
    if (!context.mounted) return false;
    if (permanentlyDenied) {
      final openSettings = await _showOpenSettings(context);
      if (openSettings) await perm.openSettings();
    }
    return false;
  }

  Future<bool> _showOpenSettings(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.lock_outline_rounded),
        title: Text(l10n.storageAccessOff),
        content: Text(l10n.storageAccessOffBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.openSettingsLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
