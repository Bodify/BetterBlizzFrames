# BetterBlizzFrames 1.9.4d
## Titan Reforged
- Change Titan Reforged to load TBC files instead as a temporary solution because of new API changes. Very difficult for me to do any testing here so please report any errors with BugSack and BugGrabber.

# BetterBlizzFrames 1.9.4c
## The Burning Crusade
### Tweak
- Tweak Castbar Spark Heights to better fit castbars.
## Classic Era
### Tweak
- Add missing reputation bar to dark mode. By Shadeqt@GitHub
- Add bag icons to OCD Tweak's icon zoom. By Shadeqt@GitHub
### Bugfix
- Fix castbar icon border from darkmode showing without icon enabled. By Shadeqt@GitHub
- Fix capitalization mistake in some pet castbar settings. By Shadeqt@GitHub

# BetterBlizzFrames 1.9.4b
## All versions
- Add French localization by Timikana@GitHub. Thank you!
## Midnight
### Tweak
- Fix "Fix ActionBar Cooldowns in CC" setting in Misc for Midnight.
- Fix Nameplate/PRD instant combo points setting.
- Add ExtraActionButton1 to hide hotkey setting.
### Bugfix
- Fix actionbar font change not applying of first time login.
## Classic Era
### Tweak
- Thanks to Shadeqt@GitHub for all of these tweaks below.
- Add MinimapBorderTop to minimap darkmode (was not being darkened)
- Add dark borders to pet buff icons (PetFrameBuff1-16) with UNIT_AURA event hook for dynamic updates
- Add dark borders around castbar spell icons (target, player, party, pet) with proper lifecycle (created on enable, cleaned up on disable, matching aura border pattern)
- OCD icon zoom fix for pet and stance buttons
- Fix Hide Combat Glow for PetFrame