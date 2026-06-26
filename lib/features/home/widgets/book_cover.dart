import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/dimens.dart';
import '../../../models/book_model.dart';
import '../../../providers/library_provider.dart';
import '../../../shared/widgets/shimmer_box.dart';

/// A book cover = the rendered first PDF page. Shows a shimmer while the cover
/// is generated (kicks off generation on first appearance — Step 3.5 pipeline).
class BookCover extends StatefulWidget {
  const BookCover({super.key, required this.book, this.borderRadius});

  final BookModel book;
  final BorderRadius? borderRadius;

  @override
  State<BookCover> createState() => _BookCoverState();
}

class _BookCoverState extends State<BookCover> {
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    _maybeRequestCover();
  }

  @override
  void didUpdateWidget(BookCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeRequestCover();
  }

  void _maybeRequestCover() {
    if (_requested || widget.book.coverImagePath != null) return;
    _requested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LibraryProvider>().ensureCover(widget.book);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(Dimens.radiusSmall);
    final cover = widget.book.coverImagePath;
    final scheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: Dimens.bookAspect,
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(color: scheme.surface),
          child: (cover != null && File(cover).existsSync())
              ? Image.file(
                  File(cover),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  frameBuilder: (context, child, frame, wasSync) {
                    if (wasSync || frame != null) return child;
                    return const ShimmerBox();
                  },
                  errorBuilder: (_, _, _) => _broken(scheme),
                )
              : const ShimmerBox(),
        ),
      ),
    );
  }

  Widget _broken(ColorScheme scheme) => Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: scheme.onSurface.withValues(alpha: 0.3),
          size: 40,
        ),
      );
}
