import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/dimens.dart';
import '../../../models/book_model.dart';
import '../pdf_page_image_provider.dart';

/// Page slider with a live thumbnail preview ("Go To"). Jumps on release.
class PageScrubber extends StatefulWidget {
  const PageScrubber({
    super.key,
    required this.book,
    required this.currentPage,
    required this.onJump,
  });

  final BookModel book;
  final int currentPage;
  final void Function(int page) onJump;

  @override
  State<PageScrubber> createState() => _PageScrubberState();
}

class _PageScrubberState extends State<PageScrubber> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.book.totalPages;
    if (total <= 1) {
      return Text(context.l10n.pageOfTotal(1, total),
          style: theme.textTheme.bodySmall);
    }
    final value = (_dragValue ?? widget.currentPage.toDouble())
        .clamp(0.0, (total - 1).toDouble());
    final previewPage = value.round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_dragValue != null)
          _Thumbnail(book: widget.book, page: previewPage),
        Row(
          children: [
            Text('${previewPage + 1}', style: theme.textTheme.bodySmall),
            Expanded(
              child: Slider(
                min: 0,
                max: (total - 1).toDouble(),
                value: value,
                onChanged: (v) => setState(() => _dragValue = v),
                onChangeEnd: (v) {
                  setState(() => _dragValue = null);
                  widget.onJump(v.round());
                },
              ),
            ),
            Text('$total', style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.book, required this.page});

  final BookModel book;
  final int page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimens.space2),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(Dimens.radiusSmall),
          boxShadow: Dimens.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: Dimens.bookAspect,
          child: Image(
            image: PdfPageImageProvider(
              bookId: book.id,
              filePath: book.filePath,
              pageIndex: page,
              targetWidth: 150,
            ),
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
