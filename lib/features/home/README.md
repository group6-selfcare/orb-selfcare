# home

The Home tab: the pig, the trait greeting, the Check in button and the Today card.

After check-in (PMG6-64): Home watches `todayCheckInProvider`. The pig takes `PigPose.forLevel(level)`, the greeting is `HomeCopy.greetingFor(trait, level)`, and the Today card shows the level face and label, the emotion, the note (2 lines) and the tags. The Check in button becomes a quieter outlined Edit. Both open `/check-in`, which pre-fills today's entry. `todayCheckInProvider` moves to the new day at local midnight and on app resume, so Home then falls back to the before-check-in state.
