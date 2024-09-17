# BetterBlizzFrames 1.5.4b
## The War Within
### Tweak:
- Typing in aura lists input field now searches in the list as well.
- Added more auras to the pvp preset for aura blacklist and whitelist.
- PSA: These presets can be found in the Import/Export section.
### Bugfix:
- Fix "Hide TotemFrame" setting.

# BetterBlizzFrames 1.5.4
## The War Within
### New stuff:
- You can now set a keybind to toggle all filters on/off to view all unfiltered auras momentarily. Or macro `/run BBF.ToggleFilterOverride()`
- Queue Timer: Display the amount of time you have to accept PvP and PvE queues ala SafeQueue.
- Misc: Minimize Objective Frame Better: Hides the objectives header as well when clicking the minimize button. (on by default)
- Misc: Surrender over Leave: Makes typing /afk in arena Surrender instead of Leaving so you don't lose honor/conquest gain.
- You can now "merge" aura list imports with your current list instead of chosing one or the other. Only new auras will be added doing this and you will not lose your settings on the current auras.
- Show Druid Overcharge charges on PlayerFrame combo points.
### Tweak:
- Nahj profile update
- Smokebomb timer on Player Debuffs now works without Player Debuff filtering on.
- Large restructure of aura lists that should both be cleaner and have better performance.
- Absorb Indicator now says millions instead of thousands. 7300k -> 7.3m
- General performance tweaks
### Bugfix:
- Fix default purge glow not scaling properly with enlarged/compacted auras
- Added missing smokebomb spell id to player debuffs for timer
- Fix issue with BBF Filter Icon potentially saving bad position data and causing lua error on next reload/login.
- Fix rare issue causing checkbox settings not to save for some people.
- Added some missing stop casting events to the Castbar Quick Hide setting.

# BetterBlizzFrames 1.5.3c
## The War Within
### Tweak:
- Adapt "Hide reputation color" and "Hide rest glow" settings to work with ClassicFrames addon.
- Pandemic timer for Agony and Unstable Affliction is now 10s and 8s instead of the regular 5s if the talents are learned.
### Bugfix:
- Added a missing second Smoke Bomb spell id for displaying Smoke Bomb CD.
- Pandemic Glow should now properly hide darkmode border during its activation

# BetterBlizzFrames 1.5.3b
## The War Within & Cataclysm
### New stuff:
- Buffs & Debuffs: Ctrl+Alt Rightclick to blacklist aura with "Show Mine" tag already added.
### Bugfix:
- Fixed new blacklist setting "allow mine" accidentally missing the castByPlayer check.

## The War Within
### New stuff:
- New setting "Quick Hide Castbars": Hide target/focus castbars immediately when cast is finished.
### Bugfix:
- Hide level 80 text now definitely hides level 80 text.
- Fixed Player Aura Filtering making player auras go downwards regardless of settings. Also fixed debuffs in the same go. I mustve been sleep deprived.
- Fixed Party Castbars showing self castbar despite not set to.

# BetterBlizzFrames 1.5.3
## The War Within & Cataclysm
### New stuff:
- Added cooldown timer to Smoke Bomb debuffs to show the duration of Smoke Bomb. Buffs & Debuffs settings need to be on for this to be active.
- Add "Show Mine" checkbox for blacklisted auras.
- Add "Mount" filter for auras. (Needs testing, if you use this and see a mount NOT show up please lmk)

## The War Within
### Bugfix:
- Fix darkmode causing some errors on evoker class.

### Known issue:
- Buff filtering + Collapsed BuffFrame is not supported and will cause issues with positioning of buffs etc. Added a message in chat to mention this and I am working on it.

# BetterBlizzFrames 1.5.2b
## The War Within & Cata
### New stuff:
- Buffs & Debuffs: The filtered buffs icon is now moveable with ctrl+leftclick and you can also change which direction the hidden auras grow.
- Buffs & Debuffs: New setting to hide the duration text on Buff/Debuff cooldown spiral.

## The War Within
### Bugfix:
- Fix player buff filter lua erroring with the 1 min filter due to an oopsie.
- Fix Target & Focus "Only Mine" filters conflicting with "Under 1 Min" filters and causing it to show auras longer than 1min.
- Fix issue with SUI + Masque causing Duration text on player auras to be hidden (again >.<)

# BetterBlizzFrames 1.5.2
## The War Within & Cataclysm
### New stuff:
- Buffs & Debufs: Add cooldown spiral to Player Auras settings.
- Slash Command: You can now also add auras to aura whitelist/blacklist by typing /bbf whitelist/blacklist spellId/spellname. For example /bbf blacklist 113 or /bbf whitelist agony. Can also be shortened to wl/bl.

## The War Within
### Tweak:
- Updated Nahj & Magnusz profiles.
- Hide level 70 text is now Hide level 80 text.
- Dark Mode: Added XP & Honor bar. Added some missing actionbar separators. Fixed soulshards not always being colored.
- Buffs & Debuffs: The duration of Player Auras are now correctly layered above the Important Glow making it more readable.
### Bugfix:
- Fix "Hide party frames" setting not hiding the border around the healthbars.
- Fix missing support for Player Auras stacking left to right and bottom to top with filtering on.
- Fix friendly npcs target of target frames having a white healthbar when used together with the ClassicFrames addon and "Class color frames" setting.

## Cataclysm
### New stuff:
- Class Portraits setting.

## Shoutout
- Shoutout to small-time streamer sodapoppin for trying out the addon.

# BetterBlizzFrames 1.5.1b
## The War Within
### New stuff:
- Recolor Temp Max HP Loss (Player, Target, Focus, Party) to transparent red. (Misc section)
### Tweak:
- Add Ace3 tooltips to DarkMode: Tooltip

# BetterBlizzFrames 1.5.1
## The War Within & Cata
### New stuff:
- Custom Code: Added a section for custom code that runs at login. Made for smaller custom scripts that don't really fit the addon.
- Buffs & Debuffs: "Same Size" setting that makes all auras on target/focus frame the same size. (By default yours are a little bigger)
- Buffs & Debuffs: "Aura Stack Size" setting that lets you re-size the stack text on auras.
### Bugfix:
- Fix SUI + Masque causing Player aura durations to be hidden due to SUI moving them up and Masque overlaying it.

## The War Within
### Tweak:
- Dark Mode Objectives: Add the objective header from the addon "World Quest Tracker".

# BetterBlizzFrames 1.5.0c
## The War Within
### New stuff:
- "Hide Dragon" setting for Target & FocusFrame.
- "Dark Mode: Vigor" setting is now optional, on by default.
### Bugfix:
- Fix Vigor sometimes not being colored due to the frame not existing yet.

## Cata
### Tweak:
- OCD Tweak: Increased Hotkey text width slightly to allow some longer keybind text like it used to be before Blizzard messed up.
- OCD Tweak: Re-apply hotkey text width after instancing because of resets.

# BetterBlizzFrames 1.5.0b
## The War Within
### Bugfix:
- Fixed Target/Focus Castbar Icon reposition tweak meant only for ClassicFrames users being active for all.
- Fix party castbars sometimes showing when no party frame is displayed due to shitty blizzard api.

# BetterBlizzFrames 1.5.0
## The War Within
### New stuff:
- Misc: Hide UI Error Frame setting (Red text: "Not enough mana" etc)
- Dark Mode: Added Dark Mode settings for Game Tooltip, Objective Frame & Vigor
### Bugfix:
- Fix some issues with Party Castbars.
- Fixed an issue on first install where it was not able to get Player Castbar Scale and resulting in an error and causing mischief.
### Tweak:
- Adjusted default position of Target/Focus Castbar Icon when ClassicFrames is enabled. If you are using ClassicFrames you might have to tweak the position because of this.
- Skip moving Target/Focus castbar text when ClassicFrames is enabled so they look like ClassicFrames intend.

## Cata
### Bugfix:
- Fixed an issue where the arena minimap hide setting could cause Lua errors in Cataclysm due to attempts to show or hide the minimap while in combat, specifically when entering or leaving the arena during combat.

# BetterBlizzFrames 1.4.9
## The War Within & Cata
### New:
- You can now choose to skip coloring the PlayerFrame healthbar with "Skip self" next to "Class Color Frames".

## The War Within
### New:
- Class coloring now works with Classic Frames.
- Reputation color also works with Classic Frames.
### Bugfix:
- Updated Interrupt icon function to TWW.

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