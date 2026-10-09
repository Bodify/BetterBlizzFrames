# BetterBlizzFrames 2.1.6
## All versions
### New
- General: "Move Names" setting. Move the Player/Target/Focus/ToT names freely. Right-click to open settings and to allow dragging the names and pixel move with arrow keys or set x/y offsets, align and multi-line per name.
- "Mirrored Names" setting in the Move Names popup. Target and Focus names move next to the portrait and align right, and the Player name aligns left.
- Misc: "Extra Status Bar Texts" setting. Shows health and mana text on the Target of Target (Retail & Forever) and on the default Party Frames (Classic). It can also override party / tot text to show percent only.
### Tweak
- Player/Target/Focus/ToT names now always follow the default name position unless a BBF setting moves them, so other things moving them should now work better (or you can just move them yourself with the new Move Names).
- "Center Names" moved into the Move Names popup.
## Forever
### New
- New "Hide Weapon Enchant" setting in Buffs & Debuffs section that removes weapon enchants/poisons from teh Buff row.
### Tweak
- Combo points now default to Blizzard's new combo points around the target portrait. Lots of changes and you will likely have to tweak your settings again due to all these changes.
- "Rogue & Druid: Retail Combo Points" is now "Move Combo Points under PlayerFrame" instead and has been turned off due to the change, you can re-enable.
- "Legacy Combo Points" is now off by default and has been turned off unless Classic Frames is on.
- Removed the popup offering BBF's combo points since Blizzard added these pretty much.
- The Personal Resource Display now uses Blizzard's new combo point bar. Adjust PRD moves, scales and hides it, and "Show resource on target nameplate" shows a separate bar on the target nameplate.
- "Smaller Level Frame" in Misc is now on by default. Feel free to turn it back off if you're not a fan.
### Bugfix
- Fix Lua errors and legacy combo points after Blizzard's latest Forever update.
## Retail & Forever
### New
- Misc: "Hide Combo Points/Resource When Empty" setting. Hides the combos until you have at least one point.
- Misc: "Only Show Filled Combo Points/Resource" setting. Hides empty points and their background and only display current ones.
- Big Debuffs: Right-click for settings. Milliseconds (on by default), Hide Timer Text, Low and Medium timer colors, Low Color threshold, timer text size, Test and Default buttons.
### Tweak
- Buffs & Debuffs auras: Timer Text Color: Right-click for Low and Medium colors and the Low Color threshold.
### Bugfix
- Fix combo points on TargetFrame getting covered by the elite dragon with Classic Frames (HD Elite).
- Fix Target/Focus auras not sorting exactly like Blizzard's with "Blizzard Default" on.
## Retail
### Tweak
- Misc: "Hide Objective Tracker during Arena" is now "Hide Objective Tracker during:" with a dropdown to pick Arena, Mythic and Raid.