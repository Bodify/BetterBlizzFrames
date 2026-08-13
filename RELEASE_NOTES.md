# BetterBlizzFrames 2.0.2d
## Midnight
### Bugfix
- Remove some debug prints left in by accident

# BetterBlizzFrames 2.0.2c
## Midnight
### Tweak
- REMOVED: Party Frame scale is removed cuz edit mode now has settings for it. Set it with edit mode instead.
- Tweak castbar position values a bit (so theyre identical to default by default). You might have to tweak your values a bit again if you notice this (apologies).
- Move "Raise Castbar Strata" setting into castbar section from Misc.
- Tweak some layer issues between tot frames, classic frames, and castbars.
### Bugfix
- Fix "Raise Castbar Strata" setting not working properly.
- Fix "modern role icons" setting causing new secret errors in 12.1
- Fix color error when BBP's npc colors was enabled.
- Fix new 12.1 aura layer issues.
- Fix Class Color replacement "One Color for All" setting not working after I disabled the custom coloring, this can still function ofc.
- Fix Friendlist Class Colors setting.
## All versions
### Tweak
- Fix some locale key mistakes from a while back causing wrong text here n there.

# BetterBlizzFrames 2.0.2b
## Midnight
### New
- Add new setting to separate aura row width between Target/Focus (ill add more of these split settings later prob)
### Tweak
- "Remove Debuff Color Border" now works on Player auras as well, and with Dark Mode: Auras or Pixel Border Auras enabled debuffs get that same border instead of nothing, matching the look of buffs.
- Clean blacklist & whitelist from old named entries (not spell ids) and disallow name entry.
- Force player aura spacing "Horizontal Padding" to the default value of 5 because I made an oopsie here. If you had changed this you will have to tweak it again :x
- Update Saul profile (www.twitch.tv/saul)
- Improve No Portrait: Pixel Border.
- Fix auras not being scaled with the Target/FocusFrame like how default auras are.
### Bugfix
- Fix secret errors in custom class colors. Custom class colors are dead I think though :/
- Fix issues with No Portrait: Pixel Border
- Fix issues with castbar positioning for Target/FocusFrame.
- Fix Highlighted Auras Scale not saving its value after reload.
- Fix Remove Debuff Color Border for auras not applying a dark border

# BetterBlizzFrames 2.0.2
## Midnight
### New
- Aura settings has been completely remade with the new 12.1 API. Filters, Sorting, Glows, etc. You will have to re-do your aura settings.
### Tweak
- Tons of things to make things work on 12.1. Too many to mention x.x
- Make UnitFrame castbar texture setting affect party castbars.
### Bugfix
- Fix TRP3 names being active on npcs and causing some issues.
### Notes
- I want to thank Verz and Muleyo for helping me understand some of the new 12.1 API with examples and stuff. Thank you<3
- Please report any issues as always.
## All versions
### New
- Target Text setting now has right click options to move the text ouside of the castbar and also to hide it for npcs.
## Classics
### New
### Bugfix
- For Wrath enable the same unified classic version of the addon as Wrath still loaded older version files.
- Fix texture unitframe healthbar, manabar & castbar not affecting the default party frames.