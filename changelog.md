# BetterBlizzFrames 1.4.8e
## The War Within't (Prepatch)
### New:
- Added aura settings to enable enlarged auras depending on friendly/enemy target/focus for retail as well (was already on cata).
### Tweaks:
- Made it so if the addon Classic Frames is enabled the un-interruptible shield around castbars don't get moved.

# BetterBlizzFrames 1.4.8d
## The War Within't (Prepatch)
- Fix target/focus frame dark mode aura borders and re-enabled them.
- Fix the fix for ObjectiveFrame not hiding properly. Delay was not enough as Blizzard now calls to show this frame all the time. Put a hook on it so now it works.

# BetterBlizzFrames 1.4.8c
## The War Within't (Prepatch)
- Fix Interrupt Icon setting due to Blizzard function now returning true/false instead of 1/0
- Tweak default Interrupt Icon position and reset y offset due to this.
- Add a slight delay to fix hiding objective frame etc when entering arena.

# BetterBlizzFrames 1.4.8b
## The War Within't (Prepatch)
- Added "Normal Size Game Menu" setting in Misc section. We're old boomers but we're not that old jesus.
- Fix "Center Names" setting not displaying name due to naming mistake after blizzard switchup.

# BetterBlizzFrames 1.4.8
## The War Within
- Updated to support TWW. Might some things I've missed that needs a quick rename fix. Please report errors.

# BetterBlizzFrames 1.4.7b:
## Retail
### Bugfix:
- Fixed Masque support for Player Castbar not properly adjusting
- Fixed Player Castbar settings resetting on some loading screens.

## Cata
### Tweak:
- OCD Tweaks: Fixed a Blizzard issue where on smaller resolutions (1080p and below?) combined with a small UI Scale would truncate all hotkey text on actionbars even though it is not needed.
- Removed Pet Actionbar fix as it has been fixed by Blizzard.
### Bugfix:
- Fix Masque support timing issue causing it not to be detected on login.
- Fix "Hide Objective Tracker" setting using retail name for frame accidentally.

# BetterBlizzFrames 1.4.7:
## Retail & Cata
### New stuff:
- Added Masque support for castbar icons.
### Tweaks:
- Misc: The "hide during arena" settings are no longer tied to the minimap setting.
### Bugfixes:
- Fix Interrupt Icon Size, x offset & y offset sliders (i forgor :x)
- Fix castbar spell names not being capped at max castbar width.

## Cata
### Tweak:
- OCD Tweak: Made it toggleable and improved icon zoom. Icon zoom is now optional (on by default). Toggle icon zoom on/off with right click.

## Retail
### Bugfix:
- Fix some aura stuff not scaling properly with Masque enabled for them

# BetterBlizzFrames 1.4.6f:
## Cata
### New Stuff:
- Combat Indicator: `Assume Pala Combat` setting. (Combat status while Guardian is out is bugged, crude workaround)

# BetterBlizzFrames 1.4.6e
## Cata
### New stuff:
- Pet ActionBar fix setting (blizz bug) in Misc section.
### Tweaks:
- More mini adjustments to OCD Tweaks. Yes I have a problem.

# BetterBlizzFrames 1.4.6d
## Cata
### Tweaks:
- Added Reputation XP Bar to OCD Tweaks & Darkmode

# BetterBlizzFrames 1.4.6c
## Cata
### Tweaks:
- Castbar hide border setting now also hides the "flash" border at end of a cast.
- Made sure absorb bar setting doesnt try to change frame level in combat to avoid lua error

# BetterBlizzFrames 1.4.6b
## Cata
### New stuff:
- Castbar hide text & border settings.

# BetterBlizzFrames 1.4.6
## Retail & Cata
### New stuff:
- Castbar Interrupt Icon setting in Castbars section.
### Bugfixes:
- Fix some castbar positioning issues with the "Buffs on Top: Castbar Reverse Movement" setting.

## Cata
### New stuff:
- Party Castbars: Hide borders setting
### Bugfixes:
- Fix castbar reverse movement with buffs on top
- Fixed some default castbar movement issues (No buff filtering enabled)
- Fix aura positioning when stacking upwards with buffs on top
- Make OCD setting skip actionbar stuff if bartender is enabled to avoid error
- 1 pixel adjustment to actionbar art in "OCD Tweaks" setting, true to its name.



1.4.5b:
- Cata
- Remove ToT adjustment cuz errors, need more testing


### BetterBlizzFrames 1.4.5

#### Retail & Cata:
- **Masque**: Split the single Aura category into Buffs & Debuffs.

#### Cata:
**New Features:**
- Added the **OCD Tweaks** setting for Cata.
- Added **Hide MultiGroupFrame** setting for the PlayerFrame.
- Properly updated **dark mode** for default action bars in Cata.

**Bugfixes & Tweaks:**
- Updated **Overshields** with more updates for better accuracy on damage taken.
- Fixed an issue where the **name background** would reappear when the hide setting was on.
- Fixed an issue where the **player name** could move out of position.
- Fixed **Arena Names** to rely on Details for spec names, because of the absence of the Blizzard function in Cata.
- Adjusted **Party Castbar borders** to account for height changes.

#### Retail:
**Bugfixes & Tweaks:**
- **Castbars** will no longer reset to white after being re-colored if **ClassicFrames** is on, allowing the classic castbars to maintain their intended appearance.
- The **Masque border on auras** falling under the "Other auras" category now scales correctly if the scale has been adjusted.

1.4.4:
Retail & Cata:
New stuff:
- Masque support for Player, Target & Focus Auras.
- Buffs & Debuffs: Increase Frame Strata setting.

Cata:
Bugfixes:
- Fixed Player Debuff filtering
- Fixed "Hide pet statusbar text"

Retail:
Bugfixes & Tweaks:
- Target & Focus names shortened a little bit to make it not overlap frame
- Fix layering issue with "Combo Points on TargetFrame" settings.


1.4.3:
Cata:
New stuff:
- Added scale sliders for Player, Target and Focus frames.
- Added "Name inside" option for bigger healthbars setting.

Bugfixes & Tweaks:
- Changed default TargetToT and FocusToT positions to be identical to default Cataclysm values (had retail values). Had to reset values because of this.
- Fixed darkmode not applying to focus tot
- Fixed hide aggro highlight setting to work with the multiple types of raid/party frames.

Retail:
- Shortened ToT name so it does not go outside of the frame texture.

Cataclysm 1.4.1e:
- Fixed logic with target/focus auras messing up with eachother after port from retail to cata.
- Fixed Name Bg setting on Player to only be the actual size of the name bg so color behind hp/mana doesnt get changed
- Fixed Player name to be above Leatrix Plus' version of Name Bg.