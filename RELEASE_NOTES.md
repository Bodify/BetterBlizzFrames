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