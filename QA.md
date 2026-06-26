# Comfy Reader — Manual QA Checklist

End-to-end checklist to run on **at least one Android** and **one iOS** target
before shipping. Mark P (pass) / F (fail) / NA per platform; file failures and
re-test. Last run: _not yet run for release_.

> Legend: **A** = Android, **i** = iOS. Items marked _(A only)_ don't apply to
> the iOS sandbox.

## Launch & shell
- [ ] Cold launch: native splash → animated splash → Home, **no white flash** (A / i)
- [ ] Animated splash motion is smooth; wordmark + tagline in correct fonts (A / i)
- [ ] Reduced-motion (OS setting on): splash shortens, grid doesn't stagger (A / i)
- [ ] App name shows as **"Comfy Reader"** on launcher + app switcher (A / i)

## Library
- [ ] **+ Add PDF** opens the system picker; chosen PDF imports with a cover and persists across restart (A / i)
- [ ] Import failure / cancel: cancel is a no-op; a bad file shows "Couldn't import that file." (A / i)
- [ ] Device scan — grant path: rationale dialog → OS prompt → PDFs from Downloads/Documents/Books appear _(A only)_
- [ ] Device scan — deny path: declining keeps the app usable via +; gentle note shown _(A only)_
- [ ] Device scan — permanently denied: "Open settings" dialog appears and opens app settings _(A only)_
- [ ] iOS: **no** device-scan attempted; only imported books show _(i only)_
- [ ] Pull-to-refresh re-scans (A) / finds nothing gracefully (i)
- [ ] Covers fill in progressively with shimmer; reload instantly next launch; scrolling stays smooth during cover render (A / i)
- [ ] Grid ↔ list toggle switches smoothly; both open the reader (A / i)
- [ ] Search filters titles live; "No matches" state for empty result (A / i)
- [ ] Sort: Recent / Name / Date added each reorder correctly (A / i)
- [ ] Continue Reading rail shows started books with correct progress; tap resumes (A / i)
- [ ] Empty state on a fresh install; distinct copy for empty-library vs no-search-match (A / i)
- [ ] Long-press → context sheet: Remove deletes book + cover + file and updates the grid; Details shows correct metadata (A / i)
- [ ] Card press shows a subtle scale feedback; cover→reader **Hero** expands smoothly (A / i)

## Reader (the star)
- [ ] Opening hides system UI (immersive); warm full-screen; resumes at saved page (A / i)
- [ ] **Page-curl** swipe shows the 3D curl with shadow + gloss; fling / revert feel right (A / i)
- [ ] Tap zones: right→next, left→previous, center→toggle overlay (A / i)
- [ ] Page-turn **sound** + light **haptic** on each completed turn; both stop when toggled off in Settings (A / i)
- [ ] Overlay auto-hides after inactivity; all controls themed (A / i)
- [ ] Scrubber drags with a live thumbnail; release jumps to that page (A / i)
- [ ] Resume: kill mid-book, reopen → resumes at the saved page; Home progress reflects it (A / i)
- [ ] Bookmarks: toggle add/remove (persists across restart); sheet lists them; tap jumps (A / i)
- [ ] Tint: Day / Night / Sepia visibly change page warmth/darkness; night is low-blue (A / i)
- [ ] Brightness slider dims/brightens; resets after leaving the reader; screen stays awake while reading (A / i)
- [ ] **Error states:** a missing / corrupt / password-protected PDF shows the friendly "Can't open this book" screen with **Go back** (A / i)
- [ ] **Large PDF (500+ pages):** curl stays smooth (~60fps), memory bounded, page loads fast — `flutter run --profile` (A / i)

## Settings
- [ ] Theme System/Day/Night updates the app **instantly** (A / i)
- [ ] Sound switch + volume (volume dims when sound off); Haptics; Keep screen on — all affect the reader (A / i)
- [ ] Default page tint changes what new books open with (A / i)
- [ ] Rescan device for PDFs runs the discovery flow _(A only)_
- [ ] About: version shows; Open-source licenses opens (A / i)
- [ ] All settings persist across restart (A / i)

## Cross-cutting
- [ ] Day/Night contrast is comfortable; text legible at OS large-text (1.3×) without broken layouts (A / i)
- [ ] Screen-reader announces icon buttons (tooltips) and cards (as buttons) (A / i)
- [ ] iOS: "Open with Comfy Reader" from Files — _known gap: launches but doesn't import yet_ (i only)
