# BetterBlizzFrames 2.1.4
## Forever
### New
- Misc: "Bronze Tint Options" dropdown next to "Classic Frames: Bronze Tint". Choose which elements get the bronze tint: Player/Target/Focus/PartyFrame, Castbars and Minimap (all on by default).
### Tweak
- BetterBlizzFrames now enables Blizzards threat meter on TargetFrame by default. I feel this is relevant for Forever and "Hide Threat Meter" is still a setting in BBF and now also with a new "Keep it shown while Tank specced" setting.
- Classic Frames: Bronze Tint now takes priority over Dark Mode on the elements it's enabled for.
- Classic Frames: Bronze Tint now also tints the borders of alternate power bars the Target/Focus threat display and the Classic Breath/Status Bars.
- Classic Frames: Bronze Tint now also works on Classic Castbars without needing Classic Frames enabled.
- Dark Mode now also darkens the PvP circle background.
- Center Names: Adjust name width and position on Player/Target/Focus to fit WoW Forever better.
- Tweak "Mirror TargetFrame" setting so it doesnt hide the level circle on WoW Forever and positions levels properly.
- Update the Forever profile.
### Bugfix
- Fix combo points not updating their color until reload when toggling Bronze Tint.
- Fix Stealth Indicator error after the latest WoW Forever patch.
- Fix Smaller Level Circle position with Symmetric PlayerFrame.
## Retail & Forever
### New
- Minimap Tweaks: "Hide Minimap Title" setting.
- Hide Threat Meter: Right-click to keep it shown while Tank specced (on by default).
- Legacy Combo Points: "Only Show Active Combo Points" setting. Only shows a combo point and its background while you actually have it, instead of always showing every background.
### Tweak
- Legacy Combo Points: Blue Combos, Show Always, More Classes and Class Color moved into the right-click window together with the position sliders.
- Improve Quest Indicator (was missing detection on some quests).
### Bugfix
- Fix Legacy Combo Points "Show Always" not working for Rogue/Druid unless "Instant Combo Points" was also enabled.

# BetterBlizzFrames 2.1.3b
## Forever
### Tweak
- Update Xaryu profile with his Forever profile.
## Retail & Forever
### Tweak
- Classic Player Castbar now also enables Classic Status/Breath Bars

# BetterBlizzFrames 2.1.3
## Forever
### New
- Misc: "Smaller Level Circle" in Forever Tweaks. Reduces the level circle size on Player/Target/Focus a little bit.
- Classic profile (Forever profile renamed to Classic).
- New Forever profile (previous Forever profile renamed to Classic). This has bronze frames, hew HD elite dragons, and a bit more modern look but still using the Classic Frames.
### Tweak
- Adjust the size and position of the PlayerFrame Elite Texture (for default frames, not Classic) to fit the new Forever textures.
- Classic Frames: Improve level display on elite frames when using the HD dragon elite setting.
## All Versions
### New
- Dark Mode: Separated "Player/Target/Focus/PartyFrame" into a new setting (on by default).
### Tweak
- Improve Dark Mode handling for easier toggle preview without a lot of reloads needed.
- "Player Elite" setting now also shows elite texture on Target/FocusFrame if you target yourself.
- Update Ceit profile (www.twitch.tv/ceitxd)
## Retail & Forever
### New
- Minimap Tweaks now has setting to adjust title size as well, and also works with Classic Minimap setting.
- Add back Masque support for Auras.
- Add option to show player castbar text background while having pixel borders on
### Tweak
- Added Blizzards blue crafting cast color instead of it just being gray/white when enabling something that needs castbar colors.
### Bugfix
- Fix castbars flashing white at completed cast with some settings (texture swap only for example)

# BetterBlizzFrames 2.1.2b
## Forever
### Bugfix
- Fix "Hide 2nd name" not removing PlayerFrame's 2nd name
- Fix "Hide Combat Glow" not working if right-click autoattack was enabled on a mob but not actually in combat.
- Fix a secret error related to player name workaround for weird blizz API

# BetterBlizzFrames 2.1.2
## Forever
### New
- Misc: "Rogue & Druid: Retail Combo Points". Use the retail style combo points for druid and rogue. (These settings work with all the Move Resources etc)
- Adjust PRD: "Hide PRD Combo Points". Hides the combo points on the Personal Resource Display while keeping the ones under the PlayerFrame.
- Adjust PRD: "Show on PRD with no target nameplate". With "Show resource on target nameplate" on, the resource is now only shown on the target nameplate and hidden when you have no target, unless you enable this.
### Tweak
- Remove warnings about Blizzard bug making addons not remember saved settings, this is finally fixed by Blizzard.
- Fix the "Instant Combo Points" setting now that the Blizzard bug has been fixed.
- Fix Stealth Indicator using the wrong texture on WoW Forever when using Classic Frames.
- Tweak Classic Frames's level text and high level skull texture to fit better.
- Dark Mode: Add the minimap day/night border to it.
### Bugfix
- Fix "Hide Combat Glow" not working properly on Forever.
- Fix an issue of the level background texture disappearing and not coming back due to a Blizzard bug.
- Fix PlayerFrame not showing Player name with some settings after the new Forever patch.
- Fix TargetFrame not updating name sometimes after the new Forever patch.
- Fix "Hide ActionBar Cast Animation" not hiding it for channels.
## All Versions
### New
- Misc: "Smooth Bars". Apply a smooth animation to the health and mana bars on Player, Target and Focus (plus the Personal Resource Display on Midnight & Forever) when they lose or gain health/mana. Thank you to Mo for contributing a working blueprint here!
- Misc: "Current HP Only & Center on Bars". Shows only the current health/mana on bars and centers them on the bar.
## Midnight & Forever
### New
- Misc: "Force Fit Player/Target/Focus Names". Scales down longer names to fit without truncation, within reason.
- Misc: "Tweak Extra Bar Textures". Changes the mana feedback and heal prediction textures to use the same texture as the bar, instead of the default older one that looks out of place.
### Bugfix
- Fix an issue with Legacy Combo Points not showing combo point background.
- Fix an issue with healthbar textures when using big player healthbar and Classic Frames setting with the texture being cut in half.

# BetterBlizzFrames 2.1.1
## All Versions
### New
- Classic Frames: HD Elite Dragons (in Misc). Replaces the dragons with the newer HD ones when using Classic Frames.
- Quest Indicator: Shows a quest icon on Target and FocusFrame for quest mobs. Located top right in /bbf with more settings for it in advanced settings.
- Add "Hide Pet ActionBar" setting in Misc.
### Tweak
- BBF now unclamps the minimap by default so you can move it closer to the edges of your screen if you want to instead of the silly edit mode restriction Blizzard does.
## Forever
### Tweak
- Add castbar background to dark mode
- Classic Frames setting now has "Bronze Frames", "Gray Actionbars" and "HD Elite Dragons" settings in the popup window too (these are in the Misc section too)
- The show mana while in other forms for Druids setting is now for all druid specs on Forever (as opposed to resto only on retail where that makes more sense). This is no longer enabled by default with this change but you might still have it on because of it being a previous default so turn it off in Misc if you dont want it.
### Bugfix
- Temporary disable "Instant Combo Points" setting due to Blizzard bugs and this causing an error because of it.
## Midnight & Forever
### New
- Minimap tweaks setting in Misc. Can move/size the minimap a bit and hide stuff.
### Tweak
- Add PRD borders to dark mode
### Bugfix
- Fix Target/Focus castbar being too far to the left when the Target/Focus had 0 auras and aura settings were disabled. Due to this you may notice your castbar shift position now if you adjusted it for a target without buffs.
## Midnight
### Tweak
- Tweak combo points/resource movement handling, should get rid of some annoyances while tweaking settings.
- Fix a lot of combo points issues. Especially related to no portrait and getting in vehicles while in combat. Lots of moving parts here so if any issues arise from these changes please lmk.