import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/dimens.dart';
import '../../../models/book_model.dart';
import '../../../providers/library_provider.dart';

/// Long-press actions for a library book: remove, details.
/// (Sharing is parked in "Future / Optional" for v1.)
class BookContextSheet extends StatelessWidget {
  const BookContextSheet._(this.book);

  final BookModel book;

  static Future<void> show(BuildContext context, BookModel book) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => BookContextSheet._(book),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Dimens.space4,
          0,
          Dimens.space4,
          Dimens.space4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Dimens.space2),
              child: Text(
                book.title,
                style: theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(context.l10n.details),
              onTap: () {
                Navigator.of(context).pop();
                _showDetails(context, book);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.error,
              ),
              title: Text(
                context.l10n.removeFromLibrary,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () async {
                final library = context.read<LibraryProvider>();
                Navigator.of(context).pop();
                await library.removeBook(book);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, BookModel book) {
    final mb = (book.fileSize / (1024 * 1024));
    final sizeStr = mb >= 1
        ? '${mb.toStringAsFixed(1)} MB'
        : '${(book.fileSize / 1024).toStringAsFixed(0)} KB';
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(book.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(l10n.detailPages, '${book.totalPages}'),
            _row(l10n.detailSize, sizeStr),
            _row(l10n.detailProgress, '${(book.progress * 100).round()}%'),
            _row(
              l10n.detailSource,
              book.isImported ? l10n.sourceImported : l10n.sourceOnDevice,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(value)],
        ),
      );
}
