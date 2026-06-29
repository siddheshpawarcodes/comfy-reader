import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/dimens.dart';
import '../../../models/book_model.dart';
import '../../../shared/navigation.dart';
import '../../../shared/widgets/pressable.dart';
import 'book_context_sheet.dart';
import 'book_cover.dart';

/// A grid tile: cover (rendered first page) + PDF name + meta + progress.
/// Tapping the cover OR the name opens the reader; long-press opens actions.
class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book});

  final BookModel book;

  void _open(BuildContext context) => openReader(context, book.id);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Pressable(
      onTap: () => _open(context),
      onLongPress: () => BookContextSheet.show(context, book),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimens.radiusSmall),
              boxShadow: Dimens.softShadow,
            ),
            child: Hero(
              tag: 'cover_${book.id}',
              child: BookCover(book: book),
            ),
          ),
          Dimens.space2.verticalSpace,
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          2.verticalSpace,
          Text(
            _meta(book),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          if (book.hasStarted) ...[
            Dimens.space1.verticalSpace,
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimens.radiusPill),
              child: LinearProgressIndicator(
                value: book.progress,
                minHeight: 3,
                backgroundColor: scheme.onSurface.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _meta(BookModel book) {
    final pages = book.totalPages > 0 ? '${book.totalPages} pages' : '';
    if (book.hasStarted) {
      final pct = (book.progress * 100).round();
      return pages.isEmpty ? '$pct%' : '$pages • $pct%';
    }
    return pages;
  }
}
