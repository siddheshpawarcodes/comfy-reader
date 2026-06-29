# Platform Behavior Matrix — <behavior>

> Comfy Reader is **Flutter-first** — there is no native app to mirror. The goal is **each
> platform's branch correct given its constraints**, not "match native."

- Behavior:
- Android path: `lib/.../...dart:` (+ `android/.../MainActivity.kt:` if via `MethodChannel('comfy_reader/tts')`)
- iOS path: `lib/.../...dart:` (+ `ios/Runner/Info.plist` / `AppDelegate` if relevant)
- Code read: <methods / manifest / plist entries + line ranges actually read>

## Condition matrix
| condition | Android behavior | iOS behavior | verdict |
|---|---|---|---|
| storage permission granted |  |  | CORRECT / BROKEN / MISSING / UNSAFE-ASSUMPTION |
| storage permission denied |  |  |  |
| storage permanently denied |  |  |  |
| device scan supported |  | (sandboxed → picker only) |  |
| document import |  | (must copy into Documents) |  |
| TTS engine | (Google, configurable) | (system, fixed) |  |
| voice install | (intent) | (returns false → manual) |  |
| OCR availability | (Play Services) | (bundled, iOS 15.5+) |  |

## Defects
For each BROKEN / MISSING / UNSAFE-ASSUMPTION:
- **Condition:**
- **Android excerpt** (`path:line`):
- **iOS excerpt** (`path:line`):
- **Consequence:** (no books found / crash on iOS / silent TTS / permission loop / Play rejection risk)

## Verdict
- [ ] BOTH PLATFORMS CORRECT (branches cited on each side)
- [ ] DEFECTS (ranked by user impact, listed above)

## Suggested fix direction (described, not coded)
