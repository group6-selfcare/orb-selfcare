# data

Everything stored on the device. There are no accounts and no network.

- `db/`: the drift database (check_ins, tags, check_in_tags), PMG6-49
- `profile/`: the Profile model and `ProfileRepository` on shared_preferences, PMG6-48
- `check_in/`: the `CheckIn` model, `dayKey` (local date, rolls over at midnight) and `CheckInRepository` with its providers (`checkInRepositoryProvider`, `todayCheckInProvider`, `tagsProvider`, `clockProvider`), PMG6-50

Tests swap the database for an in-memory one with `inMemoryDatabase()` from `test/helpers/test_database.dart`.

UI code only uses the repositories and their providers, never drift or shared_preferences directly.
