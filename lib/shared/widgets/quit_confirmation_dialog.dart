import 'package:flutter/material.dart';

import '../../core/l10n/l10n_ext.dart';

/// Confirms the user wants to leave the app when back/swipe-back is pressed
/// on a screen with no back stack (e.g. the home shell). Returns true if the
/// user chose to quit.
class QuitConfirmationDialog extends StatelessWidget {
  const QuitConfirmationDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const QuitConfirmationDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.quitAppTitle),
      content: Text(l10n.quitAppMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.exit),
        ),
      ],
    );
  }
}
