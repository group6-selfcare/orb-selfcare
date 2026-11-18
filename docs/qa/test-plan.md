# QA test plan: Daily check-in MVP (PMG6-41)

QA runs these cases on every ticket in **In Review** before it moves to **Done**, and runs the whole plan again for the end-to-end pass (PMG6-66) on the build from `main` before the sprint review.

Fill in **Result** (Pass or Fail) and **Date** (yyyy-MM-dd) as you go. File every Fail as a Bug linked to PMG6-41, with a screenshot, and put the bug key in the Result cell.

## Test devices

| Device | Android | Screen | Used for |
|---|---|---|---|
| _Real phone: QA to fill in (model)_ | _version_ | _size_ | All cases, end-to-end pass |
| Android emulator, Pixel 8 profile | 16 (API 36) | 6.2", 1080 × 2400 | Day-to-day checks |
| Android emulator, small phone (720 × 1280, 4.7") | 16 (API 36) | 4.7" | Small-screen case X6 |

## How to start fresh

Uninstall the app, or use **Reset onboarding (debug)** at the bottom of Home in a debug build. To test the database from zero, uninstall: the reset only clears the profile.

## Cross-cutting cases

| ID | Case | Steps | Expected | Result | Date |
|---|---|---|---|---|---|
| X1 | Fresh install | Uninstall, install, open | Splash, then N1 Meet your companion. No Home flash. | | |
| X2 | Kill and reopen | Check in, swipe the app away from Recents, open again | Home opens directly with the same pose, greeting and Today card | | |
| X3 | Just before midnight | Set the phone clock to 23:58, check in as Good, wait until 00:01, put the app in the background and open it again | Home is back to "No check-in yet today". Opening Check in starts empty with title "Today" | | |
| X4 | Just after midnight | At 00:01 check in as Low, then edit it | Still one check-in for the new day. Title "Edit today" when reopened | | |
| X5 | Large font | Settings, Display, Font size at the largest (scale 1.3 or more). Go through onboarding, check-in and Home | No clipped or overlapping text, every button reachable, Today card note still 2 lines | | |
| X6 | Small screen | Run on the small-phone emulator | Check-in faces fit on one row, extras scroll, Done/Continue always visible | | |
| X7 | TalkBack on faces | Turn on TalkBack, open Check in, swipe through the faces | Each reads "Feeling Rough", "Feeling Low", … as a button; the picked one is announced as selected | | |
| X8 | TalkBack on Home | Swipe through Home before and after a check-in | Pig, greeting, Check in or "Edit today's check-in", and the Today card are all announced | | |
| X9 | Back button | Use Android back on every onboarding step, the check-in and N15 | Goes back one step; on N1 it closes the app; after Go to Home it never returns to onboarding | | |

## Per-ticket cases

### PMG6-53 to 57: Onboarding and first-launch routing

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| O1 | Fresh install, tap Let's begin | N2 with a suggested pig name and the progress bar at step 2 | | |
| O2 | N2: tap Suggest another name, then clear the field | A new name appears; Next is disabled when empty | | |
| O3 | N3: pick Playful, go back to N2 and forward again | Playful is still picked | | |
| O4 | N4: type a name, Next | First check-in opens. Profile is saved but onboarding is not done (kill and reopen goes to N1) | | |

### PMG6-49, 50: Database and repository

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| D1 | Check in twice on the same day with different levels | Home shows only the latest; reopening shows "Edit today" | | |
| D2 | Pick tags, save, then edit and pick different tags | Only the new tags show on Home | | |
| D3 | Run `flutter test test/data` | All pass (seeded 18 tags, one row per day, midnight split) | | |

### PMG6-58: Mood step

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| M1 | Open Check in from Home | Waving pig, "How are you feeling today?", 5 labelled faces | | |
| M2 | Tap Good, then kill the app without tapping Done | Reopen: Home shows Feeling Good (the tap alone saved it) | | |
| M3 | Open Check in, press back without tapping a face | Home still says "No check-in yet today" | | |
| M4 | Tap a face, then Done | Back on Home with the check-in | | |

### PMG6-59: Emotion

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| E1 | Tap each level in turn | "Want to name it?" shows that level's 4 faces (Great: Excited, Happy, Loved, Surprised; Good: Happy, Peaceful, Loved, Okay; Okay: Okay, Peaceful, Tired, Sleepy; Low: Sad, Disappointed, Tired, Numb; Rough: Angry, Anxious, Stressed, Sad) | | |
| E2 | Pick Peaceful, tap it again | Selected, then cleared | | |
| E3 | Good + Happy, then switch to Great; then switch to Low | Happy stays on Great, is cleared on Low | | |

### PMG6-60: Note and tags

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| N1 | Type a long note | Stops at 500 characters, counter shows 500/500 | | |
| N2 | Tap More tags | 18 chips; Fewer tags folds back to 8 (picked ones stay) | | |
| N3 | Pick Family and Work, type a note, press back | Home shows both tags and the note | | |
| N4 | Look for a way to create a tag | There is none | | |

### PMG6-61: Edit today

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| T1 | After a check-in, tap the Edit button on Home | Title "Edit today", everything pre-filled | | |
| T2 | Change the level and note, Done | Home updates at once, still one check-in | | |
| T3 | Tap the Today card | Opens the same edit screen | | |

### PMG6-62: First check-in and N15

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| F1 | Finish N4 | "Your first check-in", "How are you feeling right now?", no tab bar | | |
| F2 | Tap a level | Skip appears top right, button says Continue | | |
| F3 | Continue (and separately, Skip) | N15: cheering pig, "Day one, done!", the trait's line, Go to Home. No weekly dots | | |
| F4 | First check-in as Rough or Low | N15 line is gentle whatever the trait | | |
| F5 | Go to Home, then press back | App closes; Home shows today's check-in | | |

### PMG6-63, 64: Home

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| H1 | Before check-in | Curious pig, trait greeting, filled Check in button, empty Today card | | |
| H2 | Check in at each level 1 to 5 | Pose: Rough comforting, Low listening, Okay calm, Good joyful, Great cheering. Never a sad or disappointed pig | | |
| H3 | Read the greeting at each level and trait | Matches the trait's voice; Rough and Low are warm, never judging | | |
| H4 | Check in with emotion, long note and tags | Today card shows face and "Feeling …", the emotion, the note cut to 2 lines, the tag chips | | |
| H5 | Tabs Space, Quest, Profile | Each says coming soon | | |

## Sign-off

| Run | Build (commit) | Device | Tester | Passed | Open bugs | Date |
|---|---|---|---|---|---|---|
| | | | | | | |
