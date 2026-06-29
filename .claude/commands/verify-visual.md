---
description: Produce visual proof (PNG) of how a screen / tint / cover / chrome / page-curl renders, then read it back and report
argument-hint: [what to verify, e.g. "night tint on a light PDF page" or "library card long title"]
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task
---

Visually verify: **$ARGUMENTS**

Apply the `visual-verification` skill (run it in THIS conversation so the captured PNGs are shown to
the user — do not hand the rendering off to a sub-agent). Then:

1. **Scope it.** Decide from the skill's decision table whether this needs the **real app / device**
   (the page-curl mid-flip or a live rendered PDF page — PDFium + the curl's engine snapshots do NOT
   run in `flutter test`) or a **widget harness** (comfort tints, covers, reader chrome, library
   cards, empty/loading states, typography/layout). Write a one-line target checklist.
2. **Discover** the route and/or the widget under test. Delegate broad read-only sweeps to the
   `Explore` agent; for render internals use `rendering-investigator`, for screen/interaction
   behavior use `ui-investigator`.
3. **Render to PNG.**
   - Widget harness: build a throwaway test under `test/scratch/` from the skill template, pump the
     REAL widget into a `RepaintBoundary`. Apply the gotchas: `loadAppFonts()` (Fraunces/Lora/Inter —
     or text = tofu blocks), `ScreenUtilInit(375×812)`, async `toImage` with a roomy `physicalSize`.
     Run `flutter test test/scratch/...`.
   - Device path: `flutter run`, open a known PDF, navigate to the page/state, capture with
     `flutter screenshot --out=/tmp/vv_<x>.png` (or the simulator screenshot / an integration test).
4. **Inspect.** `Read` the full PNG; `sips`-crop and `Read` any small labels before judging text
   (rule out font-tofu before calling anything a bug). Render extra fixtures to prove variants
   (paper vs sepia vs night; day vs dark theme; grid vs list card).
5. **Report** in the skill's format: Objective / Path / Data-Fixture / Artifacts / Findings /
   Caveats / Root cause (only if real) / Recommended fix / Confidence. Then **delete** the scratch
   harness unless the user wants it kept.

Never end with "unable to verify" — if a path is blocked, take the next per the skill (and say
plainly when a PDF/curl proof needs a device).
