import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../providers/library_provider.dart';
import '../../../shared/navigation.dart';

/// Accent FAB that imports a PDF via the system picker, then offers to open it.
class AddPdfFab extends StatefulWidget {
  const AddPdfFab({super.key});

  @override
  State<AddPdfFab> createState() => _AddPdfFabState();
}

class _AddPdfFabState extends State<AddPdfFab> {
  bool _importing = false;

  Future<void> _import() async {
    if (_importing) return;
    setState(() => _importing = true);
    final library = context.read<LibraryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final l10n = context.l10n;
    try {
      final book = await library.importFromPicker();
      if (!mounted) return;
      if (book == null) return; // cancelled
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.addedBook(book.title)),
          action: SnackBarAction(
            label: l10n.open,
            onPressed: () {
              if (!isReaderRoute(router)) router.push('/reader/${book.id}');
            },
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.couldntImport)),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _importing ? null : _import,
      icon: _importing
          ? SizedBox(
              width: 18.r,
              height: 18.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add_rounded),
      label: Text(context.l10n.addPdf),
    );
  }
}
