// RenderFlex / overflow regression tests.
//
// These pump real screens at large system font scales (TextScaler) on small
// devices and assert that nothing overflows. A RenderFlex overflow reports a
// FlutterError during paint, which `tester.takeException()` surfaces — so
// `expect(tester.takeException(), isNull)` fails iff the layout overflowed.

import 'package:comfy_reader/core/theme/app_theme.dart';
import 'package:comfy_reader/features/home/continue_reading_tab.dart';
import 'package:comfy_reader/features/home/widgets/library_grid.dart';
import 'package:comfy_reader/models/book_model.dart';
import 'package:comfy_reader/providers/library_provider.dart';
import 'package:comfy_reader/shared/widgets/max_text_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// A book with a non-null [coverImagePath] that doesn't exist on disk. This
/// makes [BookCover] render its shimmer placeholder AND skip
/// `LibraryProvider.ensureCover`, so these layout tests need no cover pipeline.
BookModel _book({
  required String title,
  int totalPages = 350,
  int lastReadPage = 0,
  bool opened = false,
}) {
  return BookModel(
    id: '$title-$totalPages-$lastReadPage',
    title: title,
    filePath: '/library/$title.pdf',
    totalPages: totalPages,
    fileSize: 5 * 1024 * 1024,
    addedAt: DateTime(2024, 1, 1),
    coverImagePath: '/covers/$title.png',
    lastReadPage: lastReadPage,
    lastOpened: opened ? DateTime(2024, 6, 1) : null,
  );
}

/// Pumps [child] inside the app's real ancestor stack (theme + ScreenUtil) at a
/// fixed logical [size] and system [textScale], one frame only (covers shimmer
/// forever, so never pumpAndSettle).
Future<void> _pumpAtScale(
  WidgetTester tester,
  Widget child, {
  required double textScale,
  required Size size,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        // Outer: the logical size ScreenUtilInit reads for .w/.h/.r scaling.
        data: MediaQueryData(size: size, devicePixelRatio: 1.0),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => Builder(
            builder: (context) => MediaQuery(
              // Inner: apply the system text scale + skip entrance animations
              // (LibraryGrid honors disableAnimations).
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScale),
                disableAnimations: true,
              ),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
  // First frame builds + paints (overflow, if any, is reported here). The
  // second pump fires flutter_animate's zero-delay restart timers (cover
  // shimmer) so they aren't flagged as "pending" at teardown; the repeating
  // shimmer itself is ticker-driven and is disposed cleanly with the tree.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 32));
}

/// Phone-ish portrait sizes, smallest first (smaller width = tighter grid
/// cells = the worst case for the cover-plus-caption stack).
const _sizes = <Size>[
  Size(320, 568), // small / older phones
  Size(360, 690), // common Android
  Size(412, 915), // large Android
];

/// 1.0 = default, 1.3 ≈ Android "Largest", 2.0 / 3.0 = accessibility sizes.
const _scales = <double>[1.0, 1.3, 2.0, 3.0];

/// A LibraryProvider whose in-progress list is injected (no storage needed).
class _FakeLibrary extends LibraryProvider {
  _FakeLibrary(this._items);
  final List<BookModel> _items;
  @override
  List<BookModel> get inProgress => _items;
}

void main() {
  group('LibraryGrid does not overflow', () {
    final books = List.generate(
      8,
      (i) => _book(
        title: 'A Wonderfully Long Book Title That Easily Wraps To Two Lines $i',
        totalPages: 300 + i,
        lastReadPage: i.isEven ? 120 : 0, // mix started (progress bar) + fresh
        opened: i.isEven,
      ),
    );

    for (final size in _sizes) {
      for (final scale in _scales) {
        testWidgets('${size.width.toInt()}w @ ${scale}x', (tester) async {
          await _pumpAtScale(
            tester,
            CustomScrollView(slivers: [LibraryGrid(books: books)]),
            textScale: scale,
            size: size,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: 'grid overflowed at ${size.width.toInt()}w / ${scale}x',
          );
        });
      }
    }
  });

  group('Continue Reading does not overflow', () {
    final fake = _FakeLibrary([
      _book(
        title: 'An Unusually Long Continue-Reading Title For Wrapping',
        totalPages: 67890,
        lastReadPage: 12344,
        opened: true,
      ),
      _book(title: 'Short One', totalPages: 12, lastReadPage: 3, opened: true),
    ]);

    Widget tab() => ChangeNotifierProvider<LibraryProvider>.value(
          value: fake,
          child: const ContinueReadingTab(),
        );

    // At the realistic clamp ceiling (1.3x), the whole screen must stay clean.
    for (final size in _sizes) {
      testWidgets('${size.width.toInt()}w @ 1.3x', (tester) async {
        await _pumpAtScale(tester, tab(), textScale: 1.3, size: size);
        expect(tester.takeException(), isNull);
      });
    }

    // The progress meta row ("Page X of Y" + "%") must survive extreme scales.
    testWidgets('meta row @ 2.0x on narrow screen', (tester) async {
      await _pumpAtScale(
        tester,
        tab(),
        textScale: 2.0,
        size: const Size(320, 700),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('MaxTextScale', () {
    testWidgets('caps an accessibility text scale to the max', (tester) async {
      late TextScaler seen;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(3.0)),
            child: MaxTextScale(
              max: 1.3,
              child: Builder(
                builder: (context) {
                  seen = MediaQuery.textScalerOf(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      expect(seen.scale(10), closeTo(13.0, 0.001)); // 10pt * 1.3, not * 3.0
    });

    testWidgets('passes a modest scale through unchanged', (tester) async {
      late TextScaler seen;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.15)),
            child: MaxTextScale(
              child: Builder(
                builder: (context) {
                  seen = MediaQuery.textScalerOf(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      expect(seen.scale(10), closeTo(11.5, 0.001));
    });
  });
}
