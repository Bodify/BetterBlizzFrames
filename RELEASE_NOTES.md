# BetterBlizzFrames 1.8.4d
## Retail & Midnight
### Tweak
- Fixup OCD Tweaks a little due to new secret values.
### Bugfix
- Classic Frames: Fix error on aug evoker due to a missing value.

# BetterBlizzFrames 1.8.4c
## Retail & Midnight
### Tweaks
- Custom Health/Mana Colors now works for transparancy as well like intended.
- Some settings extended to BossFrames, with more to come later. In this go: Darkmode, Hide reputation color (will trigger if either Target/Focus is selected), "Hide Threat" and "Hide Combat Glow".
- Opening settings in combat no longer possible, even when already loaded (due to restrictions/bug on Beta). Now avoids error by waiting and settings will instead wait for combat drop to open.
- Add a variable that lets you skip "No Portrait" setting on Target and/or Player. To enable do "/run BetterBlizzFramesDB.noPortraitSkipTarget" (or SkipPlayer)
### Bugfix
- Midnight: Fix lua error caused by "Hide Minimap Buttons" (when mousing over to show).
- Fix Classic Frames setting in combination with hide level still showing level and wrong glow texture on some types of npcs.

# BetterBlizzFrames 1.8.4b
## Mists of Pandaria
### Bugfix
- Fix missing parentheses on function call causing addon to not load properly.

# BetterBlizzFrames 1.8.4
## GitHub
- With this version and forward my addons will also have GitHub releases. Huge thanks to zerbiniandrea for the pull request with everything set up for me to get quicky started with this.
## Retail & Midnight
### New
- New "Class Color Friendlist" setting (Misc)
- New "Pixel Border" setting for CompactPartyFrames. Makes things a bit cleaner than Blizzard default. (This setting also auto toggles on Hide RaidFrame Background and Background Texture Change)
- "New Role Icons" setting for raidstyle partyframes that replaces the role icons with the more modern ones from the game. (General, PartyFrames)
- New setting to hide the background texture on RaidFrames (Misc)
- New "Hide All Absorb Glow" setting that hides the Absorb glow usually resting at full health on all frames (Misc)
- The raidframe and unitframe background color setting now lets you change texture as well. (Font & Textures / Custom Colors in General)
### Bugfix
- Hide BossFrames setting potentially fixed with new workaround.
- Fix Classic Frames setting not applying correct texture set to target/focus. Midnight secrets related issue.
- Fix No Portrait settings causing a lua error on combat drop due to a mistake. (Also tweak them to hopefully be more reliable, Thank you to Verz for helping with this)
- Fix "UnitFrame Background Color" setting not being able to change color of healthbars (not party ones).
### Tweak
- CompactParty-PetFrames now also get background color.
- Fix Resto Druid specific setting causing manabar to be shown while in Cat/Bear when selected to hide mana.
## All versions
### New
- New "Zoom ActionBar Icons" setting that crops the icon textures a bit on default action bars.
- Add a new setting to disable all castbar movement from BBF. Not recommended but useful for those who might have conflicting addons without options to turn it off there. This WILL make the castbar act weird if you have aura settings enabled (and no other addon to deal with it). Again; Not recommended.
### Tweak
- "Change UnitFrame Font" now also changes the font of the Player/Target/Focus castbar.