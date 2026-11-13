# Daily Spark — status

Design build complete: **13 / 13 screens** at pixel parity with the Figma file.

| # | Screen | Route | Local diff (mean / % > 40) |
|---|--------|-------|---------------------------|
| 1 | Splash | `?s=splash` | 1.83 |
| 2 | Onboarding 1 | `?s=onboarding&p=0` | — (auto-advance 6 s · swipe) |
| 3 | Onboarding 2 | `?s=onboarding&p=1` | — |
| 4 | Onboarding 3 | `?s=onboarding&p=2` | — |
| 5 | Welcome | `?s=welcome` | 6.74 |
| 6 | Login | `?s=login` | 3.62 / 3.34 % |
| 7 | Sign Up | `?s=signup` | 2.72 / 2.13 % |
| 8 | Home | `?s=home` | 4.17 / 3.47 % |
| 9 | Habits | `?s=habits` | 4.20 / 3.14 % |
| 10 | Habit Details | `?s=details` | 3.96 / 2.98 % |
| 11 | Add Habit | `?s=add` | 4.26 / 3.57 % |
| 12 | Progress | `?s=progress` | 7.51 / 4.41 % |
| 13 | Profile | `?s=profile` | 8.25 / 4.98 % |

Gallery (all screens, thumbnails): `https://shahd1982001.github.io/daily-spark/gallery.html`

## Architecture rules honoured
- Screens are **pure UI**: callbacks only, no state container, no network.
- Feature-first folders: `lib/screens/<feature>/` + `widgets/`.
- Shared kit: `lib/design_system/{theme,widgets}`.
- Preview shell: `lib/preview/preview_shell.dart` (`?s=` route switch, no visible UI).

## Dark mode — done (review pending)
- Token layer: `lib/design_system/theme/spark_palette.dart` (`SparkPalette.light` / `.darkPalette`,
  `SparkThemeScope`, `context.spark`, global `p`). Light values are byte-identical to the approved
  artboards (verified: home 1.7 / details 1.56 / progress 1.74 / profile 1.44 mean-abs vs approved shots).
- All 13 screens + the shared kit read tokens only — no hardcoded theme colours left.
- Frosted bottom nav + glass chip now read `p.surface` (they were stuck white under alpha).
- Toggle: **Profile → Preferences → Appearance & Theme** flips light ↔ dark live
  (row shows "Warm Light" / "Midnight" with sun / moon icon).
- `?theme=dark` also forces dark on any route for review/QA.
- Dark thumbnails + new gallery section: `gallery.html` → "الوضع الليلي".
- `review/dark_mode_all_screens.png` — all 13 screens in dark.
- Entry flow fixed: splash/onboarding timers start on the first painted frame, so opening the
  plain link shows Splash → Onboarding 1 → 2 → 3 (never jumps straight to Welcome).

### Dark match pass (Figma 163:* frames vs app)
Side-by-side evidence per screen: `review/dark_vs_app/*.png` (Figma dark | app `?theme=dark`).
All 13 screens reviewed and corrected:
- Weekly Rhythm keeps the artwork pigments (sage/gold/ember bars in cream wells) + cream "NOW" chip.
- Chips split into washes instead of solid accents: `chipNeutral #212423 · chipGreen #0E3522 · chipGold #2E2419 · chipEmber #2A1913`
  (light: `#F3F4F0 · #BCEED1 · #FFDDB2@30% · #FFDBCF@40%`).
- Raised wells/plates: `raised #242725` (Add-habit title field, settings tiles, stepper).
- Segmented control sits on canvas (`#121413`) with a hairline in dark.
- Ember icon plates + "Mindful Builder" badge use dark ember tints, not solid ember.
- Bottom nav frosted bar + glass chips read `p.surface` (no more white bar).
- Light theme re-verified byte-close to the approved shots (login 0.0 %, welcome 0.02, home 0.05, progress 0.25, habits 0.52 mean-abs).

## Link restore + deploy pipeline fix (2026-11-13)
Her link `shahd1982001.github.io` was showing GitHub's 404 and `gallery.html` had vanished.
Root cause: the CI workflow (`.github/workflows/deploy-web.yml`) publishes only `./build/web` on every
push to `main`, so the gallery (`web_extra/`) was dropped from gh-pages each time it ran.

Fixed:
- Workflow now copies `web_extra/` into `build/web`, runs `tool/patch_index.py` (sw + cache bust),
  writes `.nojekyll`, then publishes. `tool/patch_index.py` is committed so CI does not depend on `.cache`.
- `Shahd1982001.github.io` repo created → the bare host now serves an on-brand dark landing card that
  forwards to `daily-spark/gallery.html` (plus "All screens" / "Open the app" buttons). Her old root
  bookmark works again.
- gh-pages re-deployed manually first (instant restore), then CI run on `e53fa61` re-deployed successfully.

Verified (Playwright, 390×844, service workers blocked):
`https://shahd1982001.github.io/` → redirects → gallery, 0 page errors ·
`/daily-spark/` 200 · `/daily-spark/gallery.html` 200 · `main.dart.js` 200 · screens + screens_dark 200 ·
`?s=progress|profile|home|add&theme=dark` render the dark frames, 0 page errors.

## Local preview (port 20241)
- Killed leftovers: orphan `http.server 8082` (cwd `/tmp/site`, deleted) and a stale `cloudflared`
  that was holding `127.0.0.1:20241`.
- Rebuilt with `--base-href /` (the deployed build uses `/daily-spark/`, which 404s its assets at a root URL),
  copied `web_extra/`, patched index → served with
  `python3 -m http.server 20241 --bind 0.0.0.0 --directory build/web`.
- 0 page errors on gallery, `?s=progress|profile|home|details|add&theme=dark`.

## Next (needs her decision)
1. **Logic layer** — state management choice still open (Provider vs Riverpod).
2. **Backend** — must stay last.
3. **i18n / RTL Arabic** — after logic.

## Deploy recipe
```
export PATH=/home/user/.cache/sdk/flutter/bin:$PATH PUB_CACHE=/home/user/.cache/pub
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run -O2 --base-href /daily-spark/
python3 /home/user/.cache/patch_index.py build/web        # service-worker killer + cache bust
# copy build/web + web_extra (gallery + screens) → .cache/pages → force push gh-pages
```
