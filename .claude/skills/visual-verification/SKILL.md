---
name: visual-verification
description: >
  Produce VISUAL PROOF (PNG screenshots) of a rendering / drawing / layout / reader issue, then read
  the image back and report findings — never stop at static analysis. TRIGGER when asked to verify,
  screenshot, "show me", or confirm how something LOOKS or RENDERS: the page-curl, a rendered PDF
  page, comfort tints (paper/sepia/night), book covers, reader chrome (overlay/scrubber/read-aloud
  bar), library cards, empty/loading states, or any "is this drawn correctly" question. Runs in the
  MAIN conversation so the captured images are shown to the user inline.
---

# Visual Verification (render-to-PNG proof)

You are a senior Flutter QA Automation + Platform Engineer for `comfy_reader`. Your job is to turn
"does it look right?" into a **PNG a human can see**, then read that PNG and report what is actually
drawn. **Do not end with "unable to verify."** Find a deterministic path and finish with evidence.

## Why a skill (run in main context), not a sub-agent
The entire value here is the **image being shown to the user**. A sub-agent's `Read` of a PNG stays
in the sub-agent's context — the user never sees it. So the render + capture + image-Read steps run
in the **main conversation**. Delegate only *read-only discovery* (router/nav/architecture sweeps)
to existing agents — `Explore`, `rendering-investigator`, `ui-investigator` — and keep the rendering
and image inspection here.

> **Fire-and-forget alternative:** the `visual-verification-engineer` agent runs this whole
> procedure autonomously and returns a findings report + the PNG **paths** (the caller then `Read`s
> them). Use it for out-of-band analysis; use this skill in the main conversation when the user
> should see the images inline.

---

## Decision: real app or widget harness?

| Question being verified | Start with |
|---|---|
| **The page-curl** mid-flip, or a **live rendered PDF page** | **Real app / device** (§A). PDFium is a native plugin and the curl captures engine snapshots — neither renders in pure `flutter test`. |
| Comfort **tints** (paper/sepia/night), **covers**, reader **chrome**, **library cards**, **empty/loading** states, typography, layout | **Widget harness** (§B) — fast, deterministic, no device |
| "Does it look right on a real device / specific OS"? | **Real app / device** (§A) on that device |

For this codebase the split is the opposite of a pure-painter app: the **signature visuals (curl +
PDF render) need a device**, while **static widgets and tints go to the harness**. Don't try to force
PDFium or the curl into a unit test — switch to §A.

---

## A. Real-app path (page-curl, live PDF render, on-device look)
1. **Understand the target** — screen + state (which book, which page, tint, theme, read-aloud on?).
   Comfy Reader has **no login/account** — reaching a screen is easy: `/splash` → `/home` →
   `/reader/:bookId`.
2. **Discover the route** — [app_router.dart](../../../lib/core/router/app_router.dart) (4 routes).
   Delegate broad sweeps to `Explore`.
3. **Launch** — `flutter devices`; boot an emulator/simulator; `flutter run` (or the PID-file loop
   from `README.md`). Watch for startup crashes / service init (`AppPaths`/Storage/Audio/TTS).
4. **Reach the screen** — import or open a known PDF (the picker, or a fixture copied into the books
   dir), navigate to the target page/state (resume, a flip, a tint).
5. **Capture** — `flutter screenshot --out=/tmp/vv_<topic>.png` against the running device, the
   emulator/simulator screenshot, or an integration test calling `binding.takeScreenshot`. Capture
   the entry, the target page, a flip mid-curl, and each tint as needed.
6. State plainly that this is a real-device capture, and which device/page/state it shows.

> On an x86 Android emulator the first cold frame (~55–100s) and first PDF render are JIT/software
> artifacts (`README.md`) — not bugs. Give it time or use a real device.

---

## B. Widget-test render harness (static widgets / tints / covers / chrome)
Build a throwaway widget test that pumps the **real** widget into a `RepaintBoundary` and writes a
PNG. **Never reimplement drawing** — construct valid inputs and render the production widget. For a
tint proof, wrap a known image/solid in the same `ColorFiltered` the reader uses.

### Three gotchas that will make you misdiagnose
1. **Fonts aren't loaded in `flutter test` → text renders as solid "tofu" blocks.** Load the real
   variable fonts (**Fraunces / Lora / Inter**, `assets/fonts/*-Variable.ttf`) before rendering
   whenever text matters. See `loadAppFonts()` below.
2. **`flutter_screenutil` must be initialized** — wrap in `ScreenUtilInit(designSize: Size(375, 812))`
   (matches `app.dart`) so `.sp/.w/.h` work.
3. **Capture must be async** — `await boundary.toImage(pixelRatio: 3.0)` inside
   `tester.runAsync(() async { ... })`. Enlarge `tester.view.physicalSize` so nothing clips.

### Harness template (adapt the fixture; keep the plumbing)
Put it under `test/scratch/` (untracked). Run `flutter test test/scratch/<name>_test.dart` → PNG to `/tmp`.

```dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
// ... import the real widget under test (the tint ColorFiltered, BookCover, a reader-chrome widget) ...

/// Loads the real variable fonts so text is legible (else: tofu). cwd == package root in flutter test.
Future<void> loadAppFonts() async {
  for (final e in const {
    'Fraunces': 'assets/fonts/Fraunces-Variable.ttf',
    'Lora': 'assets/fonts/Lora-Variable.ttf',
    'Inter': 'assets/fonts/Inter-Variable.ttf',
  }.entries) {
    final loader = FontLoader(e.key)
      ..addFont(Future.value(
          ByteData.view(Uint8List.fromList(File(e.value).readAsBytesSync()).buffer)));
    await loader.load();
  }
}

Widget harness({required GlobalKey boundaryKey, required Widget child, required Size size}) =>
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(size: size),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(width: size.width, height: size.height, child: child),
            ),
          ),
        ),
      ),
    );

Future<void> renderToPng(WidgetTester tester,
    {required Widget child, required Size size, required String outPath}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1200, 2600);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final key = GlobalKey();
  await tester.pumpWidget(harness(boundaryKey: key, child: child, size: size));
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    await File(outPath).writeAsBytes(bytes, flush: true);
    print('WROTE $outPath (${bytes.length} bytes)');
  });
  expect(File(outPath).existsSync(), isTrue);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts(); // gotcha #1
  });
  testWidgets('render', (tester) async {
    // 1) build the real widget (e.g. ColorFiltered(<night matrix>, child: <known image>))
    // 2) await renderToPng(tester, child: w, size: const Size(375, 600), outPath: '/tmp/vv_tint_night.png');
  });
}
```
Mark the file `// THROWAWAY — DELETE once verified. Do not commit.`

---

## C. Inspect the PNG (this is the proof)
1. **`Read` the full PNG** to see overall layout/placement/color/state.
2. **Zoom small labels** — crop at full resolution with macOS `sips`, then `Read` the crop:
   ```bash
   # sips -c <cropH> <cropW> --cropOffset <Y> <X> in.png --out crop.png   (offset = top-left)
   sips -c 220 1125 --cropOffset 530 0 /tmp/vv_x.png --out /tmp/crop.png
   ```
3. **Rule out font-tofu** before concluding a text bug (gotcha #1). Cross-check colors against
   `AppColors`/`ComfyColors` and the expected tint.
4. **Prove variants** by rendering more than one fixture: paper vs sepia vs night; day vs dark theme;
   grid vs list card; empty vs loaded (`ShimmerBox`).

---

## Throwaway discipline
- Harnesses go in `test/scratch/`, marked `// THROWAWAY — DELETE. Do not commit.`; they're untracked.
- **Delete them when done** (and re-create from this template if `test/scratch/` is cleaned up
  mid-task). Never let harness/fixture code leak into `lib/` or committed tests.

## Report format (always end here)
```
# Objective            — what visual claim was being verified
# Path                 — real-app/device (device + page/state) OR widget harness (which widget/fixture)
# Data / Fixture        — book / tint / theme / settings used
# Artifacts            — every PNG path (+ crops), with byte sizes
# Findings             — what is ACTUALLY drawn (per region/color/value), vs expected
# Caveats              — what couldn't be proven (live PDF/curl in a unit test; device font metrics)
# Root cause           — only if a real defect is confirmed (font-tofu is NOT a defect)
# Recommended fix      — precise, minimal, design-system-compliant (AppColors/AppTypography/Dimens)
# Confidence           — High / Medium / Low + why
```

## Hard rules
- Real widgets/render path only — never fake the drawing.
- Don't conclude "bug" on illegible text without ruling out font-tofu first.
- Be honest about the engine boundary: say plainly when a PDF/curl proof needs a device.
- Never stop at analysis when a render path exists. Produce the image.
