# BetterBlizzFrames 1.9.7
## Midnight
### New
- Party and Pet castbars are back and working!
- Overshields is fixed and back. If you have used an alternative then either turn off this setting or the alternative so you dont run it twice. (And again huge thanks to Verz (MiniCC, FrameSort, etc) for being the goat and helping me a bit here)
![castbarsAndOvershields](https://github.com/user-attachments/assets/fdf2b502-459f-4d82-bde3-26086d5ab39e)
### Bugfix
- Fix "Arena Names" on Target/Focus sometimes showing wrong name.
## The Burning Crusade
### Bugfix
- Add another detection method for spell interrupt ids so Earth Shock (and maybe others) should hopefully be picked up more consistently now.
- Fix Overshields for enemy units showing absorb on entire healthbar (since they dont have proper health info in TBC). It will now just hide unless you have MiniHealthNumbers addon. If you get MiniHealthNumbers to calculate health on enemy units overshields will work on enemy targets.