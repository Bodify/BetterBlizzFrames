# BetterBlizzFrames 1.9.5c
## Midnight
### Bugfix
- Fix a mistake in interrupt popup causing it to popup on abilities player was channeling and stopped.

# BetterBlizzFrames 1.9.5b
## Midnight
### Bugfix
- Fix a mistake in interrupt popup causing a lua error.

# BetterBlizzFrames 1.9.5
## Midnight
### New
- New setting for ChatFrame: Hide background (and tabs). Shows tabs on mouseover.
- "Zoom ActionBars" setting now also work for Dominos bars.
### Tweak
- Add more missed tooltips for the darkmode tooltip setting.
- "Quick Hide Castbars" setting no longer insta hides channel casts due to a combination of API restrictions and 20+ year old Blizzard bug making it so I cannot keep an interrupted channel castbar visible after kicking it.
- Hook Duration text on BuffFrame's aura with dark mode enabled due to Duration text changing position from Blizzard updates.
- "Class Color FrameTexture" setting now also works on the "Mini-PlayerFrame" etc settings.
- OCD Tweaks now also fixes duration text on player buffs/debuffs going up into the border after Blizzard decided that was a great idea.
### Bugfix
- Fix Kick Popup not working when kicking channeled casts due to a 20+ year old Blizzard bug (i forgot).
- Fix purge texture size on auras when the scale has been adjusted.
- Fix parts of OCD Tweaks setting being unintentionally active when No Portrait was enabled causing it to look weird and other glitches.
- Fix tooltip locale mistake on "Move Resource".
## Classic Era
### Tweak
- Add missing castbar icon X/Y offset sliders for player and pet. By Shadeqt@GitHub
- Improve darkmode setting for CompactPartyFrameMembers borders. By Shadeqt@GitHub
### Bugfix
- Fix many inconsistencies and some wrong values with castbar settings on Era. By Shadeqt@GitHub