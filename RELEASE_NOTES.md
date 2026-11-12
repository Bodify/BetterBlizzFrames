# BetterBlizzFrames 2.2.1b
## All versions
### New
- Alt Mana Bar Texture setting in Font & Texture.
### Bugfix
- Fix names losing its shadow on font from 2.2.1 patch.
- Fix custom power colors not working on bbf's alt mana bar for druids.
## Forever
### Tweak
- Update Perplexity profile (www.twitch.tv/perplexity). Thank you for sharing!
### Bugfix
- Fix classic minimap setting unintentionally having bronze colored minimap button rings.

# BetterBlizzFrames 2.2.1
## All versions
### New
- Misc: More Features: Tooltip Tweaks. Class, NPC, level and faction colors in unit tooltips, class colored healthbar, and options to hide the faction, class name or healthbar.
- Misc: Show Quest XP on XP Bar. Shows XP from completed quests as an orange segment on the XP bar. Right-click for texture & color settings.
- Misc: Change Heal Prediction Color. Recolor incoming heals on UnitFrames and/or RaidFrames.
- Racial Indicator: New "NPCs" setting that shows a creature type icon on NPCs (on by default).
### Tweak
- Names now fall back to the default font for letters your custom font doesn't support (Cyrillic, Korean, Chinese names etc).
### Bugfix
- Fix "Improved AddonList" not sorting properly sometimes.
## Retail & Forever
### New
- Big Debuffs: Right-click settings can now add your own buff and debuff spell IDs, or blacklist spells.
- Big Debuffs: Now also works on the default party frames.
- The "Format Numbers" setting now a right-click popup with "Extra Decimal" and new "Don't format below 10k" setting.
- Font & Textures: Change Name Bg Texture: New Alpha Override setting to change the name background alpha.
- Minimap Tweaks: Classic Mail Icon. Shows the mail icon as a classic minimap button. Draggable around the minimap and resizeable.
- Misc: ActionBars: Add Slot Art. Gives every action bar the main bar's background slot art.
- Misc: "Classic Frames: Use Original Textures". Classic Frames now uses textures bundled with BBF since the in-game ones have a warped level ring. Enable this if you use your own custom textures in your WoW folder.
### Tweak
- "Texture Behind Name" setting has been removed and merged into Change Name Bg Texture in Font & Textures (your setting is moved over).
- Classic Frames level text is now better positioned after most annoying parts have been sorted (like the warped texture mentioned)
- Minimap button borders from other addons now get resized with "OCD Tweaks" so the border actually fits the icon.
### Bugfix
- Fix level text not following the name font size with No Portrait in some cases.
- Fix some resource bars causing a lua error
- Fix an aura filtering issue in dungeons causing more auras that intended to show with only whitelist on.
## Forever
### New
- Remove Name Border: Now has right-click options to pick which frames it should be active on.
- Change Name Bg Texture: The "Classic/Forever" toggles underneath Target/FocusFrame for Name Background Texture has been moved into Font & Textures section instead as "Change Name Bg Texture".
- Classic Minimap: Tracking and Day/Night buttons can now be dragged around the minimap.
- Misc: Calmer Combat Glow. Makes the combat glow on unit frames less bright.
- Big Debuffs: New "Add extra buffs" setting (on by default). Shows a preset list of extra buffs on friendly units like Sprint, Aspect of the Cheetah, Inner Focus etc.
- Party Frame Hide Options: New "Hide Party Auras" and "Hide Party Buff Tooltip" settings.
### Tweak
- Classic Castbars are now bronze tinted to match the default bronze UnitFrames.
- Racial Indicator border now follows dark mode/bronze tint colors.
- Minimap compass underlay now gets the minimap dark mode.
- Tweak Party frame status glow to fit properly with Big Healthbars.
- Racial Indicator: Use the SD textures for race indicator when using race texture (they have infinitely more aura).
- Racial Indicator: Race texture is now the default instead of the racial spell icon (can be changed in advanced settings).
- Another batch of small pixel tweaks around Classic Frames, Big Healthbars, Reduced ToT etc.
- Earth Shock now counts as an interrupt for the castbar interrupt icon.
- The sidebar with streamer profiles are now split into "Forever" and "Retail" sections since not all of them have been updated specifically for Forever but are just Retail profiles (that still work fine but may want some tweaks).
### Bugfix
- Fix some lua errors from secret colors on frame textures and party level ring.
- Fix Classic Frames sometimes being desaturated on NPC target and elites when using Class Color Frame Texture.
- Fix the default party frame status and combat glows being slightly misplaced, and the combat glow showing underneath the frame border.