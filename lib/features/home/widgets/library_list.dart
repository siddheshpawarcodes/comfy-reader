import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/dimens.dart';
import '../../../models/book_model.dart';
import '../../../shared/navigation.dart';
import '../../../shared/widgets/pressable.dart';
import 'book_context_sheet.dart';
import 'book_cover.dart';

/// Compact list rows: small cover + name + meta + progress.
class LibraryList extends StatelessWidget {
  const LibraryList({super.key, required this.books});

  final List<BookModel> books;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.space4,
        Dimens.space2,
        Dimens.space4,
        Dimens.space10,
      ),
      sliver: SliverList.separated(
        itemCount: books.length,
        separatorBuilder: (_, _) => Dimens.space3.verticalSpace,
        itemBuilder: (context, i) => _LibraryRow(book: books[i]),
      ),
    );
  }
}

class _LibraryRow extends StatelessWidget {
  const _LibraryRow({required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Pressable(
      onTap: () => openReader(context, book.id),
      onLongPress: () => BookContextSheet.show(context, book),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56.w,
            child: Hero(
              tag: 'cover_${book.id}',
              child: BookCover(book: book),
            ),
          ),
          Dimens.space3.horizontalSpace,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: Dimens.space1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  2.verticalSpace,
                  Text(
                    book.totalPages > 0 ? '${book.totalPages} pages' : '',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (book.hasStarted) ...[
                    Dimens.space2.verticalSpace,
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimens.radiusPill),
                            child: LinearProgressIndicator(
                              value: book.progress,
                              minHeight: 3,
                              backgroundColor:
                                  scheme.onSurface.withValues(alpha: 0.1),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(scheme.primary),
                            ),
                          ),
                        ),
                        Dimens.space2.horizontalSpace,
                        Text(
                          '${(book.progress * 100).round()}%',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
