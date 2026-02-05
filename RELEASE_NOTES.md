# BetterBlizzFrames 1.8.9c
## Midnight/Prepatch
### Bugfix
- Fix forcing manabars borders to show with Pixel No Portrait setting even though "Hide Target/Focus Manabar" was enabled.

# BetterBlizzFrames 1.8.9b
## Midnight/Prepatch
### New
- Add sub-setting to the party range alpha setting that keeps the background always solid non-transparent. This is enabled by default now (as it was before).
- Add variable to skip bug warning on login (will remove this ofc when I feel like it), type: /run BetterBlizzFramesDB.skipBugWarning = true
### Bugfix
- Fix nil frame error
- Fix some locale issues for gui tooltips

# BetterBlizzFrames 1.8.9
## Midnight/Prepatch
### New
- Show CD Timer on Auras (Buffs & Debuffs) and size setting for it.
- Split "Hide Target/Focus Auras" into "Hide Target/Focus Buffs/Debuffs".
- Add Wolf profile (www.twitch.tv/wolfzx)
- Add Trimaz profile (www.twitch.tv/trimaz_wow)
### Tweak
- Force show No Portrait pixel border on manabar on targets without mana as well for consistency.
- Add new damage meter header to dark mode.
### Bugfix
- Fix aura stack scale setting not being properly implemented, size slider works now.
- Fix No Portrait's border glow texture not being the smaller one when manabar was hidden.
- Fix own Pet detection in Class Icon/Party Pointer now that Blizzard allowed it again.
- Fix lua error on login as petclass with texture changes enabled.
- Fixes to No Portrait setting Healthbar getting weird on party frames (hopefully)
- Many minor misc things I've probably forgot to mention. Please continue to report bugs and thank you so much!
## All classics
### Tweak
- TBC: Add missing roots to Loss of Control setting.
- Fix Class Icons setting to work on default party frames.
## Note
- Spec name stuff might be dead, probably, we'll see.
- The game is still undergoing tons of changes and in an extremly buggy state despite being in Prepatch and releasing in a few weeks. Many things are getting restricted and unrestricted and its a pain to develop for as we have no idea what is happening most of the time. 