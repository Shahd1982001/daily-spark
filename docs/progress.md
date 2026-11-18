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

## Habit title translation checkpoint
- User approved sending task titles over the internet for automatic translation. Habit titles are translated for display across Home, Habits, Progress, Details and related confirmations; original locally stored titles stay unchanged for editing.
- Uses Google's translation endpoint directly from the client, with in-memory deduplication/cache and original-text fallback when offline or when the provider fails. It is an external service, subject to availability, rate limits and machine-translation errors; no new account backend.
- Arabic and English currently selectable; the target-language mechanism also supports FR/ES/RU/ZH as their catalogs become available. Other written personal fields are not sent.

## MVP readiness — data-protection checkpoint
- The user chose an Arabic/English MVP, guest choice with eventual account option, and stepwise review. Detailed roadmap: `docs/mvp_plan.md`.
- Fixed the delete-habit bug: unrelated partial progress is preserved in memory and after reload; test first reproduced the bug (7 became 0) then passed with the fix.
- Full suite 53 tests passed; Flutter analyze has no fatal warnings/errors (pre-existing lint warnings remain). Backend, real accounts, profile photo upload and actual notifications are not implemented yet.

## MVP point 2 — habits, sorting and restoration (checkpoint)
- Habits sort sheet offers original, newest, oldest and alphabetical order; choice persists locally. Sorting changes only the list order, not stored habit data.
- Archived habits can be restored from the Paused tab; archived habits cannot be checked off. The archived period is saved so paused dates are not treated as missed after restoration. Same-day archive/restore keeps that day active. Old stored records with no pauseHistory still load.
- Fixed calendar scheduling prior to creation and corrected monthly completion counting. Added tests for archive/restore, storage reload, paused streak days and pre-creation percentages. Full suite: 58 passing.
- Existing schedules and targets are not versioned when edited: historical statistics can be recalculated using the newest settings. That issue and comprehensive time-zone/day-rollover verification still need review; point 2 should not yet be described as completely audited.

## MVP point 2 — history, unit edits and civil-day checkpoint
- From this version, schedule, days, target and unit changes take effect on the edit day; earlier dates use the earlier saved plan. Added versioned planHistory with backward-compatible reading of prior local snapshots. Older edits made before this change cannot be reconstructed retroactively.
- A unit change prompts for confirmation and resets only today's logged progress, preserving previous days and their units. Same-unit target changes preserve today's recorded amount and recalculate whether today's target is complete. Mixed units are not added into the current-unit total.
- Civil-date math no longer assumes every day has 24 hours; day-dependent providers refresh when the local date changes, on resume and via periodic checks. This follows the device's local date; multi-device timezone reconciliation will require backend decisions.
- Removed silent 400-day cap from streaks and All Time. Added tests for historical settings, reset/cancel, previous-day persistence, same-unit edits, rollover, 450-day streaks and DST. Flutter suite: 66 passing; calendar cases also run successfully in America/New_York and Pacific/Auckland. Manual Arabic confirmation-dialog visual check passed (buttons localized after the check).
- Still advisable before final MVP: broader interactive and device testing, user-data corruption/sync handling, security and backend; no claim of universal timezone validation.

### Profile photo checkpoint
- Added gallery selection, replacement and removal, shared by the profile and app bars; without a photo the spark mark appears. Name alone never selects a demo portrait.
- Resized picker output is validated and saved locally with a 750 KiB limit; malformed data and cancelled selections fall back safely. Android picker lost-data recovery is included. iOS photo access description and Android Internet permission added.
- Web selection and reload checked in a browser; Flutter analyzer and 69 tests pass. Web preview uses browser local storage, while mobile uses app-local preferences. Photo is device-local, not account-isolated or synced; it may be lost if local app/browser data is cleared. Real device photo picker, Android release build and iPhone build/test still needed; this Linux environment has no Android SDK or Xcode. Actual reminder/sound integrations, secure accounts and sync remain future work.

### Reminders — planning groundwork (not yet working notifications)
- Added and tested a pure weekly reminder planner respecting per-habit time, recurrence, pause and the global toggle. Invalid times are ignored. 74 tests pass and analyzer reports no errors.
- This is groundwork only: no device notification scheduling or permission request has been connected yet. The current settings switch is not a working notification implementation.
- Next: select and configure native notification and timezone plugins, handle permissions and denied state, schedule and cancel after each relevant edit and on resume/timezone changes, exclude demo mode, handle Android reboot and iOS pending notification limit without silently dropping reminders, and test on physical devices. Android SDK and Xcode are not available in this environment. User-facing permission/failure text must be bilingual, and notification timing may be inexact under OS restrictions.

### Native reminders — integration checkpoint (device verification outstanding)
- Added local scheduled notifications for Android/iOS, permission requests on activating/saving a reminder, reconciliation on habit/settings/language changes and app resume, and Android boot rescheduling receivers. Weekly rules are compacted to daily where possible; iOS's 64 pending-request limit is surfaced and existing pending reminders cleared rather than silently ignoring some. Device timezone is refreshed when the app resumes. Android uses inexact scheduling, so OS power management can delay notifications. Web/demo do not schedule reminders. Habit title is shown as originally saved; notification title follows app language.
- Android Gradle config requires compile SDK 37 and Java library desugaring; iOS 15 minimum. No exact-alarm entitlement requested. Tests include mocked native channels, rule planning and sequencing; 78 Flutter tests pass; analyzer has no errors; web builds. This environment lacks Android SDK, macOS/Xcode and physical devices, so native compilation, permission UX, delivery/reboot/DST/timezone behavior and OS limitations are NOT verified. This checkpoint must not be represented as production-ready. Timezone changes while the app remains closed may retain old scheduling until it is reopened. System notifications and channel settings govern sound; in-app sound/haptic preference remains separate and not fully implemented.

### Completion sound and haptic checkpoint
- Added a short original bundled chime and medium haptic feedback when a user action first crosses today's target, from any completion control. No feedback on partial progress, unchecking, old dates, reloads or target edits; the profile sound/haptic switch disables both. Failures in playback don't prevent saving.
- Analyzer: no errors; 79 Flutter tests pass, including mocked feedback and preference scenarios; browser verified audio asset was requested and played after completing a demo habit. Device ringer/audio/vibration behavior varies, and Android/iPhone builds and hardware remain untested until the final mobile testing phase requested by the user. Notification sound uses OS/channel settings, not this in-app feedback switch.
- Spark mascot: user wants a distinctive encouraging character (completion, late reminders, streaks) before backend, to be designed next; no mascot is implemented yet. User chose to postpone comprehensive mobile device testing until after backend.

### Layout fixes — profile sound row and habit identity
- Fixed dark habit identity field painting over the selected habit icon; the framed input now sits beside the icon and encloses its label. Arabic title label aligns with the input.
- Replaced fixed-position profile settings text with a responsive row that reserves space for its trailing control, wraps subtitles, grows as needed, mirrors the layout for Arabic, and labels the toggle for accessibility. Reviewed dark web screenshots in English and Arabic at 390px and added regression tests including 320px row bounds and icon selection. Analyzer reports no errors and all 82 tests pass; physical iPhone/Android testing remains for the final testing phase.

### Web cache fix after user reported old UI
- Verified the deployed layout itself was correct in a fresh browser, but found the old index cache fix was incomplete: Flutter's generated bootstrap re-registered a service worker, and main.dart.js was not fingerprinted. Existing users could therefore continue seeing an earlier build even after a normal refresh.
- Deploy patch now produces content-fingerprinted bootstrap and main filenames and disables worker registration; existing workers are unregistered without clearing local data. Added refresh.html as a same-origin entry point absent from the old worker's cache manifest, and a regression test for the deployment patch. This is a web review build and no longer promises offline caching. Data is not intentionally removed. Verify on the live deployment and ask user to confirm on their own browser; physical iPhone cannot be verified here.

### Spark mascot — first interactive checkpoint
- User selected an original cute mascot concept; included a transparent cut-out in the app. A friendly bilingual celebration appears for a user crossing today's goal, independently of the sound switch, with a streak message at 3+ routine days. No celebration for partial progress, undo, old dates, reload or target edits. Home displays a gentle nudge only if a scheduled, unpaused, unfinished habit is past its explicitly configured reminder time, otherwise a streak message for 3+ days. Home checks the time once a minute; this is an in-app message, not a background push notification. No fabricated habits or stats on first launch.
- Analyzer has no errors; 84 tests passed including overdue schedule/paused/done/time cases and completion-event checks. English/Arabic dark Home and completion interaction reviewed in local browser. Still to do: wider frontend/localization/accessibility/data-persistence audit, native builds and device checks after backend per user; current mobile recurring reminders are not yet guaranteed to be suppressed after a habit has been completed, nor do they carry the mascot, and must not be described as intelligent late notifications.

### Local habit storage safety checkpoint
- Serialized repository saves in call order; reload waits for outstanding writes, and a failed write does not block later saves. Blank, malformed, non-object and structurally invalid saved habit payloads now raise a load error instead of silently seeding over the original. A bilingual retry screen prevents normal editing when the snapshot cannot be loaded. SharedPreferences write failures are surfaced as errors.
- 87 Flutter tests pass, including slow concurrent writes, a failed write followed by a retry, and preserving malformed data. This is not a full recovery/backup solution: in-session save errors still need a clear, reliable user-facing retry workflow and conflict/corruption recovery must be designed; browser data clearing can still erase local-only information. Backend and device testing remain later phases.

### Spark presence, animation and late-alert choice (partial)
- Spark now always appears in a small Home card, including a fresh empty installation and regardless of the late-alert preference. Gentle idle motion and celebration motion honor the device's reduce-motion setting. Created a concerned expression for in-app late nudges, with a one-hour grace period after a habit's reminder time; completed, unscheduled and paused habits are excluded from the in-app late state.
- New local signup and initial guest entry offer a choice about future Spark late alerts. Skipping explains Profile > Preferences; a separate preference is persisted locally, off by default, and editable there. It is clearly labeled coming soon: the selection saves intent ONLY, and does not yet create smart alerts or ask notification permission. The current basic daily reminder setting is separate and may notify even if the habit was already completed.
- Still required: implement actual after-one-hour and near-end-of-day intelligent notifications that cancel on completion, respect the opt-in, device permission, quiet-hours/edge cases, scheduling limits and day/time changes. This must not be claimed done or silently use the existing repeating reminders as a substitute. The choice is device-local, not account-synced; revisit when backend is designed. Android/iOS build and physical notification tests remain after backend per user.
- Analyzer reports no errors; 90 Flutter tests pass, including choice persistence, reduced motion and mascot time logic. Browser reviewed guest opt-in dialog, skip result and empty Home in English and Arabic; account signup hook is implemented but full visual signup flow still needs manual QA.

### Spark articulated animation checkpoint
- User clarified that moving the entire picture was not enough: Spark itself must animate. Split the selected artwork into illustrated limbs and facial states for both happy and concerned expressions. Flutter now independently pivots arms and feet and blinks Spark's eyes, with more energetic limb movement on completion; the Home card remains present and small. This is a 2D layer rig (not frame-by-frame character animation or a 3D model). Reduced-motion setting displays the original static illustration.
- Checked actual successive browser frames for changing limbs and no missing assets; animator tests cover limb transforms, blink frames, concerned state and reduced motion. Flutter analyzer has no errors; 91 tests pass. Physical mobile performance/behavior remains untested until the final testing phase. Smart late notifications are still pending, separate from the in-app concerned expression.

### Spark as a roaming interactive pet
- User clarified Spark must behave like a pet roaming the screen, rather than a fixed card. Moved Spark into a small movable overlay on Home, Habits, Details, Profile and Progress. It walks between positions with articulated limbs and blinks, can be dragged, reacts with a laughing expression and speech when tapped or a goal is completed, and is hidden while dialogs/sheets or the keyboard are open. Reduce-motion disables autonomous movement and remains manually draggable.
- Sad mood is now based on the latest missed *past scheduled day*, not an overdue time today. It excludes paused/unscheduled days and today; tapping the pet comforts it without marking habits complete. The comfort state is stored locally keyed by the missed day, and a new missed day can make Spark sad again. For efficiency, lookback is limited to 14 days and considers currently active habits' latest scheduled day; very old misses/long pauses are not reconstructed. The mood is only in-app; intelligent late push alerts are still not implemented.
- Flutter analyzer has no errors and 92 tests pass. Tests cover completed/missed/paused days, drag, comfort and not falsifying progress. Browser screenshots confirmed the character changes location and reacts; browser did not report JS errors. Hardware touch/notifications, performance and accessibility on Android/iPhone remain unverified until the final device test phase.

### Spark navigation-floor pet
- Spark now walks above the navigation bar, pauses, waves, shows a heart and turns; drag and release above the bar to see her fall and become upset, then tap to comfort her. Reduced-motion settings skip the fall animation.
- Completing today's target earns a randomly selected cookie or cake, once per habit per day; tap Spark to feed the oldest treat. Inventory is local and demo inventory is temporary. Missed-day mood remains separate from fall mood.
- No backend or smart notification delivery was added. Treat and habit saves are separate local writes; treat write failure does not undo habit progress, so a failed write can lose that reward. Native devices still need testing.

### Spark frame-sequence first pass
- Added hand-selected image frames for walking and waving, and a timed idle sequence with two jumps, turning to show her back, and presenting a heart. Cookie chewing alternates two frames. Preloads the frames and preserves reduced-motion, drag, floor, comfort, and treats.
- This is a first pass, not a full high-frame-count character animation: generated poses can vary and the cake, falling and comfort still need additional matching frames. User requested every motion as image sequences; continue those in a later turn. Native device validation remains outstanding.

### Spark walk-cycle experiment
- Added 16 registered walk-cycle PNG frames, preloaded and played at 12.5 fps in both directions, instead of alternating the previous three independently generated poses. The cycle is rendered offline from one side image and separated leg layers; it is an interpolated rig, not 16 hand-drawn poses or a finalized natural walk. The user should review it before the other actions are expanded.
- A browser smoke test found no page errors, and tests cover the sequence and reduced-motion behavior. Gentle placement vs falling, random comfort requests and naming remain future work; the existing behavior has not yet been changed for these.

### Walk visibility follow-up
- User reported the first walk was not visibly moving. Shortened the initial wait by starting the walk immediately, shortened the ordinary pauses, and increased the stride. Browser screenshots confirm horizontal displacement and the walk assets load, but the gait is still generated from one rig rather than drawn as 16 distinct poses; it is not yet approved as a natural walk. Reduced-motion system settings intentionally disable automatic movement.

### Mascot animation reset requested by user
- Removed the earlier generated pose/frame assets and rigs from the current app; retained the chosen original `spark.png` as the sole mascot artwork. The nav-bar pet is temporarily still and fixed at 76 logical pixels. Old assets remain in previous Git history, not in the current app.
- Paused movement, dragging, falling, animated expressions and celebration while the new image sequences are planned. Habit data, missed-day mood state, and locally earned treats remain; tapping can comfort/feed with text feedback. These are placeholders, not final interactions.
- The next implementation should use carefully registered, consistently sized illustrated frames for each action, starting with walking, and be reviewed by the user before subsequent actions.

### New mascot sequence: standing blink
- Started over using the chosen original artwork. Blink uses the original open frame and three painted eye-only frames, then plays them in reverse; all frames share the same 546×600 canvas and alpha, and the body, face outside the eye area, and app display size remain unchanged. It blinks roughly every three seconds; no walking or drag animation was restored.
- Reduced motion shows the original still. Frame-order/size widget tests pass; browser checks confirm frame assets load and actual pixels change. Awaiting user approval before starting the next movement.

### Resting group, movement 2: looking left and right
- Added six eye-only look frames drawn from the original artwork, displayed in a sequence that looks left, returns to center, looks right and returns. This is an eye glance, not a head turn; ask the user to approve it. Body/size/canvas/alpha remain unchanged, and the approved blink alternates with the look sequence.
- Tests cover both directions, stable size/position and reduced motion; browser loaded all six files without page errors. User review required before adding sitting or subsequent motions.

### Separate sit preview (not integrated)
- At the user's request, new motion work goes into a separate preview, and is not added to the app until the whole set has been approved. The sit prototype is a self-contained `web_extra/spark-sit-preview.html`, with twelve offline-generated in-between PNGs and the original face/body kept at the same scale. The endpoint is an experimental seated pose; interpolation is a draft and needs the user's review.
- The existing in-app blink/look remains unchanged. Sit-to-stand and the rest of the group are not done; treat the preview as unapproved. The replay button and frame loading were checked in a browser. The separate HTML is published alongside the app without changing app behavior.

### Sit preview revision (separate, unapproved)
- User requested a more realistic sit. Added a separate v2 preview: twenty registered frames include a distinct knee-bend stage, followed by lowering into the sit, while retaining the original face/body proportions. Leg contours are computationally interpolated between posed references and can still distort; this is a draft for review, not a claim of professional hand-drawn animation.
- The v2 preview is standalone, not integrated into the app. Browser smoke test verifies animation advances and replay works. User approval remains pending.

### Sit preview v3 — feet forward, still a draft
- User rejected v2 as unnatural and selected a seated pose with the feet forward. Made a separate v3 experiment with 24 exported frames, original face/body art retained at fixed scale, feet emerging forward as the body lowers. The transition is computationally generated between pose elements, not 24 independently hand-drawn poses, so its naturalness must be judged by the user; no claim of final quality.
- No app behavior changed. The stand-up movement and other idle actions remain pending. Browser smoke test confirms frames change and replay works.

### Separate jump-to-sit experiment
- User proposed jumping and landing seated instead of the rejected direct sit transition. Built `web_extra/spark-jump-sit-preview.html` as a standalone draft: original-size registered frames, a small preparatory bend, a parabolic jump and landing with the feet forward. It uses the previously drafted seated-pose elements and offline compositing/interpolation, not independently drawn frames; awaiting the user's review.
- The preview and its builder are separate from the app. No existing in-app behavior changed. Browser smoke test verifies replay/frame updates; a frame audit shows constant canvas size and the same start/end floor line.

### Jump with hand movement: separate experiment
- User asked for a small knee bend and hand movement, and asked how to achieve appealing motion. Made an isolated `spark-jump-arms-preview.html` with a slight lowering before takeoff and arms responding to the jump. It preserves the original face/body and never changes the app.
- Important: this draft uses composited, pivoted arm artwork and interpolated pose elements. It is not a fully hand-illustrated action sequence; the knees are suggested by a small body lowering, not fully drawn knee-bend frames. The user has rejected mechanically moving limbs before, so be explicit and do not call this an approved or fully realistic result. More carefully drawn key poses and intermediate frames are needed for a genuinely organic result.
- Browser smoke test confirms replay and frame updates. Await feedback before integrating anything.

### Jump preview with opaque limb silhouettes
- User reported backgrounds around raised arms, wanted arms to straighten as they rise, and rejected leg fade-in, requesting an old-style frame sequence. Built a separate experiment using transparent arm cutouts, an illustrated straighter raised-arm pose, and registered frames whose foot silhouettes morph without introducing a second leg via an opacity fade. Original face/body/scale remain unchanged.
- These are computationally interpolated silhouettes, not 44 individually hand-drawn frames or a claim of classic animation quality; intermediate limb shapes may still need redrawing. The preview is unapproved and not in the app. Browser replay/frame-loading smoke test passed, and checked output corners are transparent.

### Jump storyboard revision from user annotations
- User annotated phone screenshots: arms move upward during the jump; legs move outward in the air; the seated leg pose must not appear while airborne; arms return down and sitting occurs only after touching the ground. Made a standalone draft `spark-jump-story-preview.html` following that sequence, with an airborne leg reference and separate seated stage. Corrected the preview's ground line and prevented the top of the mascot from being clipped; feet start/end at the same floor height.
- The body/face keep their original scale. This remains a computationally interpolated draft, not a hand-drawn professional final: some intermediate arm joints/leg edges may need further redrawing, and user approval is pending. No app integration or app code changed.
- Browser smoke test checks frame changes and replay; the prior preview page remains available unchanged.

### Isolated arm-arc direction study
- User clarified that the lower tip of the arm should travel upward around its attachment in an arc and return, not slide sideways. Made a separate arm-only study with the original arms pivoting in a continuous arc; the body, feet, scale and floor remain fixed. This is an offline composited rotation study, not a completed hand-drawn/straightened arm animation or a claim that her desired path has been approved.
- No jump, sitting, or app behavior is changed. Browser replay/frame-change smoke test passed; review with user before combining with other movements.

### Refinement of approved hand path (separate preview)
- User approved the direction of the isolated hand arc and asked to refine it. Made a separate preview with more in-between frames, cleaned light background pixels from the extracted arm edges, and a modest curve adjustment while retaining the original arm's pivot and fingertip path. Added canvas margin so raised arms are not clipped. The original body, feet, and scale remain fixed.
- Still an offline digitally composited experiment, not hand-drawn production animation, and needs user approval before combining with the jump or integrating in the app. Browser smoke test verifies replay and frame changes; image bounds were checked for clipping.

### Fuller raised-hand shape (preview only)
- User liked the hand path but said the raised hand looks curved/incomplete and wants a fuller, straighter shape. Added a separate experiment widening/straightening the original arm cross-sections as they rise, retaining the approved arc and original rest pose. This is a procedural shape adjustment, not a newly hand-illustrated finished arm; it may still not match the user's intention and awaits their review.
- No app change. Replay and frame advance checked in browser; frame bounds and transparent corners checked to avoid clipping.

### Preserve original body outline while hands rise
- User noticed the dark bold body outline was interrupted around the arm attachments. Created a separate outline preview using the original contour in the fixed body layer and extracting only the arm region outside it; cleaned transparent-edge RGB to reduce light fringing. The previously approved arm path and original body scale are retained.
- Still a procedural frame study, not integrated into the app or user-approved. Browser replay and frame advancement passed; static canvas and transparent corners checked.

### Complete dark hand outlines (separate preview)
- User requested full, bold outlines around each raised hand, as well as the continuous body outline. Added a dark outline behind the arm silhouette, with the original body layered over the attachment; kept the existing path and rest pose. This remains an experimental procedural adjustment for user review, not a finished hand-drawn frame sequence and not integrated in the app.
- Browser playback and replay smoke checks passed.

### Inner edge of raised hands
- User clarified using IMG_9672.jpeg that the missing dark line is on the inner/lower edge of each raised hand, not the already dark exterior. Built a separate procedural preview painting the inner rim of the existing silhouette; retained the fixed body contour and arm arc. Awaiting visual approval; not added to the app.
- Preview playback and replay smoke-tested.

### Jump with wider legs and open-legged landing (standalone draft)
- User set aside the hand-outline issue and shared IMG_9668–9671 as references: legs open further while jumping and land sitting with legs in the same open direction, combined with the previously approved hand arc.
- Added a separate combined preview: legs spread and stay open through ground contact; torso settles after contact, hands travel along the approved arc. Original body and face remain fixed, frame canvas constant. This remains a procedural pose/interpolation draft, not a hand-drawn sequence; requires user's visual approval and is not in the app.
- Playback and replay passed in browser.
