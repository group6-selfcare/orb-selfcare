# QA test plan: Daily check-in MVP (PMG6-41)

QA runs these cases on every ticket in **In Review** before it moves to **Done**, and runs the whole plan again for the end-to-end pass (PMG6-66) on the build from `main` before the sprint review.

Fill in **Result** (Pass or Fail) and **Date** (yyyy-MM-dd) as you go. File every Fail as a Bug linked to PMG6-41, with a screenshot, and put the bug key in the Result cell.

## Test devices

Fill in the real phone before the first run. PMG6-65 asks for the model and Android version of every test device.

| Device | Android | Screen | Used for |
|---|---|---|---|
| _Real phone: QA to fill in (model)_ | _version_ | _size_ | All cases, end-to-end pass |
| Android emulator, Pixel 8 profile | 16 (API 36) | 6.2", 1080 × 2400 | Day-to-day checks |
| Android emulator, small phone | 16 (API 36) | 4.7", 720 × 1280 | Small-screen case X6 |

## How to start fresh

Uninstall the app, or use **Reset onboarding (debug)** at the bottom of Home in a debug build. To test the database from zero, uninstall: the reset only clears the profile.

## Automated tests

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| A1 | On the commit under test, run `flutter test` | All pass. This covers the widget tests the tickets ask for (tapping Good saves level 4, Family and Work saved on Done, edit updates the same row, 48dp faces, each tab keeps its own stack) and the profile and database tests | | |

## Cross-cutting cases

| ID | Case | Steps | Expected | Result | Date |
|---|---|---|---|---|---|
| X1 | Fresh install | Uninstall, install, open | Splash, then N1 Meet your companion. No Home flash. | | |
| X2 | Kill and reopen | Check in, swipe the app away from Recents, open again | Home opens directly with the same pose, greeting and Today card | | |
| X3 | Just before midnight | Set the phone clock to 23:58, check in as Good, wait until 00:01, put the app in the background and open it again | Home is back to "No check-in yet today". Opening Check in starts empty with title "Today" | | |
| X4 | Just after midnight | At 00:01 check in as Low, then edit it | Still one check-in for the new day. Title "Edit today" when reopened | | |
| X5 | Font scale 1.3 | Run `adb shell settings put system font_scale 1.3` (or pick 130% under Settings, Display, Font size). Go through onboarding, check-in and Home. Reset with `font_scale 1.0` | No clipped or overlapping text, every button reachable, Today card note still 2 lines | | |
| X6 | Small screen | Run on the small-phone emulator. On N2 and N4, tap the text field so the keyboard opens | Check-in faces fit on one row, extras scroll, Done/Continue always visible. With the keyboard open, the name field and Next stay visible | | |
| X7 | TalkBack on faces | Turn on TalkBack, open Check in, swipe through the faces | Each reads "Feeling Rough", "Feeling Low", … as a button; the picked one is announced as selected | | |
| X8 | TalkBack on Home | Swipe through Home before and after a check-in | Pig, greeting, Check in or "Edit today's check-in", and the Today card are all announced | | |
| X9 | Back button | Use Android back on every onboarding step, the check-in and N15 | Goes back one step; on N1 it closes the app; after Go to Home it never returns to onboarding | | |
| X10 | Largest font | Same as X5 with Font size at the largest setting | Text may wrap, but nothing is cut off and every button is still reachable | | |

## Per-ticket cases

### PMG6-47: Tab shell

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| S1 | Tap each tab in turn | The selected tab shows its coloured icon and a dark label; the others are grey | | |
| S2 | Open Space, Quest and Profile | Each shows the pig and "Coming soon" | | |
| S3 | Open Check in from Home | No tab bar on the check-in screen | | |
| S4 | On Space, press Android back; then press back again on Home | First back returns to Home; second back closes the app | | |

### PMG6-48: Profile storage

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| P1 | Finish onboarding, kill the app, open it again | Home opens (not N1) and the greeting uses the same user name, pig name and trait voice | | |
| P2 | Fresh install, go to N4 | N4's name field is empty | | |

### PMG6-53 to 57: Onboarding and first-launch routing

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| O1 | Fresh install, look at N1 | Waving pig, "Hi! I'm your new companion", Let's begin, progress bar at step 1 of 4. No "I already have an account" link | | |
| O2 | Tap Let's begin | N2 "What would you like to call me?" with a suggested pig name and the progress bar at step 2 | | |
| O3 | N2: tap Suggest another name a few times | A different name each time, never the one already shown | | |
| O4 | N2: clear the field, then type only spaces, then type 25 letters | Next is disabled when empty or only spaces; the field stops at 20 characters | | |
| O5 | N2: type a name, Next, then back | The typed name is still there | | |
| O6 | Open N3 | "What am I like?", Gentle, Cheerful and Playful cards, each with a description and a sample line. Gentle is already picked | | |
| O7 | N3: pick Playful, go back to N2 and forward again | Playful is still picked | | |
| O8 | N3 with TalkBack on: swipe through the cards | Each card is read with its name and whether it is selected | | |
| O9 | Open N4 | "And what's your name?", hint "Your first name or nickname", helper "I'll use it when I talk to you. Only you will see it.", progress bar at step 4 of 4 | | |
| O10 | N4: clear the field, type only spaces, type 25 letters; then type a name, go back to N3 and forward | Next is disabled when empty or only spaces; the field stops at 20; the typed name is kept | | |
| O11 | N4: type a name, Next | First check-in opens. Profile is saved but onboarding is not done (kill and reopen goes to N1) | | |

### PMG6-49, 50: Database and repository

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| D1 | Check in twice on the same day with different levels | Home shows only the latest; reopening shows "Edit today" | | |
| D2 | Pick tags, save, then edit and pick different tags | Only the new tags show on Home | | |
| D3 | Run `flutter test test/data` | All pass (seeded 18 tags, one row per day, midnight split, profile save and load) | | |

### PMG6-58: Mood step

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| M1 | Open Check in from Home | Waving pig, "How are you feeling today?", 5 labelled faces | | |
| M2 | Tap Good, then kill the app without tapping Done | Reopen: Home shows Feeling Good (the tap alone saved it) | | |
| M3 | Open Check in, press back without tapping a face | Home still says "No check-in yet today" | | |
| M4 | Tap a face, then Done | Back on Home with the check-in | | |

### PMG6-59: Emotion

The PO approved the level-to-emotion mapping as drafted (Q2). If it changes later, update E1.

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| E1 | Tap each level in turn | "Want to name it?" shows that level's 4 faces (Great: Excited, Happy, Loved, Surprised; Good: Happy, Peaceful, Loved, Okay; Okay: Okay, Peaceful, Tired, Sleepy; Low: Sad, Disappointed, Tired, Numb; Rough: Angry, Anxious, Stressed, Sad) | | |
| E2 | Pick Peaceful, tap it again | Selected, then cleared | | |
| E3 | Good + Happy, then switch to Great; then switch to Low | Happy stays on Great, is cleared on Low | | |

### PMG6-60: Note and tags

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| NT1 | Look at the empty note field, then type a long note | Hint "Add a note (optional)". Typing stops at 500 characters, counter shows 500/500 | | |
| NT2 | Look at "What's it about?", then tap More tags | 8 chips (Work, Education, Family, Friends, Health, Self Care, Money, Partner); More tags shows 18; Fewer tags folds back to 8 (picked ones stay) | | |
| NT3 | Pick Family and Work, type a note, press back | Both chips show as selected (sapphire) before leaving. Home shows both tags and the note | | |
| NT4 | Look for a way to create a tag | There is none | | |

### PMG6-61: Edit today

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| ED1 | After a check-in, tap "Edit today's check-in" on Home | Title "Edit today", everything pre-filled | | |
| ED2 | Change the level and note, Done | Home updates at once, still one check-in | | |
| ED3 | Tap the Today card | Opens the same edit screen | | |

### PMG6-62: First check-in and N15

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| F1 | Finish N4 | "Your first check-in", "How are you feeling right now?", no tab bar | | |
| F2 | Tap a level | Skip appears top right, button says Continue | | |
| F3 | Continue (and separately, Skip) | N15: cheering pig, "Day one, done!", the trait's line, Go to Home. No weekly dots | | |
| F4 | First check-in as Rough or Low | N15 line is gentle whatever the trait (see Q1) | | |
| F5 | Go to Home, then press back | App closes; Home shows today's check-in | | |

### PMG6-63, 64: Home

| ID | Steps | Expected | Result | Date |
|---|---|---|---|---|
| H1 | Before check-in | "Orb" header with the Check in button top right, curious pig, trait greeting with both names, filled Check in button, empty Today card "No check-in yet today" | | |
| H2 | Before check-in, tap the Check in button; then go back and tap the empty Today card | Both open the check-in | | |
| H3 | Scroll the whole of Home | No Journey, Your goal or Suggestions sections | | |
| H4 | Check in at each level 1 to 5 | Pose: Rough comforting, Low listening, Okay calm, Good joyful, Great cheering. Never a sad or disappointed pig (see Q4) | | |
| H5 | Read the greeting at each level and trait | Matches the trait's voice; Rough and Low are warm, never judging | | |
| H6 | Check in with emotion, long note and tags | Today card shows face and "Feeling …", the emotion, the note cut to 2 lines, the tag chips | | |

## Questions for the PO

Where the tickets and the app disagree, the cases above follow the app. The PO decides, then either the ticket or the case is updated.

Figma is a reference, not the spec: a screen passes when it does what the acceptance criteria ask and looks good, even where it differs from Figma.

| # | Question | Ticket says | App does | Affects | Status |
|---|---|---|---|---|---|
| Q1 | Day-one line after a Rough or Low first check-in | PMG6-62: "the trait-specific line from `copy.dart`" | One shared gentle line for levels 1–2, whatever the trait | F3, F4 | Open |
| Q2 | Level-to-emotion mapping | PMG6-59: used "once the PO approves it" | The mapping in E1 | E1, E3 | Decided: approved as drafted |
| Q3 | Selected chip colour | PMG6-60: "the pink style from Figma" | Sapphire, from the app's chip theme | NT3 | Decided: keep sapphire |
| Q4 | Level-to-pose table | PMG6-51: the table is "added to this ticket" | The mapping in H4, from `lib/shared/pig_pose.dart` | H4 | Decided: table added to PMG6-51 |

## Sign-off

| Run | Build (commit) | Device | Tester | Passed | Open bugs | Date |
|---|---|---|---|---|---|---|
| | | | | | | |
