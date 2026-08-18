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