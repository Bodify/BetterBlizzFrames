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