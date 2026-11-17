# data

Everything stored on the device. There are no accounts and no network.

- `db/`: the drift database (check_ins, tags, check_in_tags), PMG6-49
- `profile/`: the Profile model and `ProfileRepository` on shared_preferences, PMG6-48
- `CheckInRepository`: PMG6-50

UI code only uses the repositories and their providers, never drift or shared_preferences directly.
