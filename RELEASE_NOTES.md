# BetterBlizzFrames 1.8.7j
## Midnight/Prepatch
### Tweak
- Update Aeghis profile

# BetterBlizzFrames 1.8.7i
## Midnight
### Bugfix
- Ignore "Show last name only" setting as this now contains secret and causes errors. Dont think theres a workaround but not looking into it right now. Assuming its gone.

# BetterBlizzFrames 1.8.7h
## The Burning Crusade
### New
- Add Edit Mode Transparency slider in the Edit Mode settings (top right).
### Tweak
- Fix default TargetFrameToT and FocusFrameToT position on TBC. You will have to tweak your ToT positions. 0,0 is default. It was changed +18 x-axis and -5 y-axis.

# BetterBlizzFrames 1.8.7g
## Midnight
### Tweak
- Added back Player Auras gap settings in the buffs & debuffs section.
## The Burning Crusade
### Bugfix
- Fix names on default party frames.
- Fix default background color for TargetFrame for Blizzard.
- Fix talent tree icons being scrambled due to class portrait setting.
- Fix tooltip for Hide Player Power in gui.
## Era
### Tweak
- Add font settings support for Verz's MiniHealthNumbers addon.

# BetterBlizzFrames 1.8.7f
## The Burning Crusade
### Tweak
- Update aura stuff with late changes made to mop version. Hopefully things like the glows etc are positioned correctly now with all sorts of settings. If you notice anything weird please let me know.
### Bugfix
- Fix some bugs caused by leftover retail code in tbc version.

# BetterBlizzFrames 1.8.7e
## The Burning Crusade
### Tweak
- Remove Player Castbar handling by BBF in TBC since this is now handled by Edit Mode instead. Your player castbar mightve moved due to this so make sure to re-adjust it in edit mode.
#### Bugfix
- Fix a nil error due to darkmode castbar logic looking for old castbar name
- Fix some old aura settings needing update for TBC. Causing Masque support to break and a few other things.

# BetterBlizzFrames 1.8.7d
## The Burning Crusade
### Bugfix
- Fix issue with OCD Tweaks setting causing healthbars and stuff to be in wrong positions.

# BetterBlizzFrames 1.8.7c
## The Burning Crusade
### Tweak
- Fix healthbar height for large healthbar setting.
## All versions
### Tweak
- Classics: Fix ToT Portrait for Class Portrait setting. Also fix it messing up Character Panel icon.
- Class Color Names setting now also supports the custom colors and also forces reaction colors on npcs instead of gray color if tapped unit.
- Fix font settings for default party frame names and increase width for larger font sizes.
### Bugfix
- Classics: Fix missing gui element causing "Class Color Names" to not show/hide the Level option on click.
- Classics: Fix DarkMode for Auras.
- Fix Format Numbers not working properly on first login on game launch.