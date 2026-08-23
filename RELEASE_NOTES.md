# BetterBlizzFrames 2.0.6b
## Midnight
### Tweak
- Update Jazggz profile (www.twitch.tv/jazggz). Thank you for sharing!
- Update Dissonance profile (www.twitch.tv/dissonancewow). Thank you for sharing!
### Bugfix
- Fix an issue causing the purgeable border on auras on the new aura settings to get stuck hidden

# BetterBlizzFrames 2.0.6
## Midnight
### New
- Every filter setting for Target/FocusFrame now has a "Friendly/Enemy" toggle box. So you can for example show only your buffs on Friendly Targets but all buffs on Enemy Targets.
- New "Dispellable" filter for debuffs on Target/Focus. 
- New Ceit profile (www.twitch.tv/ceitxd). Thank you for sharing!
### Tweak
- Finally fix "Mirror TargetFrame" setting for Midnight. Makes the Player Portrait round; a mirrored version of TargetFrame.
- Add a tiny crop on spec icons for spec icon portraits setting (to hide borders sticking out)
- Tiny tweak to ocd setting and level position.
### Bugfix
- Fix "Purgeable" filter to not rely on whether you can dispel or not but just the nature of the buff if its dispellable or not.
- Fix castbars flashing white on some castbar color settings at the end of cast.
- Fix a spacing issue between Target/FocusFrame and auras with aura settings enabled and some specific filters.
- Fix an issue with glows on auras not showing on friendly units.

# BetterBlizzFrames 2.0.5
## New
- New Kaaaz profile (www.twitch.tv/KaaazTTV). Thank you for sharing!
- New "Hide purge texture" setting
- New "Show purge texture on friendly too" setting.
## Tweak
- Update Venruki profile (www.twitch.tv/venruki).
- Fix the purge texture showing on friendly buffs unintentionally. Its now an optional setting instead.
- Fix "Only mine" filters for Buffs and Debuffs for Target/FocusFrame applying where it doesnt make sense; "Only mine" on Enemy Buffs for example. "Only mine" is now only active for friendly buffs and enemy debuffs.
- Filtered Buffs Icon now also gets disabled if "Show Buffs" is not enabled.
- Filtered Buffs Icon now properly also gets Pixel Border if thats enabled (not only when dark mode is also enabled)
## Bugfix
- Fix "Hide Boss Frames" causing errors.
- Fix an issue with blacklist + "Show Mine" tag filtering the buff anyway.
- Fix "Big Debuffs" setting showing too many debuffs on friendly units due to a mistake in the filter.

# BetterBlizzFrames 2.0.4
## New
- "Enlarged Aura" is back as an option in the whitelist for Target & Focus. Can be combined with Important Glow for a separate (or same) color to the Important one. Scale it with "Enlarged Aura Scale" and sort the enlarged block first or last with "Sort Enlarged First". Player auras keep their Edit Mode size but still glow and sort with the block. Your old whitelist ticks and Enlarged Aura Scale carry over.
- The "Important Glow" setting is back for whitelisted auras. Reminder that this only works for debuffs on enemies and buffs on friendlies.
- New "Important" and "Defensives" filters under Show BUFFS and "Crowd Control" under Show DEBUFFS on Target, Focus and Player auras. Use them if you want a frame to show nothing but those auras. "Important Auras First" is still there and only moves them up front and scales them up. Unlike the whitelist/blacklist these work on every unit.
- "Max Buffs" and "Max Debuffs" are back under Target & Focus Aura Settings but they are scuffed for now. Tldr is it cannot get properly fixed until new Blizzard API in 12.1.5.
## Tweak
- ENABLED: When Dark Mode is enabled the "DarkMode: Nameplate Resource" is now on by default as well. Due to this change it mightve turned on for you but can still be turned off under Dark Mode top left in /bbf.
- Fix whitelisted auras not sorting before others as intended (even without whitelist filter enabled).
- Aura glow settings are no longer locked behind "Important Auras First", the matching filter on that frame enables them too.
- "Under one min", "Only mine" and "Purgeable" now only narrow the normal auras and no longer hide important/defensive/crowd control auras.
- Add EllesmereUI partyframe support for party castbars.
## Bugfix
- Fix a potential lua error from hiding/showing minimap buttons in combat with that setting.
- Fix dark mode color for nameplate/PRD resource setting.
- Fix potential issue with TargetFrame combo points setting that could sometimes not update properly on certain events.
- Fix "Dead/Unconcious" text layer on ToT Frame for Classic Frames setting after recent changes.