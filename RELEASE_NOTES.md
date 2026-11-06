# BetterBlizzFrames 2.2.0g
## Retail & Forever
### New
- Misc, Actionbars: Change Art Size. Change the size of the gryphon action bar art.
- General: Hide Attack Icon. Hide the combat swords icon on PlayerFrame.
### Bugfix
- Potential fix for PlayerFrame mana text sometimes jumping onto the health text.
## Forever
### Tweak
- Many minor tweaks and bugfixes.
- Manabars now keep their default WoW Forever texture by default with No Portrait (not Pixel Border) and Classic Frames and Retail Textures. If you want this changed again theres a setting in Font & Textures to change manabar textures.
- Retail Textures setting now uses the healthbar retail crop version by default.
- Player name background setting now works with Retail Textures.

# BetterBlizzFrames 2.2.0f
## All versions
### New
- New "Snowfall Keypress" setting in misc that shows an animation on key press. Based on jButtonFlash by woldner which is based on SnowfallKeyPress.
## Retail
### Tweak
- Remove BagIcon from darkmode due to it being unique on Retail without a real border, all just one texture.
## Forever
### Tweak
- Tweak some classic frames number positions
- Fix "Hide XP Bar" showing each divider still.
- Add missing glow texture for big healthbar for pet frame
- Minor tweaks to lots of different settings to fix gaps and positions. If you notice stuff please let me know!

# BetterBlizzFrames 2.2.0e
## All versions
### New
- Add right-click option on "Use Spec Icon" portrait setting to only be active in PvP.
- Misc: Always hide statusbar texts (even when mouseover as that shows by default normally)
## Retail & Forever
### Tweak
- More general name, status text and level position tweaks. (If you have adjusted these with Move Names you might have to re-tweak them).
- Improve compatibility with other classic frames addons a bit, still not intended usecase this but if it works then sure.
- Update minus frames, text positions and look with big healthbars on.
### Bugfix
- Fix an issue with Big Healthbar settings causing player healthbar to shrink a little bit after respecs.
- Fix a combination of Classic Frames + PlayerFrame elite texture using the wrong texture.
- Fix some issues with name background texture and Classic Frames setting.
- Fix an issue with quick hide castbar setting causing a quick evoker channel into cast to sometimes hide the new cast castbar unintentionally.
## Forever
- New "Easy Darnassian" setting. Lets you speak Darnassian with /d hello (itll use whatever chat have selected, say yell etc). (for quick cross faction chat to other elves)

# BetterBlizzFrames 2.2.0d
## Retail & Forever
### New
- Castbars: Hide castbar finish effects. Remove the glows and stuff after a cast is completed on Player Castbar.
### Tweak
- Tweak lvl position a bit for classic frames n stuff.
- Retail: revert new role icons to how they looked before patch 2.2.0
- Allow custom code to move statusbar texts again.
### Bugfix
- Fix a secret error in new role icons etting
- Fix Hide XP/Honor bar not working properly
- Fix No Portrait Pixel Border healthbar being weird in vehicle.
- Purgeable enemy buff filter: Fix Shaman's Greater Purge not counting as a purge.

# BetterBlizzFrames 2.2.0c
## Retail & Forever
### Bugfix
- Fix No Portrait + Mini-FocusFrame causing pixel borders and text to still be showing.
- Fix a secret error (ty Wildu for report)
- Fix role icons being too small with the new role icons setting.

# BetterBlizzFrames 2.2.0
## Highlights
- Bigger update with many changes, especially for Forever. Here are some highlights:
- **Big Healthbars for every frame:** Player, Target, Focus, ToT, Party and Pet. Right-click for "Extra Large" and "Name Inside". (Retail & Forever)
- **Retail and Prepatch Textures:** Swap the Forever unit frames to the retail art or the bronze frames from the Forever prepatch. (Forever)
- **Party Level:** Show level on the default party frames. (Retail & Forever, optional on retail)
- **Name sizes:** Move Names now has a scale slider for every name, plus new Pet and Party rows. (All versions)
- **No Portrait: Pixel Border resizing:** Right-click No Portrait Pixel Border to set health and mana sizes per frame and the border size. (Retail & Forever)
- **Loss of Control Tweaks:** BetterBlizzCC has been revamped and updated for all versions of the game and now these settings are also included in BBF's new Loss of Control Tweaks settings. Second CC icon, interrupted school, icon only, text position, timer text and more. Right-click for settings. (All versions)

## All versions
### Important
- Lots of tweaks made to a lot of things, if you notice something strange please let me know and share your combination of settings as there are a lot to go over.
### New
- Move Names: "Scale" slider for every name.
- Move Names: "Pet" and "Party" rows. Moving the first party name moves them all.
- Misc: "Lower ToT Strata" setting. Puts the ToT frames behind most other frames.
- Misc: "Flip Portraits" setting. Target, Focus & ToT portraits get flipped and face left instead.
- Misc: "No Number Commas" setting. Shows 1300 instead of 1,300 on health and mana numbers. (Forever, Era & TBC)
### Bugfix
- Fix an issue causing right click popup windows to cover dropdown items that was on the popup.

## Retail & Forever
### New
- Big Player Healthbar reworked into Big Healthbars: Works on Target, Focus, ToT, Party and Pet too, also with No Portrait and Classic Frames. Can be picked which frames the setting is enabled on. Also has an extra large option for some frames and hide mana options too.
- Classic ToT: Gives the ToT frame a look closer to the old Classic one.
- Castbars: "Stop Castbar Shake" setting. Removes the shake from player castbar when your cast gets interrupted.
- Font & Texture: "Change Damage Meter Bar Texture" setting with a "Hide Bar Border" option.
- Font & Texture: Right-click "Change Castbar Texture" to pick an Uninterruptible texture.
- No Portrait Pixel Border: Right-click for health and mana sizes per frame and border size and also moving the default auras without aura settings on.
- Buffs & Debuffs: Right-click "Show Aura Timer Text" for timer and stack text settings: size, an optional own font and outline for each, plus "Only Mine" and "Timer Text Color" which moved there.
- Misc: "Swap StatusBar Texts" setting. Moves the health percentage to the right and current health to the left.
- Misc: "Hide Minimap Expansion Button" setting. Hides the minimap button for the current expansions gimmick.
### Tweak
- Hide Player, Target, Focus and Party Mana now work on the default frames and the healthbar grows into the mana spot.
- Hide ToT and Pet Mana have new frame textures.
- Classic Frames: Hide ToT Mana and Hide PetFrame Mana now work, also with HD Textures.
- "Blizzard CF" texture removed. Anyone using it now has it switched to use "Blizzard" instead. This was mainly used as a workaround for how the Classic Frames setting used to work before this patch.
- "One font for all text ingame" now also changes the aura timer and stack numbers.
- No Portrait: Stealth Indicator fits the borders better.
- Classic Frames: Elites now hide level and the level ring properly.
- Classic Frames & No Portrait: Minus mobs now show as a normal size frame.
- Hide Minimap Buttons now also hides the minimap expansion button.
- Purge texture: Enrage effects no longer get the purge texture unless you have a soothe ability, even with "Always show purge texture" on.
### Bugfix
- Fix role icon on classic frames being stretched across the frame.
- Classic Frames: Fix the Player Elite Frame ignoring Big Healthbar and Hide Lvl.
- Fix "Current HP Only & Center on Bars" not centering the value.
- Move Names: Fix "Multi-line" not working. (Thanks Wildu for detailed report and fix)
- Purgeable enemy buff filter: Fix issue with it showing purgeable buffs if you didnt have an enemy purge but had a friendly dispel, like Holy Pala for example.

## Forever
### New
- General: "Retail Textures" setting. Swaps the unit frames to the retail art. Its "Texture Options" dropdown has "Prepatch Textures" for the bronze prepatch frames and "Symmetrical PlayerFrame" to mirror the TargetFrame.
- Party Frames: Level ring and level on the portrait, like Player and Target.
- "Remove Name Border" setting. Removes the textures behind the names on the new blizzard unitframe textures.
- Target/Focus: "Name Bg Options" dropdown with "Retail Background Texture" and "Classic Background Texture".
- No Portrait: "WoW Forever Borders" option. THis is on by default on Forever so uncheck if you want back the other type.
- Misc: "Tweak Happiness" setting. Hide, resize or move the pet happiness icon, or make it a more simple icon.
- Misc: "Hide MicroMenu Border" setting. Hides the big border around the micro mneu.
- Misc: "Classic Style Combat Glow" setting. Swaps the combat glow on Player, Target and Focus for a thin outline like in Classic. Also works with No Portrait.
### Tweak
- "Classic Frames: Bronze Tint" is now "Extra Bronze Tints" and also works with Retail Textures and No Portrait.
- Party Frames: Improve Blizzards low resolution party frame texture and role icons.
- No Portrait: Changed some default sizes here due to all the new settings. You will have to tweak your settings.
- Class Color FrameTexture now also colors the level ring.
- Dark Mode: Now also darkens the minimap zone text, tracking and calendar buttons. Minimap and Objectives are on by default.
- "Mirror TargetFrame" and "Hide Shadow" moved into the Retail Textures "Texture Options" dropdown, as the new frames don't need them.
- Big Healthbars: Player, Target and Focus mana bar masks fit the frame better.
### Bugfix
- Class Color FrameTexture + Classic Frames: Target/Focus no longer stays gray on NPCs.

## Retail
### New
- Misc: "Show Party Level" setting. Level ring and level on the default party frame portraits. (an equivalent is always on for Forever)
- Misc: "Force Fit Player/Target/Focus Names" setting. Shrinks long names so they fit instead of getting cut off. When possible.
- Adjust PRD: "Show on PRD with no target nameplate" option under "Show resource on target nameplate".
- New Varima profile (www.twitch.tv/varima_). Thank you for sharing!
### Tweak
- New Role Icons: Works again, uses the newer icons and now also replaces the party frame role icons.
- Dark Mode: Now also darkens castbar text borders, the breath bar, the micro menu and bag slots.
- Dark Mode: Player Elite Frame now follows "Dark Mode Elite Texture".
### Bugfix
- Fix "Hide Mana Feedback" sometimes showing the animation again.
- Fix ToT arena names showing "Arena 1" instead of the spec name, and sometimes the wrong arena number.