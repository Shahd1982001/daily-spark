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

## Dark polish round 3 (her verdict)
She reviewed all 13 dark screens and confirmed they're right. Verdicts on the 3 open deltas:
- **Progress header** — keep the app version (logo + wordmark + bell + avatar). No change.
- **Ember glow** on Home/Details — keep it subtle. No change.
- **Add Habit header** — match the Figma dark frame. Done, dark only:
  header plate `#121413@0.90` with a `#282C2A@0.60` hairline, cancel button and avatar get the
  `#282C2A` ring, avatar flips to a surface disc + ember glyph, and `DRAFT SAVED` is now the muted
  ochre pill (`chipGold` fill, new `goldBorder #523A25` ring, `onEmberSoft #FFB596` text) instead of
  bright gold. Also fixed the details-screen ember badge in dark to `chipEmber` + `ember@30%` ring.

**Note on that Figma frame:** the wide "field" in `163:4304` is not a search input — the brand-logo
image node (light frame: 32×32) was accidentally stretched to 261×32 and its fill covers the art, which
pushes the "New Habit" heading off the bar. So the frame's own header is broken; the app keeps
X + logo + title + avatar (the light-frame intent) with the dark tokens above.

Light theme untouched and re-verified: add 0.37 mean-abs / 0.00 % of pixels > 40 vs the approved shots,
details 0.08 / 0.00 %.

## Brand logo swap (her asset)
She supplied a new spark logo (`uploads/IMG_9594.png`, 1024×1024 RGBA, transparent bg) and asked for it in
**both themes**. Applied everywhere the mark appears:
- `assets/brand/spark_logo.png` — 1024 master (cropped to the artwork, square-padded, alpha kept).
- `assets/brand/spark_mark.png` — 512, used by splash (`SparkAppIcon`, 72px on the white tile),
  login and welcome badges.
- `assets/brand/home_logo.png` — regenerated header tile: white squircle + logo, used by the shared
  `AppTopBar` and the Add-habit header (32px).
- `SparkLogo` widget now paints `spark_logo.png` instead of the old `CustomPainter` glyph (painter removed).
- `web/favicon.png` (32) + `web/icons/Icon-192/512` + `Icon-maskable-192/512` regenerated on the cream plate.
- Gallery thumbnails regenerated for all 13 screens in light **and** dark (`web_extra/screens*`, 390×844).

Note: the uploaded file has no red outline in its pixels — its edges are an orange→transparent ramp
(the red ring is an artefact of some viewers). If a hard ember ring is wanted on the logo it has to be drawn.
Verified live: splash light/dark, home dark header, gallery — 0 page errors; analyze 0 errors.

## Logo: white plate removed (her follow-up)
She asked for the logo to sit directly on the background in both themes ("الخلفية البيضاء متع اللوقو
حولها خلي لوقو بس"). Done:
- Splash `SparkAppIcon`: the two white plates + the 112 white tile (and its borders/shadows) are gone —
  the mark is drawn at full size over a soft ember halo only.
- Shared `AppTopBar` + Add-habit header: `home_logo.png` (white squircle) replaced by the bare
  `spark_logo.png` at 30 px. The white tile asset is now unused in-app.
- Brand pills (login `Daily Spark`, welcome badge) keep their own surfaces — they follow `p.panel` /
  `p.surface`, so they are dark in dark mode, never white.
- Favicon + PWA icons keep the cream plate on purpose (a transparent tab/OS icon has no contrast).
- All 26 gallery thumbnails regenerated again.

## Logic layer — Phase 1: core (done)
Riverpod + local-first storage, no UI changes yet. 1021 lines across 8 files, **19 unit tests green**.

**Layout**
```
lib/data/models/day.dart          calendar-day helpers (dayKey / parseDayKey) — dates stored as yyyy-MM-dd
lib/data/models/habit.dart        Habit: id, title, note, iconKey, accent, rhythm(+days),
                                  target, reminder, category, detailTag, sortOrder, createdAt, archivedAt
lib/data/repositories/…           HabitsSnapshot (habits + completion log) ⇄ JSON, versioned (schemaVersion 1)
lib/data/local/habit_store.dart   HabitStore interface · PrefsHabitStore (shared_preferences)
                                  · MemoryHabitStore (tests)
lib/data/services/streaks.dart    streakFor() / completionPercent() — scheduled days only, today never breaks
lib/data/seed/seed_data.dart      first-run content = the approved Figma data set (12d/8d/5d/19d/7d)
lib/state/habit_providers.dart    habitsProvider (AsyncNotifier) + todayHabits / todaySummary / habitStreak
```
**Behaviour**
- First launch seeds 5 habits + a 40-day log, then persists; later launches read the store (no re-seed).
- `toggle(id)` writes immediately; `addHabit / updateHabit / archiveHabit / deleteHabit` keep the log consistent.
- Storage key: `daily_spark.snapshot.v1` (web: `localStorage['flutter.daily_spark.snapshot.v1']`).
  To wipe: clear that key → next load re-seeds.
- App bootstrap watches `habitsProvider` once at startup so screens open with data ready.

**Verification**
- `flutter analyze` → 0 errors · `flutter test` → 19/19 pass.
- Web build loads with 0 page errors; localStorage holds the 5 habits, 5 logs, meditation = 12 days.
- UI screenshots unchanged vs the approved design.

**Next — Phase 2:** wire Home + Habits to the store (list from `todayHabitsProvider`, check-off taps,
Daily Pulse / "3 of 5" from `todaySummaryProvider`, streak chips from `habitStreakProvider`).

## Logic layer — Phase 2a: Home is live + real empty start
Her call: **a real install starts empty**; the design data set stays only for review.

- `?demo=1` opens the seeded design data in a throw-away `MemoryHabitStore` (never touches real data).
  A normal launch starts with zero habits and persists everything the user adds.
- **Home is now store-driven** (ConsumerStatefulWidget):
  routine list ← `todayHabitsProvider` · check circle ← `controller.toggle(id)` (instant + persisted) ·
  ring % / "3 of 5" ← `todaySummaryProvider` · "N Days / Record" ← `routineStreakProvider` /
  `routineRecordProvider` · the Su→Sa strip ← `lastSevenDaysProvider` (past days show ✓ only when the
  whole day was completed, today stays ember) · filter pills are generated from the habit categories
  with live counts · streak chip ← `habitStreakProvider` · card tap → Habit Details ·
  greeting date/greeting word/season + status line are computed from the clock.
- **New empty state** (not in Figma, designed to match the system): icon disc + "Your first spark is
  waiting" + one line of copy + ember CTA "Create your first ritual →" + "Takes about 40 seconds".
  CTA opens Add Habit. Empty screens hide the pulse card, filters and clarity note.
- Secondary empty state for an empty filter (`Nothing scheduled in this part of the day.`).

**Verified on the web build** (Playwright, 0 page errors throughout):
empty home → CTA tap lands on Add Habit · demo home tap on the workout circle → `3 of 5 → 4 of 5`,
ring `60% → 80%`, streak chip `19d → 20d` · `Morning (2)` filter shows exactly the 2 morning habits ·
light + dark both correct · `flutter analyze` 0 errors · 19/19 tests still green.

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
