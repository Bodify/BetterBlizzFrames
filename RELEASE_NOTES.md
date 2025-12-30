# BetterBlizzFrames 1.8.6e
## The Burning Crusade
### Tweak
- Remove Thorns from PvP Buffs whitelist import.

# BetterBlizzFrames 1.8.6d
## The Burning Crusade
### Tweak
- Fix Queue Timer window size.

# BetterBlizzFrames 1.8.6c
## The Burning Crusade
### Tweak
- Loss of Control feature now adjusted for TBC. Might still need more tweaks please let me know.
- Some more spell ids adjusted around in the addon.
## Mists of Pandaria
### Bugfix
- Fix darkmode for default party frames causing lua error due to PartyFrame being different in MoP and TBC.
## All versions
### Tweak
- Add back code to force certain nameplate font sizes for "Change all fonts" setting to hopefully avoid some users having massive nameplate names.
- Retail & Midnight: "Hide PlayerFrame 2nd Resource" (Misc) now works with Classic Frames setting enabled as well.

# BetterBlizzFrames 1.8.6b
## The Burning Crusade
### Tweak
- Hide default PlayerFrame Background when BBF Background Texture is enabled and tweak its position slighly.

# BetterBlizzFrames 1.8.6
## The Burning Crusade
- Early and scuffed TBC support. Aka made the addon launch and fixed the obvious things that presented itself while standing still after login. Anything else is experimental so use at own risk.
## All versions
### Tweak
- Update the "One font for all text ingame" setting to use proper API to get all fonts instead of a hardcoded list of fonts. Still certain fonts that are not possible to change via this method (like floating dmg numbers) but should cover more.
- Fix some localization issues.
## Retail & Midnight
### Tweak
- Tweak target of target debuffs positions for No Portrait settings.
- Midnight: Tweak darkmode aura border position and fix pixel border being set on debuffs without that setting being enabled.
## Classics
### Bugfix
- Fix missing "Focus ToT" text in gui on MoP

# BetterBlizzFrames 1.8.5b
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