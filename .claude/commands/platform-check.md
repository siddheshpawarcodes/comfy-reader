---
description: Verify a behavior is correct on BOTH Android and iOS (Flutter-first — no native app to mirror)
argument-hint: [behavior, screen, or file:line to verify]
allowed-tools: Read, Grep, Glob, Bash, Task
---

Verify cross-platform behavior for: **$ARGUMENTS**

Delegate to the `platform-parity-investigator` agent. Comfy Reader is **Flutter-first** — there is no
native app to match; the goal is "is each platform's branch correct given its constraints?" Require
it to:
- Read BOTH the Android and iOS branches (Dart `Platform.isAndroid/isIOS`, the
  `MethodChannel('comfy_reader/tts')` handlers in `android .../MainActivity.kt`, the manifest, and
  iOS `Info.plist`) — the whole method, not snippets.
- Enumerate the conditions each platform distinguishes for the split points: device scan / storage
  permission (`MANAGE_EXTERNAL_STORAGE`), document import (iOS copy-into-Documents), TTS engine
  (Google vs system), voice install (`TtsPlatform`), OCR (ML Kit / iOS 15.5+).
- Return a platform matrix with CORRECT / BROKEN / MISSING / UNSAFE-ASSUMPTION per condition, with
  both excerpts and the concrete consequence.
- Never assert "works on both platforms" without citing the lines read on each side; if a native
  handler can't be inspected, downgrade the claim to "unverified on <platform>."

Use `.claude/templates/platform-matrix.md` for the output shape.
