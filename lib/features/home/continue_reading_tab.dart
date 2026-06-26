import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/dimens.dart';
import '../../models/book_model.dart';
import '../../providers/library_provider.dart';
import '../../shared/widgets/pressable.dart';
import 'widgets/book_cover.dart';

/// The "Continue Reading" tab: every in-progress book, newest first. Tapping a
/// row resumes the reader at the saved page. Lives inside [HomeShell].
class ContinueReadingTab extends StatelessWidget {
  const ContinueReadingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final books = context.watch<LibraryProvider>().inProgress;

    return Scaffold(
      appBar: AppBar(title: const Text('Continue Reading')),
      body: books.isEmpty
          ? const _NothingInProgress()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                Dimens.space4,
                Dimens.space4,
                Dimens.space4,
                Dimens.space10,
              ),
              itemCount: books.length,
              separatorBuilder: (_, _) => Dimens.space3.verticalSpace,
              itemBuilder: (context, i) => _ProgressRow(book: books[i]),
            ),
    );
  }
}

/// A full-width resume card: cover, title, progress bar, and page/percent meta.
class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Pressable(
      onTap: () => context.push('/reader/${book.id}'),
      child: Container(
        padding: const EdgeInsets.all(Dimens.space3),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(Dimens.radiusCard),
          boxShadow: Dimens.softShadow,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64.w,
              child: BookCover(book: book),
            ),
            Dimens.space4.horizontalSpace,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  Dimens.space2.verticalSpace,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.radiusPill),
                    child: LinearProgressIndicator(
                      value: book.progress,
                      minHeight: 5,
                      backgroundColor: scheme.onSurface.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                    ),
                  ),
                  Dimens.space2.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Page ${book.lastReadPage + 1} of ${book.totalPages}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Dimens.space2.horizontalSpace,
                      Text(
                        '${(book.progress * 100).round()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Dimens.space2.horizontalSpace,
            Icon(
              Icons.play_circle_fill_rounded,
              color: scheme.primary,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when no book has been started yet.
class _NothingInProgress extends StatelessWidget {
  const _NothingInProgress();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Dimens.space6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: 56,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
            ),
            Dimens.space5.verticalSpace,
            Text('Nothing in progress', style: theme.textTheme.headlineSmall),
            Dimens.space2.verticalSpace,
            Text(
              'Open a book from your Library and it will show up here so you can '
              'pick up right where you left off.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
