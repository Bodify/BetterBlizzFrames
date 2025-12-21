# BetterBlizzFrames 1.8.5b
## All versions
### Tweak
- Update the "One font for all text ingame" setting to use proper API to get all fonts instead of a hardcoded list of fonts. Still certain fonts that are not possible to change via this method (like floating dmg numbers) but should cover more.
## Retail & Midnight
### Tweak
- Fix PetFrame's clickable area. (By default from Blizzard only clickable on Portrait instead of entire frame like everything else in the game)
## Classics
### Bugfix
- Fix issue with one localization key causing string.format to error and causing it not to load the gui.

# BetterBlizzFrames 1.8.5
## All versions
### New
- Localization support! Thank you so much to 007bb who has added localization support with English and Korean included. And some cleanup in some of the code.
## Retail & Midnight
### Tweak
- Fix No Portrait settings click area and edit mode selection highlight.
- Adjust threat glow on Classic Frames setting to fit the frame better, especially on Minus mobs.
- Tweak castbar positioning to not be affected by hidden auras when "Show Buffs/Debuffs" is disabled.
### Bugfix
- Fix health background for No Portrait setting being positioned wrong when targeting Minus mobs.
- Retail: Fix Target/Focus castbar flashing wrong texture and color at the end of a cast when interrupt color was enabled.
- Fix PlayerFrame's "Hide Resource/Power" setting sometimes causing lua errors for Brewmaster monk due to some old code that needed change due to Blizzard changes.
## Classic Era
### Bugfix
- Fix some castbar logic trying to adjust for FocusFrame (which doesnt exist on Era) causing a lua error.