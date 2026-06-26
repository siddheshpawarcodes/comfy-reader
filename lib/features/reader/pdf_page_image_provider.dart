import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../services/pdf_service.dart';

/// Cache key for a rendered PDF page. Equality lets Flutter's global
/// [imageCache] de-dupe concurrent requests and reuse decoded frames.
@immutable
class PdfPageKey {
  const PdfPageKey(this.bookId, this.pageIndex, this.targetWidth);

  final String bookId;
  final int pageIndex;
  final int targetWidth;

  @override
  bool operator ==(Object other) =>
      other is PdfPageKey &&
      other.bookId == bookId &&
      other.pageIndex == pageIndex &&
      other.targetWidth == targetWidth;

  @override
  int get hashCode => Object.hash(bookId, pageIndex, targetWidth);
}

/// Lazily renders a single PDF page to an image, on demand. This is the
/// lazy-render boundary for the flipbook: it builds N cheap provider objects,
/// but only ±a few pages are ever decoded; the global [imageCache] (bounded in
/// main.dart) evicts far pages.
class PdfPageImageProvider extends ImageProvider<PdfPageKey> {
  const PdfPageImageProvider({
    required this.bookId,
    required this.filePath,
    required this.pageIndex,
    required this.targetWidth,
    this.pdf = const PdfService(),
  });

  final String bookId;
  final String filePath;
  final int pageIndex;
  final int targetWidth;
  final PdfService pdf;

  @override
  Future<PdfPageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PdfPageKey>(
      PdfPageKey(bookId, pageIndex, targetWidth),
    );
  }

  @override
  ImageStreamCompleter loadImage(PdfPageKey key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(
      _load(key, decode),
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<String>('Book', bookId),
        DiagnosticsProperty<int>('Page', pageIndex),
      ],
    );
  }

  Future<ImageInfo> _load(PdfPageKey key, ImageDecoderCallback decode) async {
    final bytes =
        await pdf.renderPage(filePath, pageIndex, targetWidth: targetWidth.toDouble());
    if (bytes == null) {
      throw StateError('Failed to render page $pageIndex of $filePath');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final codec = await decode(buffer);
    final frame = await codec.getNextFrame();
    return ImageInfo(image: frame.image);
  }
}
