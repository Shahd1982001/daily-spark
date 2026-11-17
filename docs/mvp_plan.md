# Daily Spark — roadmap to a demonstrable MVP

Product goal: a polished, honestly described, usable trial version to show a company. English and Arabic only. Every phase gets its own test and review checkpoint. Review demo data stays separate from normal users. No real backend until agreed.

## 1. Protect habit data — first checkpoint
- Fixed: permanently deleting one habit must not erase partial amounts of other habits, including after reload.
- Regression test reproduces the issue and verifies today, yesterday, deletion and persistent reload.
- Audit save failures, concurrent edits, loss of local data, and handling of corrupted storage separately; don't claim the local store is foolproof yet.

## 2. Habit workflow and calculations
- Decide and implement restore/unarchive, sorting, edit/cancel confirmations and empty states.
- Verify schedules, partial completion, targets, day rollover, streaks, progress and changed schedules with explicit scenarios and tests.

## 3. Real personalisation
- Replace the static example avatar for real users with an honest fallback; implement optional profile-image picking and storage, with Home and Profile reflecting the same image. Agree on limits and sync when backend is defined.
- Verify editable display name and profile settings without overwriting user data.

## 4. Notifications and feedback
- Agree which device platforms are intended and notification permission rules; implement only supported reminders and clearly distinguish saved preferences from active notifications.
- Implement or honestly disable sound/haptics and validate dark mode/accessibility.

## 5. Arabic/English polish and presentation
- Review every screen, dialogs, errors, empty/loading states and layout in both languages. Machine translation of habit titles uses an external provider by user approval; keep original text and handle offline/failure transparently.
- Review onboarding, privacy text, demo claims and screenshots. Preserve the gallery and deliver working checkpoints.

## 6. Backend — after user requirements and other work are accepted
- User choice: guest or account, with a path to move guest habits to an account; agree exactly when and how migration occurs and what happens on conflict/sign-out.
- Select stack with user, design secure authentication (no plaintext password storage), account isolation, recovery, cloud persistence, sync/offline conflict handling, profile photos, privacy, account/data deletion and backups.
- Implement and test security, migration, errors and deployment; keep current local authentication clearly labelled as insecure development-only. Do not use real passwords in the preview.

## 7. Release-readiness checklist
- End-to-end journeys from first launch to creating, tracking and recovering habits; test multiple devices/platforms after target platforms are chosen, keyboard/accessibility, performance and reliability.
- Prepare a concise company demo, test instructions and known limitations. Call it an MVP only after core scenarios work reliably; this is not a claim of production certification.

### Point 2 checkpoint — historical plans and calendar
- Plan changes are versioned from the edit date; before-feature edits cannot be recovered retroactively. A unit change resets the current day after confirmation, leaving earlier units and logs intact.
- Device-local civil-day arithmetic and date refresh are covered by automated transition tests; broader physical-device and cross-device/timezone sync testing remains for release.
