# BetterBlizzFrames 1.9.7g
## Midnight
### Tweak
- Now checks for tullaCTC handling of aura cooldown text and ignores BBF setting if thats the case.
### Bugfix
- Fix error related to darkmode and tooltips due to secrets.

# BetterBlizzFrames 1.9.7f
## All versions
### New
- New setting for Party Castbars to force anchoring to default party frames instead of detected party frames addon. (Castbars section)
## Midnight
### Bugfix
- Fix "Classic Castbar" setting for Player Castbar sometimes showing a big non-classic glow texture.

# BetterBlizzFrames 1.9.7e
## Midnight
### Tweak
- Tweak chat filters to add a few more spammy system messages and improve the detection method.

# BetterBlizzFrames 1.9.7d
## Midnight
### Tweak
- Tweak most chatframe filters to use Blizzard globals instead so it also accounts for localization and not just English.
## All versions
### Tweak
- Party Castbars now supports other party addons as well (DandersFrames, ElvUI, Cell, Grid2, VuhDo & ShadowedUnitFrames)
- Interrupt logic: Replace IsSpellKnown API call with IsPlayerSpell because IsSpellKnown returns false on known spells on some clients causing interrupt logic to not detect an interrupt.

# BetterBlizzFrames 1.9.7c
## Midnight
### Bugfix
- Fix layer issue introduced in 1.9.7b showing Stealth Indicator above PlayerFrame unintentionally. 

# BetterBlizzFrames 1.9.7b
## Midnight
### Bugfix
- Fix an issue with party castbars getting stuck on if party members left group while casting.
- Fix overshield not updating immediately on the PRD when it was set to shown in combat only.
- Fix a layering issue with overshields on normal UnitFrames.
- Fix nil error related to new party castbars and castbar coloring.
## All versions
### Tweak
- Update the new Midnight Stealth Indicator logic for all other versions too (and fix it for TBC).

# BetterBlizzFrames 1.9.7
## Midnight
### New
- Party and Pet castbars are back and working!
- Overshields is fixed and back. If you have used an alternative then either turn off this setting or the alternative so you dont run it twice. (And again huge thanks to Verz (MiniCC, FrameSort, etc) for being the goat and helping me a bit here)
- Hide External Defensives Tooltip (Misc).
![castbarsAndOvershields](https://github.com/user-attachments/assets/fdf2b502-459f-4d82-bde3-26086d5ab39e)
### Tweak
- BetterBlizzFrames now makes External Defensives clickthrough by default so you can actually move your camera.
### Bugfix
- Fix "Arena Names" on Target/Focus sometimes showing wrong name.
## The Burning Crusade
### Bugfix
- Add another detection method for spell interrupt ids so Earth Shock (and maybe others) should hopefully be picked up more consistently now.
- Fix Overshields for enemy units showing absorb on entire healthbar (since they dont have proper health info in TBC). It will now just hide unless you have MiniHealthNumbers addon. If you get MiniHealthNumbers to calculate health on enemy units overshields will work on enemy targets.