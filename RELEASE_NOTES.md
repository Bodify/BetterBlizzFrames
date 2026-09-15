# BetterBlizzFrames 2.0.8b
## All versions
- New settings in Misc section for BBF's GUI to Force English Language and change Font and Font Size for the GUI.
- Existing translations for other languages have been updated and new translations for all other languages have been added.
- Known issue with translations: Some languages will need some tweaks and especially tweaks to lenght of strings and overlapping. If theres a lot of issues probably use the new "Force English" setting in Misc for now.
## Midnight
### Bugfix
- Fix attempt for class colors sometimes being stale on Target/Focus/ToT frames after changes from last patch 2.0.8

# BetterBlizzFrames 2.0.8
## Highlights (Retail)
- Hunter & Shaman combo points for Tip the spear and Mealstrom buff.
- Hide Pet/ToT Mana now supporting default frames and stretches the healthbar bigger.
- Druid blue overcharges combos back.
![bbfShamanCombos](https://github.com/user-attachments/assets/f4b0d017-6394-4211-bd70-a668ab5bd8a0)
![bbfHideToTManas](https://github.com/user-attachments/assets/abbbcdee-9ab4-4a52-aba4-c3c095f41f10)
## Midnight
### New
- Misc: "Shaman: Mealstrom Weapon Combo Points". Enhancement now gets a Rogue-style combo point bar for Maelstrom Weapon stacks on PlayerFrame and PRD/Target Nameplate.
- Misc: "Hunter: Tip of the Spear Combo Points". Survival now gets a Rogue-style combo point bar for Tip of the Spear stacks on PlayerFrame and PRD/Target Nameplate.
- New Hide PetFrame Mana setting that also makes the healthbar bigger (Misc).
- New Hide ToT Frame Mana setting that also makes the healthbar bigger (Misc).
### Tweak
- Druid Blue Combopoints are back (Feral's Overflowing Power from Berserk/Incarn showing blue combo points). This has always been on by default but since theyve been out of commission for a hot minute it might surprise you with them being back on.
- Custom Health Color and Class Color Overrides are back, kind of. They work on friendly units and enemies in arena specifically, otherwise it defaults to normal class colors.
- Tweak all cooldown frames to make sure they properly display the cooldown text on very short durations as well.
- Tweak mask on PetFrame when using No Portrait to avoid health/mana bleeding outside of border.
- Misc section has now been organized a little bit in the GUI.
### Bugfix
- Fix a Blizzard bug with Rogue combo points not being centered on the Personal Resource Display when talented into 6 or 7 combo points. BetterBlizzPlates already had this but now BetterBlizzFrames does too.
- Fix a Blizzard bug causing breath bar (and other similar bars) to stay hidden after opening Edit Mode. Blizzard hides this bar when opening Edit Mode and they never re-show it... GG.
- Fix an issue with manabar text hidden + no portrait settings causing it to show again after reload/loading screens.
- Fix an issue with OCD Tweaks combined with no portrait causing some weirdness with the frames.
- ToT Offset (Castbar settings) while the new 12.1 aura settings are enabled works again. Thanks to Hatsu @ Discord for suggestion and proof of concept.
## All versions
### New
- Quick Hide Castbars: New right click option to always hide the castbar instantly, also when the cast was successfully interrupted (normally the castbar is kept up in that case to show the interrupt).
### Bugfix
- Fix "Move Resource" settings unchecking itself due to a mistake in the class specific settings for it.
## Classic Era
### New
- New Color Shamans Blue setting (Misc). Colors Shamans their blue color. On Era and only Era they are the same pink as paladin, this setting avoids that. Enabled by default, uncheck it to keep the pink Blizzard color.