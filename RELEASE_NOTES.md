# BetterBlizzFrames 2.0.6e
## Midnight
### Tweak
- Minor tweak to auras to try avoid spammy buggy auras due to Blizzard API while waiting for fix.

# BetterBlizzFrames 2.0.6d
## Midnight
### Tweak
- Update Snupy profile (www.twitch.tv/snupy). Thank you for sharing!
- Update Saul profile (www.twitch.tv/saul). Thank you for sharing!
- Fix Queue Status Eye's frame strata when moved.
### Bugfix
- Fix "Hide StanceBar" setting leaving a clickable area where it was hidden.
## All versions
### Tweak
- Add a hidden close button for the profiles sidebar in the top right corner of it that shows on mouseover.

# BetterBlizzFrames 2.0.6c
## Midnight
### New
- The Big Healthbar setting for PlayerFrame for the No Portrait setting (from Wildu) has now been extended to work with default frames, mirror targetframe, classic frames and also the "no portrait: pixel border" settings. It's also been moved from Misc to under PlayerFrame as "Big Healthbar" in general section of /bbf.
### Tweak
- Make BBF's new auras follow Blizzards PvE filter for which debuffs to show in PvE. By default Blizzard only shows your own debuffs while in PvE and now BBF does the same. It can be changed by enabling the no filter CVar from Blizzard and BBF will follow that too: noBuffDebuffFilterOnTarget