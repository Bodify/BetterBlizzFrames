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