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

## Logic layer — Phase 2b: Habits is live + 3 review data sets
Her rule (confirmed): **the Figma numbers are placeholder** — the design shows what a *filled* account
looks like, and the app must compute every value from the user's own data.

- `?demo=` review modes: `none` (a real launch, empty) · `small` (2 habits, 2 days — "just started") ·
  `1`/`full` (the design data set). Demo data always lives in a throw-away `MemoryHabitStore`.
- **Habits screen is store-driven**: tiles ← active habits with `iconKey`/accent mapping shared with Home
  (`screens/home/widgets/habit_card_style.dart`), meta line, streak chip, done state, "NextUp" badge ←
  first unfinished habit of today · snapshot card ← `todaySummaryProvider` (n of m, %, progress bar, the
  Mon→Sun strip with "(Today)" on the real weekday) · chips ← `All / Today / Paused` with live counts ·
  toggle writes through the controller · tile tap → details · empty state + empty-filter state.
- Meta lines are ellipsised inside the tile so a long habit name or long unit never runs under the toggle.
- `figmaText` now takes `maxLines` + `overflow`.

**Verified** (local + the deployed site, 0 page errors): empty / small / full in light and dark; toggle
changes the numbers immediately; `flutter analyze` 0 errors; 19/19 tests green.

### Review links (deployed)
```
https://shahd1982001.github.io/daily-spark/?s=home              Home, empty (new user)
https://shahd1982001.github.io/daily-spark/?s=habits            Habits, empty
https://shahd1982001.github.io/daily-spark/?s=habits&demo=small Habits, 2 habits
https://shahd1982001.github.io/daily-spark/?s=home&demo=1       Home, filled (design parity)
https://shahd1982001.github.io/daily-spark/?s=habits&demo=1     Habits, filled
(+ &theme=dark on any of them)
```

## Logic layer — Phase 2c: Progress is live
- New `state/progress_providers.dart`: `progressRangeProvider` (week / month / all) ·
  `rangeStatsProvider` (scheduled vs completed + per-habit ratios for the window) ·
  `weeklyRhythmProvider` (7 days) · `bestHabitStreakProvider` · `personalBestProvider`.
- Hero card: ring %, "N of M habits hit", all computed. Weekly Rhythm bars: height + pigment +
  star + NOW chip + "Top Day" + footer ribbon all derived from the data. Streak card: real streak and
  personal best. Consistency list: one row per habit with `completed of scheduled days` and the bar width.
  The This Week / This Month / All Time segmented control now really switches the window.
- Empty state for a user with no habits ("Your progress starts here").

**Answer to her question "will it look like Figma when filled?"** — structure, spacing, colours and
components match (same tokens); the numbers differ because they now come from real data. Example with
the same seed: our 5 habits × 7 days = 35 slots, 31 completed → **89% / 31 of 35**, while the Figma mock
shows 78% / 28 of 35 and "Top Day: Thursday". Same layout, different (truthful) numbers.
Side-by-side: `review/progress_figma_vs_app.png`.

## Logic layer — Phase 2d: Profile is live
- New providers: `totalCompletionsProvider` (every check-in ever) · `consistencyScoreProvider`
  (14-day completion rate) · `profileLevelProvider` (1 level per 30 check-ins → Sprout/B builder/…) ·
  `userNameProvider` (null until the user has an account; `?demo=` shows "Shahd").
- Profile reads: streak tile ← `bestHabitStreakProvider`, completed ← lifetime log, active habits ←
  store, level card ← level + score + "next" hint, identity card + "X's Journey" title ← user name.
- **No fake identity for a new user**: no name → "Your Journey", the spark logo instead of a photo,
  Level 1 Sprout, 0 % consistency and a bio that invites the first ritual.
- Theme toggle in Preferences still flips the whole app.

Verified empty + filled, light + dark, 0 page errors; analyze 0 errors; 19/19 tests.

## Logic layer — Phase 2e: Habit Details is live
- Data: `HabitsSnapshot.amounts` (habit → day → amount) stores *partial* progress, so amount habits
  (20 pages, 1.5 L, 30 min) can sit between 0 and the target. `log` stays the single source of truth for
  "done": reaching the target adds the day, dropping below removes it. Old snapshots stay readable
  (missing field → `{}`).
- Controller: `setAmount(id, n)` (clamped 0…target) · `stepAmount(id, ±n)`; `toggle` now writes the full
  target instead of a bare boolean, so the two paths never disagree.
- New `state/details_providers.dart`: `selectedHabitIdProvider` (set by the card she tapped) ·
  `detailsHabitProvider` (falls back to today's first habit, null when there are no habits) ·
  `habitDetailProvider` → streak, best run **and the month it was set**, lifetime consistency, 7-day
  gauge, month calendar (per-day completed / today / missed / before-start / future), 30-day trend,
  today amount, target, and the quick-step sizes (5/10 for a 20-page target, scaled for bigger ones).
- Screen: header/edit/avatar stay, title + chips + hero + today card + month calendar + stats mosaic +
  habit loop + editorial card + actions are all data-driven. `spark` insight line, "+5 / +10" labels,
  "Archive to Vault", delete confirmation → all real. Archive/delete actually hit the store.
- Month calendar height adapts to 5- or 6-week months (no legend spill).
- Empty state: "No ritual to open yet" + Create a habit, no fake "Mindful Reading" demo.
- Dark: completed cells use the bright ember token (Figma dark), editorial cover fade follows the theme.

Verified light + dark, empty + 2-habit + full seed, partial amounts, stepper clicks (20 → 15 → 10 → 5 →
0 → back up), archive, delete dialog, tile → details selection; 0 page errors, analyze 0 errors, 28/28 tests.

Fixes picked up on the way: `habitMetaLine` was printing a literal `\u00b7` (now a real `·`), the
Habits tile meta line overlapped the toggle when the streak badge was shown, and the streak token in
that line is now the compact `19d`.

## Next (needs her decision)
1. **Add Habit** (`?s=add`) — last screen of the build order, then auth/onboarding, then backend.
2. **Backend** — must stay last.
3. **i18n / RTL Arabic** — after logic.

## Deploy recipe
```
export PATH=/home/user/.cache/sdk/flutter/bin:$PATH PUB_CACHE=/home/user/.cache/pub
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run -O2 --base-href /daily-spark/
python3 /home/user/.cache/patch_index.py build/web        # service-worker killer + cache bust
# copy build/web + web_extra (gallery + screens) → .cache/pages → force push gh-pages
```

---

## 🧩 Phase 2e+ — Add / Edit Habit (logic) — 2026-11-12

One draft drives both flows (`habitDraftProvider` + `editingHabitIdProvider`): the Add form is a
**blank** sheet for a new user, and Edit reuses the exact same sheet prefilled — `Save Changes`
edits in place (id, logs, streak untouched), `Ignite This Habit` creates `h_<micros>` at sortOrder+1.

- **Symbol ↔ unit contract:** book=pages · water=ml · meditation/walk/moon=mins · flame=times.
  Switching the symbol re-bases unit, presets and step (pages 10–50 · ml 250–1500 · mins 5–30 · times 1–5),
  keeping the current amount when the unit holds.
- **Rhythm segments** (Every Day / Weekdays / Weekends / Custom) write the real weekday set; tapping any
  day drops to Custom — mirroring the 2b calendar semantics.
- **Reminder** toggle arms an 08:30 default, the Scheduled Moment pill opens the time picker; off clears
  the time (repository `copyWith(clearReminder: true)`).
- **Category** (Morning/Afternoon/Evening/Night) derived from the chosen hour; `DRAFT SAVED` pill while
  dirty, `EDITING` in edit mode; CTA switches label accordingly.
- Wired into the preview shell: `?s=add`, `?s=add&demo=1&id=h_read` (edit), `onEdit/onEditRitual`
  from Details and the habits `onCreateHabit` empty-state all land in the sheet.
- Chip rows are scrollable with true min-widths (no clipped `1500 ml`), reminder rows are
  overflow-proof at 390px.
- Tests: +6 core (draft defaults, symbol rebase, rhythm, ignite fields, edit-in-place, reminder clear)
  and a new `add_habit_widget_test.dart` (CTA inert until named, ignite writes the store, chips write
  the draft, edit prefills + saves) → **38/38 green**. Verified live: title typing, symbol→unit switch,
  preset tap, reminder toggle + 8:30 pill, ignite lands the habit in the Habits list with its toast,
  edit prefills Read 20 Pages (light + dark).

---

## 🔗 Phase 2e++ — One connected app (sync + live settings) — 2026-11-15

Everything is now wired to the same Riverpod store, so **any change updates every
screen**: igniting a habit from Home's "+ New Ritual" bumps Home's routine count and
daily pulse immediately (5→6 total, 3 of 5→3 of 6), toggling a circle updates the
summary live, and edits propagate to Home/Progress/Profile.

- **Navigation spine**: `_go` keeps a history of the tab screens; `onBack` from
  Details and `onClose/onDiscard` from the Add sheet return to where they were
  opened from (Home → Details → back lands on Home, not Habits). Edit-saves return
  to their origin; a fresh ignite lands on the Habits list.
- **Profile settings are live** (`state/settings_providers.dart`, SharedPreferences):
  - *Daily Reminders* / *Sound & Haptic* toggles persist across reloads.
  - *Appearance* flips the theme live and persists it (`?theme=dark` still forces
    the start value for screenshots).
  - *Personal Details* opens a real sheet (display name + ritual motto) — the name
    drives Home's greeting ("Good evening, Noor") and the Profile identity card;
    the motto becomes the profile bio. Nothing is hardcoded: a nameless user sees
    just "Good evening".
  - *Ritual Guide* opens a real 3-step sheet; *About* a real dialog; *Share* copies
    the app link; the gear scrolls to the settings section; stat tiles open Progress.
- **Honest status**: Spark Cloud Sync shows **Local** ("Stored on this device") —
  it flips to Active when the backend arrives. Language says Arabic arrives with the
  i18n update. Guest mode enters the app (Home) instead of dead-ending.
- Fixed a real bug found in testing: shell-level handlers opened modal sheets with
  the State context above `MaterialApp` (no Navigator) — now via `navigatorKey`.
- Tests: +4 settings/profile-info core tests → **42/42 green**. Verified in-browser:
  add→Home sync, toggle→summary sync, back-spine, name→greeting, dark flip +
  persistence, guide/about/share, 0 page errors.

---

## 🔐 Phase 3 — Auth: login, sign up, guest — 2026-11-15

Local-first accounts complete the loop (the cloud backend swaps in later):
`state/auth_providers.dart` keeps one account per device in SharedPreferences —
name, email, password — plus the session (`none / guest / account`).

- **Sign up** validates inline (name ≥2, real email, password ≥6, passwords
  match) with error text under the exact field; success stores the account and
  the name flows straight into the greeting ("Good evening, Noor") and profile.
- **Log in** checks the stored account: "No account on this device yet" /
  "That account is not on this device" / "Incorrect password" appear under the
  right field. Success restores the name and the session.
- **Continue as Guest** (welcome + login + sign up) enters the app nameless —
  "Good evening" with the empty state, everything else fully functional.
- **Session** persists: a returning user's splash skips straight to Home;
  **Log Out** clears the session and the account name and returns to Welcome.
- **Forgot password** is honest: recovery arrives with Spark Cloud accounts ☁️.
- The auth fields lost their fake prefilled credentials (`sarah.miller@…` /
  `SuperSecret123`) — they open blank with hints, per the no-fake-data rule.
- Tests: +4 auth core tests (validation, sign-up/sign-in round trip, guest
  session persistence) → **46/46 green**. Verified in-browser end-to-end:
  sign up → greeting with name → log out → wrong password error → log in →
  name back → reload keeps the session → guest enters nameless, 0 page errors.

## Localization — Arabic coverage checkpoint (in progress)
- Expanded Arabic catalog and converted dynamic UI phrases (including dates, units, streaks and profile progress); retained user-written names, titles and notes verbatim.
- Added localization tests for catalog key parity, template placeholders, live language changes and preserving user text. Current suite: 49 tests passing.
- Arabic review is ongoing: visual and interaction checks are not yet exhaustive, and FR/ES/RU/ZH catalogs have not yet been implemented. No full-coverage claim yet.
- Gallery is copied into every Pages build. Backend remains deferred.
