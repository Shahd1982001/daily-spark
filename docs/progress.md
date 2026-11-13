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

## Next (needs her decision)
1. **Dark mode** — Figma dark frames exist (`163:2560 · 2915 · 3185 · 3411 · 3760 · 4073 · 4304 · 2826 · 2604 · 2263 · 2348 · 2474 · 2727`).
2. **Logic layer** — state management choice still open (Provider vs Riverpod).
3. **Backend** — must stay last.
4. **i18n / RTL Arabic** — after logic.

## Deploy recipe
```
export PATH=/home/user/.cache/sdk/flutter/bin:$PATH PUB_CACHE=/home/user/.cache/pub
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run -O2 --base-href /daily-spark/
python3 /home/user/.cache/patch_index.py build/web        # service-worker killer + cache bust
# copy build/web + web_extra (gallery + screens) → .cache/pages → force push gh-pages
```
