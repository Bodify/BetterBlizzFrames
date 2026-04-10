# Castbar Module Refactor Plan

## Overview

`temp_cata/modules/castbar.lua` is 1087 lines with heavy duplication across party/pet/player/target castbar handling. This plan outlines a fresh rewrite as `temp_era/modules/castbar_poc.lua` (~700-750 lines) that preserves all features and avoids the 3 confirmed bugs in the original. The old file stays untouched as reference. The goal is to simplify — reduce cognitive load and make the code easier to reason about — not to minimize line count.

## Branch & Approach

- **Branch:** `refactor/castbar`, branched off `main`
- **Approach:** Fresh file (`temp_era/modules/castbar_poc.lua`), not an in-place edit of the old module
- **TOC:** `BetterBlizzFrames_Vanilla.toc` updated to load `temp_era/modules/castbar_poc.lua` instead of `temp_cata/modules/castbar.lua`. Swap back to verify the original still works anytime.
- **Old file:** `temp_cata/modules/castbar.lua` stays untouched as reference. Era no longer depends on cata code.
- **Public API:** The new file exports the same `BBF.*` functions (`UpdateCastbars`, `UpdatePetCastbar`, `ChangeCastbarSizes`, `RefreshCastbars`, test mode functions) so the rest of the addon doesn't care which file provides them.

**Classic Era scope:** FocusFrame does not exist in Classic Era. All focus-related code (~100 lines) from the original is simply not brought over. BorderShield does exist on `SmallCastingBarFrameTemplate` in Era (Blizzard shows it for uninterruptible casts) and is handled normally.

The rewrite is based on analysis of both the current BBF implementation and `cfCastbars`, a minimal addon that achieves party/pet castbars via a single factory function wrapping Blizzard's `SmallCastingBarFrameTemplate`.

## Reference Files

| File | Purpose |
|---|---|
| `temp_cata/modules/castbar.lua` | Original BBF castbar module (1087 lines). **Reference only** — not edited by this rewrite. |
| `temp_era/modules/castbar_poc.lua` | **New file.** The fresh rewrite built from this plan. |
| `cfCastbars/Core.lua` | Minimal ~35-line factory that creates a castbar for any unit. Demonstrates how little code is needed when leaning on Blizzard's template. |
| `cfCastbars/PartyCastbar.lua` | 14 lines. Creates party castbars by calling the Core factory in a loop. |
| `cfCastbars/PetCastbar.lua` | 9 lines. Creates pet castbar by calling the Core factory once. |
| `cfCastbars/Test.lua` | Generic test mode -- one `TestCast(bar, duration)` function drives any bar with a looping OnUpdate animation. |

### Other Files Affected

| File | What needs updating |
|---|---|
| `BetterBlizzFrames_Vanilla.toc` | Change castbar load path from `temp_cata/modules/castbar.lua` to `temp_era/modules/castbar_poc.lua` |
| `temp_era/gui.lua` | Remove focus castbar GUI section (dead in Era) |

The following files reference castbar DB keys but are **not modified** by this rewrite (no DB key migration):

| File | References (unchanged) |
|---|---|
| `temp_era/BetterBlizzFrames.lua` | Default settings table (keys unchanged) |
| `temp_era/modules/auras.lua` | `targetStaticCastbar`, `targetDetachCastbar` for aura positioning |
| `temp_era/modules/darkmode.lua` | `darkModeCastbars`, `classicCastbars`, `showPartyCastbar` |
| `temp_era/modules/interruptIcon.lua` | `castBarInterruptIcon*` keys |

---

## Confirmed Bugs (Fixed by This Refactor)

All 3 bugs are in the focus castbar code (lines 734-836), which is deleted entirely since FocusFrame doesn't exist in Classic Era. Documenting here for reference if this plan is adapted for TBC/Cata versions:

1. **Focus missing `notInterruptible` check** (line 749): `if name then--and not notInterruptible then` -- highlights uninterruptible spells
2. **Focus uses wrong unit string** (line 829): `UnitChannelInfo("target")` inside the focus handler -- uses target's channeling status
3. **Dead conditional** (lines 782-785): `if not channeling then resetCastbarColor() else resetCastbarColor() end` -- both branches identical

---

## Current Problems

### 1. Duplicated code across bar types

| Duplication | Lines wasted | Description |
|---|---|---|
| Focus castbar code (entire block) | ~100 lines | FocusFrame doesn't exist in Era. All focus sizing, interrupt highlight, timer, texture hooks are dead code. |
| Target vs Focus OnUpdate (interrupt highlight) | ~97 lines | Two ~100-line blocks differ only by unit string, texture variable, and 3 bugs. Focus block deleted; target block kept. |
| Target vs Focus sizing in `ChangeCastbarSizes` | ~47 lines | Identical sequences. Focus block deleted. |
| Party vs Pet creation in `CreateCastbars` | ~42 lines | Same template: create frame, set texture, icon, Timer, OnUpdate hook |
| Party vs Pet test mode | ~40 lines | Same ticker/show/hide/icon/timer pattern |
| Timer setup across bar types | ~30 lines | Same font string creation and OnUpdate hooking |

### 2. Code that duplicates Blizzard template behavior

| Code | Lines | What Blizzard already handles |
|---|---|---|
| `resetCastbarColor` (lines 609-615) | ~7 lines | Both branches set identical color `(1, 0.702, 0)`. Inline the single call. |
| Texture re-set on every OnEvent (lines 350-352, 993-1014) | ~20 lines | Only needs one-time set, not per-event |

### 3. Inconsistent patterns

| Issue | Examples |
|---|---|
| Draw layers | Party icon = `OVERLAY`, Player icon = `ARTWORK`, Target = `OVERLAY, 7` |
| Icon base X offset | `-4` for party/pet, `-5` for player/target |
| Icon base Y offset | `-1` for party/pet creation, `0` for pet update, `1` for target |
| Icon sizing | Hardcoded `22x22` in some places, `SetScale` only in others |
| DB key casing | `partyCastBarScale` vs `partyCastbarShowText` (capital B vs lowercase b) |
| DB key word order | `showPartyCastBarIcon` vs `petCastBarShowText` |

### 4. Dead code (~70 lines)

- All focus castbar code (lines 505-506, 538-540, 545, 734-836, 971-991, 1008-1014, 1023-1025) -- ~100 lines, FocusFrame doesn't exist in Era
- Commented-out Evoker hook (lines 1067-1088)
- Commented-out InterruptGlow sizing (lines 868-877)
- Commented-out loading screen frame strata block (lines 1051-1064)
- Commented-out throttle logic in OnUpdate hooks (lines 635-639, 736-740)
- Commented-out BorderShield lines in pet/player sections (lines 232-235, 909-913, 1037-1041)
- Unused variables: `targetLastUpdate`, `focusLastUpdate`, `updateInterval` (lines 549-551)
- `resetCastbarColor` has two identical branches (lines 609-615)

### 5. `adjustCastBarBorder` has mystery parameters

```lua
adjustCastBarBorder(castBar, border, adjust, shield, player, party, playerCb)
```

- `player` param is never used across all 13 call sites (always `nil` or omitted)
- `party` and `playerCb` create 1-pixel tweaks via positional booleans
- Call sites are unreadable: `adjustCastBarBorder(bar, bar.Border, 15, nil, nil, true)`

Only 3 distinct parameter combinations exist across all 13 calls:
1. Normal border: `adjust=15, shield=nil`
2. Shield border: `adjust=12, shield=true`
3. Height baseline varies: `party=true` -> defaultBorderH=55, else 56; `playerCb=11` -> defaultBarH=11, else 10

### 6. Missing hooks in plan scope

These hooks exist in current code and must be preserved:

| Hook | Lines | Purpose |
|---|---|---|
| Spark repositioning OnUpdate | 879-886 | Resizes and repositions spark for custom-sized player castbar |
| OnShow icon hook | 1031-1043 | Shows player castbar icon on each cast start |
| hooksecurefunc SetScale | 1045-1049 | Persists player castbar scale to DB when changed |
| OnEvent texture hooks | 993-1014 | Re-applies custom texture after Blizzard resets it on cast events |

### 7. `GetPartyMemberFrame` is defined but not used

Lines 42-68 define `GetPartyMemberFrame()` which searches 3 frame types. But `UpdateCastbars()` (lines 155-161) duplicates this search inline instead of calling it. Either use the function or remove it.

### 8. First-pass scope is too broad

The current plan mixes three distinct jobs:

1. Structural simplification inside `castbar.lua`
2. DB key normalization across multiple files
3. Branch/load-path cleanup for Era vs non-Era codepaths

The first pass should focus on structural simplification first. DB-key normalization should be deferred until the castbar module shape is stable. Branch/load-path assumptions must be treated as branch-specific, not universal.

### 9. Bar ownership split matters

The module has two real lifecycles:

- **Addon-owned bars:** party and pet are created by this module and can share factory/setup code
- **Blizzard-owned bars:** player and target are existing Blizzard frames and should only be styled, anchored, and hooked

The architecture should reflect that split instead of implying one generic pipeline owns all four bar types equally.

### 10. Known risk areas

- **Taint on Blizzard frames:** OnUpdate hooks on `CastingBarFrame` that read `BetterBlizzFramesDB` can taint the bar in combat. All hooks must avoid calling secure Blizzard functions or modifying secure frame attributes.
- **Timer layout** is not just timer hookup: player centering and per-type offsets must be preserved.
- **Public BBF entry points** should remain as compatibility wrappers during the refactor.
- **Party frame detection** (~40 lines of inline search across 3 frame types) is the most complex piece and is kept as-is in this refactor. Do not force `GetPartyMemberFrame()` into `UpdateCastbars` — the function is removed as unused.
- **`wasOnLoadingScreen` flag:** Used in the SetScale hook to prevent saving scale during loading screen. Must be cleared on `PLAYER_ENTERING_WORLD`. If stale, scale changes silently stop saving.
- **`DarkModeCastbars()` contract:** Called at the end of `UpdateCastbars` and `UpdatePetCastbar`. Must tolerate nil bars (e.g., early call before creation). Verify it has its own nil guards.

---

## Target Architecture

### File structure (~700-750 lines)

```
1. Helpers: CreateBar, StyleBar, FitBorder, AttachTimer   (~80 lines)
2. Addon-Owned Bar Setup                                  (~80 lines)  -- party + pet
3. Blizzard Bar Setup                                     (~60 lines)  -- player + target
4. Interrupt Highlighting                                 (~50 lines)  -- target only, no focus
5. One-Time Hooks                                         (~50 lines)
6. Test Mode                                              (~40 lines)
7. Refresh / Public Wrappers                              (~20 lines)
8. Event Wiring                                           (~20 lines)
```

The key split is **addon-owned bars** (party/pet — created by this module) vs **Blizzard-owned bars** (player/target — only styled and hooked). Sections 4-8 are self-contained features, not architectural layers.

### First-pass scope

The first pass should stay focused on `castbar.lua` structure:

- delete dead focus/dead commented code, unify timer hookup, unify test mode
- split creation from refresh
- extract `StyleBar` as the single shared layout function
- keep public entry points as wrappers
- preserve runtime hooks

DB key normalization is deferred indefinitely. The 7 inconsistent keys are documented in a comment block and accessed by their actual names. No migration function, no string concatenation for key access.

### 1. Helpers (~80 lines)

#### CreateBar(name, unit)

Factory for party/pet castbars only. Player/target are Blizzard frames — not created.

```lua
local function CreateBar(name, unit)
    -- Guard: if the named frame already exists, return it (prevents double-creation)
    if _G[name] then return _G[name] end

    local bar = CreateFrame("StatusBar", name, UIParent, "SmallCastingBarFrameTemplate")
    CastingBarFrame_SetUnit(bar, unit, true, true)
    bar:SetStatusBarTexture(classicCastbarTexture)
    bar.Text:SetFontObject("SystemFont_Shadow_Med1_Outline")
    bar.Icon:SetSize(22, 22)

    -- Timer font string (countdown text like "1.8")
    bar.Timer = bar:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1_Outline")
    bar.Timer:SetPoint("LEFT", bar, "RIGHT", 5, 0)
    bar.Timer:SetTextColor(1, 1, 1, 1)

    return bar
end
```

Note: No `FakeTimer`. Test mode reuses `bar.Timer` directly (set text to "1.8", restore on exit).

#### StyleBar(bar, opts)

Single function that applies all layout to any castbar. Each caller passes explicit values — no lookup tables, no prefix arithmetic, no adapters. Every call site is self-documenting and greppable.

```lua
local function StyleBar(bar, opts)
    if not bar or not bar.Text or not bar.Border then return end

    -- Geometry
    bar:SetScale(opts.scale)
    bar:SetWidth(opts.width)
    bar:SetHeight(opts.height)
    bar:SetStatusBarTexture(opts.texture or classicCastbarTexture)
    if opts.ignoreParentAlpha then bar:SetIgnoreParentAlpha(true) end

    -- Text
    bar.Text:ClearAllPoints()
    bar.Text:SetPoint("CENTER", bar, "CENTER", 0, 0)
    bar.Text:SetWidth(opts.width)
    bar.Text:SetAlpha(opts.showText and 1 or 0)

    -- Border
    bar.Border:SetAlpha(opts.showBorder and 1 or 0)
    bar.Flash:SetParent(opts.showBorder and bar or hiddenFrame)
    FitBorder(bar, bar.Border, false, opts.borderH, opts.barH)
    FitBorder(bar, bar.Flash,  false, opts.borderH, opts.barH)

    -- Icon
    if not opts.showIcon then
        bar.Icon:SetAlpha(0)
    else
        bar.Icon:ClearAllPoints()
        bar.Icon:SetPoint("RIGHT", bar, "LEFT", opts.iconX, opts.iconY)
        bar.Icon:SetScale(opts.iconScale or 1)
        bar.Icon:SetDrawLayer(opts.iconLayer, opts.iconSublayer)
        bar.Icon:SetAlpha(1)
    end

    -- Timer
    if bar.Timer then bar.Timer:SetShown(opts.showTimer) end
    AttachTimerHook(bar)
end
```

#### FitBorder(bar, border, isShield, defaultBorderH, defaultBarH)

Replaces `adjustCastBarBorder` with its 7 mystery parameters. Only 2 parameter combos matter: shield vs normal.

```lua
local DEFAULT_BAR_WIDTH    = 150  -- Blizzard's default castbar width for all types
local DEFAULT_BORDER_WIDTH = 200  -- Blizzard's default border texture width
local BORDER_H_SCALE       = 5.0  -- vertical scaling ratio for border height

local function FitBorder(bar, border, isShield, defaultBorderH, defaultBarH)
    local adjustFactor = isShield and (12 / 50) or (15 / 50)

    local dw = bar:GetWidth() - DEFAULT_BAR_WIDTH
    local dh = bar:GetHeight() - (defaultBarH or 10)

    local borderW = DEFAULT_BORDER_WIDTH + dw + (dw * adjustFactor)
    local borderH = (defaultBorderH or 56) + (dh * BORDER_H_SCALE)

    border:ClearAllPoints()
    border:SetPoint("CENTER", bar, "CENTER", isShield and -4 or 0, 0)
    border:SetSize(borderW, isShield and borderH - 1 or borderH)
end
```

#### AttachTimerHook(bar)

Hooks OnUpdate once for countdown text. Replaces scattered timer setup across bar types.

```lua
local function AttachTimerHook(bar)
    if not bar.Timer then return end
    if not bar.timerHooked then
        bar:HookScript("OnUpdate", UpdateCastTimer)
        bar.timerHooked = true
    end
end
```

### 4. Interrupt Highlighting (~50 lines, down from ~200)

Target-only (FocusFrame doesn't exist in Era). The duplicate focus block (~100 lines) is deleted entirely.

**Key design change:** The original code (and previous plan draft) looped over interrupt spell IDs and set color inside the loop — last ID wins (loop-and-overwrite). This version computes one aggregate interrupt state first, then applies one color result. Interrupt cooldown state is also cached via `SPELL_UPDATE_COOLDOWN` event instead of calling `GetSpellCooldown` every frame.

**API note:** Classic Era `UnitCastingInfo`/`UnitChannelInfo` return `startTime` and `endTime` in **milliseconds**. Division by 1000 to get seconds is correct for this API version.

```lua
local function resetDefault(castbar, texture)
    texture:SetDesaturated(false)
    castbar:SetStatusBarColor(1, 0.702, 0)
    castbar.Spark:SetVertexColor(1, 1, 1)
end

local function applyEdgeHighlight(castbar, texture, startTime, endTime)
    local now = GetTime()
    local elapsed = now - startTime / 1000
    local remaining = endTime / 1000 - now
    if elapsed <= highlightStartTime or remaining <= highlightEndTime then
        texture:SetDesaturated(true)
        castbar:SetStatusBarColor(unpack(edgeColor))
        castbar.Spark:SetVertexColor(unpack(edgeColor))
    elseif colorMiddle then
        texture:SetDesaturated(true)
        castbar:SetStatusBarColor(unpack(middleColor))
        castbar.Spark:SetVertexColor(1, 1, 1)
    else
        resetDefault(castbar, texture)
    end
end

-- Cache interrupt cooldown state on event, not per-frame
local interruptCooldowns = {}  -- [spellID] = { start, dur }

local cdListener = CreateFrame("Frame")
cdListener:RegisterEvent("SPELL_UPDATE_COOLDOWN")
cdListener:SetScript("OnEvent", function()
    for _, id in ipairs(interruptSpellIDs) do
        local start, dur = GetSpellCooldown(id)
        interruptCooldowns[id] = { start = start, dur = dur }
    end
end)

-- Compute aggregate interrupt state: "cannot" > "delayed" > "available"
local function GetInterruptState(castLeft)
    local now = GetTime()
    local worst = "available"
    for _, id in ipairs(interruptSpellIDs) do
        local cd = interruptCooldowns[id]
        if cd then
            local cdLeft = cd.start + cd.dur - now
            if cdLeft > 0 and cdLeft > castLeft then
                return "cannot"  -- worst possible state, no need to continue
            elseif cdLeft > 0 then
                worst = "delayed"
            end
        end
    end
    return worst
end

-- Single hook for target (was duplicated for focus with 3 bugs; focus deleted for Era)
local function HookTargetInterruptHighlight()
    if targetCastbarEdgeHooked then return end

    TargetFrameSpellBar:HookScript("OnUpdate", function(self)
        if not UnitCanAttack(TargetFrame.unit, "player") then
            resetDefault(self, targetSpellBarTexture)
            return
        end

        local name, _, _, startTime, endTime, _, _, notInterruptible = UnitCastingInfo("target")
        if not name then
            name, _, _, startTime, endTime, _, notInterruptible = UnitChannelInfo("target")
        end

        if not name or notInterruptible then
            resetDefault(self, targetSpellBarTexture)
            return
        end

        local castLeft = endTime / 1000 - GetTime()

        if castBarRecolorInterrupt then
            local state = GetInterruptState(castLeft)
            if state == "cannot" then
                targetSpellBarTexture:SetDesaturated(true)
                self:SetStatusBarColor(unpack(castBarNoInterruptColor))
                self.Spark:SetVertexColor(unpack(castBarNoInterruptColor))
            elseif state == "delayed" then
                targetSpellBarTexture:SetDesaturated(true)
                self:SetStatusBarColor(unpack(castBarDelayedInterruptColor))
                self.Spark:SetVertexColor(unpack(castBarDelayedInterruptColor))
            elseif targetCastBarEdgeHighlight then
                applyEdgeHighlight(self, targetSpellBarTexture, startTime, endTime)
            else
                resetDefault(self, targetSpellBarTexture)
            end
        elseif targetCastBarEdgeHighlight then
            applyEdgeHighlight(self, targetSpellBarTexture, startTime, endTime)
        else
            resetDefault(self, targetSpellBarTexture)
        end
    end)
    targetCastbarEdgeHooked = true
end
```

**Note for TBC/Cata adaptation:** If porting this refactor to versions with FocusFrame, extract the OnUpdate body into a `CreateInterruptHighlightHook(unitID, parentFrame, texture, edgeEnabled)` factory and hook both target and focus. The factory approach eliminates the 3 bugs documented above.

### 2. Addon-Owned Bar Setup (~80 lines)

Each setup function calls `StyleBar` with explicit params, then does its unique anchoring/unit logic. No lookup tables — the per-type constants are inline at each call site.

#### Party

Party anchoring keeps slot-based behavior. The current inline frame detection logic (searching PartyMemberFrame, CompactPartyFrame, CompactRaidFrame for each slot) is kept as-is — it is the most complex piece of this module and needs its own focused cleanup pass, not a drive-by rewrite.

`GetPartyMemberFrame()` (lines 42-68) is currently defined but unused — `UpdateCastbars()` duplicates its search inline. Decision: **remove** the unused function. If the inline search needs refactoring later, write a new purpose-built helper at that time.

```lua
function BBF.UpdateCastbars()
    local db = BetterBlizzFramesDB
    if not (db.showPartyCastbar or db.partyCastBarTestMode) then
        for i = 1, 5 do
            if spellBars[i] then CastingBarFrame_SetUnit(spellBars[i], nil) end
        end
        return
    end

    for i = 1, 5 do
        spellBars[i] = CreateBar("Party" .. i .. "SpellBar", "party" .. i)
    end

    -- ... party-specific frame detection + anchoring logic (kept as-is, ~40 lines) ...
    -- This searches PartyMemberFrame1-5, CompactPartyFrame, CompactRaidFrame for each slot.
    -- For each bar found:

    StyleBar(spellBars[i], {
        scale      = db.partyCastBarScale,
        width      = db.partyCastBarWidth,
        height     = db.partyCastBarHeight,
        showText   = db.partyCastbarShowText,       -- NOTE: inconsistent key (lowercase b), kept as-is
        showBorder = db.partyCastbarShowBorder,      -- NOTE: inconsistent key (lowercase b), kept as-is
        showIcon   = db.showPartyCastBarIcon,        -- NOTE: inconsistent key (prefix "show"), kept as-is
        iconX      = -4 + (db.partyCastbarIconXPos or 0),
        iconY      = -1 + (db.partyCastbarIconYPos or 0),
        iconLayer  = "OVERLAY",
        iconScale  = db.partyCastBarIconScale,
        borderH    = 55, barH = 10,
        showTimer  = db.partyCastBarTimer,
    })
    -- spellbar:SetFrameStrata("MEDIUM")

    BBF.DarkModeCastbars()
end
```

#### Pet

```lua
function BBF.UpdatePetCastbar()
    local db = BetterBlizzFramesDB
    if not (db.petCastbar or db.petCastBarTestMode) then
        if spellBars["pet"] then CastingBarFrame_SetUnit(spellBars["pet"], nil) end
        return
    end

    spellBars["pet"] = CreateBar("PetSpellBar", "pet")
    -- SmoothStatusBarMixin: applied once at creation. Note: this means SetValue calls
    -- on the pet bar will animate smoothly. StyleBar and test mode must use
    -- SetSmoothedValue when available to avoid bypassing the mixin.
    if not spellBars["pet"].smoothMixinApplied then
        Mixin(spellBars["pet"], SmoothStatusBarMixin)
        spellBars["pet"]:SetMinMaxSmoothedValue(0, 100)
        spellBars["pet"].smoothMixinApplied = true
    end

    local bar = spellBars["pet"]

    StyleBar(bar, {
        scale      = db.petCastBarScale,
        width      = db.petCastBarWidth,
        height     = db.petCastBarHeight,
        showText   = db.petCastBarShowText,
        showBorder = db.petCastBarShowBorder,
        showIcon   = db.showPetCastBarIcon,          -- NOTE: inconsistent key (prefix "show"), kept as-is
        iconX      = -4 + (db.petCastbarIconXPos or 0),
        iconY      =  0 + (db.petCastbarIconYPos or 0),
        iconLayer  = "OVERLAY",
        iconScale  = db.petCastBarIconScale,
        borderH    = 55, barH = 10,
        showTimer  = db.petCastBarTimer,
    })

    local petFrame = PetFrame
    if petFrame then
        bar:ClearAllPoints()
        if db.petDetachCastbar then
            bar:SetPoint("CENTER", UIParent, "CENTER",
                db.petCastBarXPos, db.petCastBarYPos)
        else
            bar:SetPoint("CENTER", petFrame, "CENTER",
                db.petCastBarXPos + 4, db.petCastBarYPos - 27)
        end
        bar:SetFrameStrata("MEDIUM")
        CastingBarFrame_SetUnit(bar, "pet", true, true)
    else
        CastingBarFrame_SetUnit(bar, nil)
    end

    BBF.DarkModeCastbars()
end
```

### 3. Blizzard Bar Setup (~60 lines)

These are Blizzard frames — not created, just styled. Target XY positioning is handled in `auras.lua`.

**Taint warning:** OnUpdate hooks on `CastingBarFrame` that read `BetterBlizzFramesDB` (a non-Blizzard global) can taint the bar in combat. All hooks on Blizzard-owned bars must avoid calling secure Blizzard functions or modifying secure frame attributes. `SetStatusBarTexture`, `SetStatusBarColor`, `SetSize`, and `SetPoint` are safe. Do not call `SetAttribute` or any protected function from these hooks.

```lua
function BBF.ChangeCastbarSizes()
    local db = BetterBlizzFramesDB
    BBF.UpdateUserAuraSettings()

    -- Player
    StyleBar(CastingBarFrame, {
        scale      = db.playerCastBarScale,
        width      = db.playerCastBarWidth,
        height     = db.playerCastBarHeight,
        showText   = db.playerCastBarShowText,
        showBorder = db.playerCastBarShowBorder,
        showIcon   = db.playerCastBarShowIcon,
        iconX      = -5 + (db.playerCastbarIconXPos or 0),
        iconY      =  0 + (db.playerCastbarIconYPos or 0),
        iconLayer  = "ARTWORK",              -- player uses ARTWORK, not OVERLAY (see Design Decisions)
        iconScale  = db.playerCastBarIconScale,
        borderH    = 56, barH = 11,          -- player bar is 1px taller than others
        showTimer  = db.playerCastBarTimer,
    })
    BBF.MoveRegion(CastingBarFrame, "CENTER", UIParent, "BOTTOM",
        db.playerCastBarXPos, db.playerCastBarYPos + 166)

    -- Target
    StyleBar(TargetFrameSpellBar, {
        scale      = db.targetCastBarScale,
        width      = db.targetCastBarWidth,
        height     = db.targetCastBarHeight,
        showText   = db.targetCastBarShowText,
        showBorder = db.targetCastBarShowBorder,
        showIcon   = db.targetCastBarShowIcon,
        iconX      = -5 + (db.targetCastbarIconXPos or 0),
        iconY      =  1 + (db.targetCastbarIconYPos or 0),
        iconLayer  = "OVERLAY", iconSublayer = 7,  -- target icon stacks above border
        iconScale  = db.targetCastBarIconScale,
        borderH    = 56, barH = 10,
        showTimer  = db.targetCastBarTimer,
    })

    -- One-time hooks are installed separately, not from the normal layout refresh path
    EnsurePlayerHooks()
    EnsureTargetHooks()

    -- Font customization (shared concern with other modules)
    if db.changeUnitFrameFont then
        -- ... font setup for target/player text (kept as-is) ...
    end
end
```

### 5. One-Time Hooks (~50 lines)

Player/target runtime hooks do not belong inside the normal refresh/layout path. Install them once via guarded helpers. All hooks in this section use `HookScript` (permanent) or `hooksecurefunc` (permanent) — a bug means a `/reload`. All guards use a flag on the frame itself to prevent double-registration.

```lua
local function EnsurePlayerHooks()
    if CastingBarFrame.bbfHooked then return end
    CastingBarFrame.bbfHooked = true

    -- Spark repositioning for custom-sized player castbar
    -- NOTE: Blizzard template does NOT reposition spark correctly for custom widths.
    -- This hook is required. Do not remove.
    CastingBarFrame:HookScript("OnUpdate", function(self)
        self.Spark:SetSize(33, BetterBlizzFramesDB.playerCastBarHeight + 20)
        local val = self:GetValue()
        local _, maxVal = self:GetMinMaxValues()
        if maxVal > 0 then
            local pct = val / maxVal
            self.Spark:ClearAllPoints()
            self.Spark:SetPoint("CENTER", self, "LEFT", self:GetWidth() * pct, -1.5)
        end
    end)

    -- Show/hide icon on each cast start
    CastingBarFrame:HookScript("OnShow", function()
        if BetterBlizzFramesDB.playerCastBarShowIcon then
            CastingBarFrame.Icon:Show()
        end
    end)

    -- Persist player castbar scale to DB when changed (e.g. by MoveRegion)
    -- wasOnLoadingScreen: set by the loading screen handler elsewhere in BBF.
    -- Prevents scale being saved as 0 or nil during the loading screen transition
    -- when Blizzard resets frame properties. If this flag is stale (persisted as true
    -- across sessions), scale changes will silently stop saving. The flag must be
    -- cleared on PLAYER_ENTERING_WORLD.
    hooksecurefunc(CastingBarFrame, "SetScale", function()
        if not BetterBlizzFramesDB.wasOnLoadingScreen then
            BetterBlizzFramesDB.playerCastBarScale = CastingBarFrame:GetScale()
        end
    end)

    -- Re-apply custom texture after Blizzard resets it on cast events
    CastingBarFrame:HookScript("OnEvent", function()
        CastingBarFrame:SetStatusBarTexture(classicCastbarTexture)
    end)

    -- Draw layer ordering for player bar
    CastingBarFrame.Border:SetDrawLayer("OVERLAY", 5)
    CastingBarFrame.BorderShield:SetDrawLayer("OVERLAY", 6)
    CastingBarFrame.Text:SetDrawLayer("OVERLAY", 7)
end

local function EnsureTargetHooks()
    if TargetFrameSpellBar.bbfHooked then return end
    TargetFrameSpellBar.bbfHooked = true

    -- Re-apply custom texture after Blizzard resets it on cast events
    TargetFrameSpellBar:HookScript("OnEvent", function()
        TargetFrameSpellBar:SetStatusBarTexture(classicCastbarTexture)
    end)

    -- Draw layer ordering for target bar
    TargetFrameSpellBar.Border:SetDrawLayer("OVERLAY", 6)
    TargetFrameSpellBar.BorderShield:SetDrawLayer("OVERLAY", 7)
end
```

### 6. Test Mode (~40 lines, down from ~110)

One function works for any castbar. Uses OnUpdate (like cfCastbars) instead of C_Timer.NewTicker for simplicity. Handles SmoothStatusBarMixin on pet bar via `SetSmoothedValue` check.

No `FakeTimer` — test mode reuses `bar.Timer` directly (sets static text "1.8", restores on exit). The permanent OnUpdate hook exits early when `testStartTime` is nil, so cost is one nil-check per frame when test mode is inactive.

```lua
function BBF.CastbarTestMode(bar, enabled, opts)
    if not bar then return end
    opts = opts or {}

    if enabled then
        bar:SetIgnoreParentAlpha(true)
        bar:Show()
        bar:SetAlpha(1)
        bar:SetMinMaxValues(0, 100)
        bar:SetValue(0)
        bar.Text:SetText(opts.spellName or "Test Cast")
        bar.Flash:SetAlpha(0)

        if opts.showIcon and opts.iconTexture then
            bar.Icon:SetTexture(opts.iconTexture)
            bar.Icon:Show()
        else
            bar.Icon:Hide()
        end

        -- Reuse Timer for static test display
        if bar.Timer and opts.showTimer then
            bar.Timer:SetText("1.8")
            bar.Timer:Show()
        elseif bar.Timer then
            bar.Timer:Hide()
        end

        -- OnUpdate-based animation (simpler than C_Timer, no external ref to manage)
        bar.testStartTime = GetTime()
        if not bar.testHooked then
            bar:HookScript("OnUpdate", function(self)
                if not self.testStartTime then return end
                local elapsed = GetTime() - self.testStartTime
                local val = (elapsed % 2) / 2 * 100  -- 2-second loop
                if self.SetSmoothedValue then
                    self:SetSmoothedValue(val)
                else
                    self:SetValue(val)
                end
            end)
            bar.testHooked = true
        end
    else
        bar.testStartTime = nil
        bar:SetAlpha(0)
        if bar.Flash then bar.Flash:SetAlpha(1) end
        if bar.Timer then bar.Timer:Hide() end
    end
end

-- Callers:
function BBF.partyCastBarTestMode()
    BBF.UpdateCastbars()
    local db = BetterBlizzFramesDB
    for i = 1, 5 do
        BBF.CastbarTestMode(spellBars[i], db.partyCastBarTestMode, {
            showIcon = db.showPartyCastBarIcon,
            iconTexture = GetSpellTexture(116),
            spellName = L["Label_Frostbolt"],
            showTimer = db.partyCastBarTimer,
        })
    end
end

function BBF.petCastBarTestMode()
    BBF.UpdatePetCastbar()
    local db = BetterBlizzFramesDB
    BBF.CastbarTestMode(spellBars["pet"], db.petCastBarTestMode, {
        showIcon = db.showPetCastBarIcon,
        iconTexture = GetSpellTexture(6358),
        spellName = L["Label_Seduction"],
        showTimer = db.petCastBarTimer,
    })
end
```

### 7. Refresh / Public API (~20 lines)

```lua
function BBF.RefreshCastbars()
    BBF.UpdateCastbars()     -- party
    BBF.UpdatePetCastbar()   -- pet
    BBF.ChangeCastbarSizes() -- player + target
    BBF.DarkModeCastbars()
end
```

### 8. Event Wiring (~20 lines)

```lua
local CastBarFrame = CreateFrame("Frame")
CastBarFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
CastBarFrame:SetScript("OnEvent", function(self, event)
    if BetterBlizzFramesDB.showPartyCastbar then
        BBF.UpdateCastbars()
    end
    -- Re-run test mode if active so bars re-anchor correctly
    if BetterBlizzFramesDB.partyCastBarTestMode then
        BBF.partyCastBarTestMode()
    end
end)

local petUpdate = CreateFrame("Frame")
petUpdate:RegisterEvent("UNIT_PET")
petUpdate:SetScript("OnEvent", function()
    if BetterBlizzFramesDB.petCastbar then
        BBF.UpdatePetCastbar()
    end
end)

-- Recheck interrupt spells on pet summon (warlock/priest summons)
local recheckInterruptListener = CreateFrame("Frame")
recheckInterruptListener:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
recheckInterruptListener:SetScript("OnEvent", function(self, event, unit, _, spellID)
    local summonSpells = {
        [688] = true,    -- Summon Imp
        [691] = true,    -- Summon Felhunter
        [712] = true,    -- Summon Voidwalker
        [713] = true,    -- Summon Succubus
        [108503] = true, -- Grimoire of Service
        [34433] = true,  -- Shadowfiend
    }
    if summonSpells[spellID] then
        BBF.InitializeInterruptSpellID()
    end
end)
```

---

## Code to Remove Entirely

| Code | Lines | Reason |
|---|---|---|
| All focus castbar code | 505-506, 538-540, 545, 734-836, 971-991, 1008-1014, 1023-1025 | FocusFrame doesn't exist in Era (~100 lines) |
| `resetCastbarColor` | 609-615 | Both branches identical. Inline `castbar:SetStatusBarColor(1, 0.702, 0)` directly. |
| Commented-out Evoker hook | 1067-1088 | Dead code |
| Commented-out InterruptGlow sizing | 868-877 | Dead code |
| Commented-out loading screen strata | 1051-1064 | Dead code |
| Commented-out throttle logic | 635-639, 736-740 | Dead code |
| Commented-out BorderShield blocks | 232-235, 909-913, 1037-1041 | Dead code |
| Unused throttle variables | 549-551 | Dead code (`targetLastUpdate`, `focusLastUpdate`, `updateInterval`) |
| Duplicate target sizing | 943-968 | Replaced by `StyleBar` call |
| Duplicate party/pet creation | 273-360 | Replaced by `CreateBar` |
| Duplicate party/pet test mode | 363-472 | Replaced by unified `CastbarTestMode` |
| Unused `GetPartyMemberFrame` | 42-68 | Defined but never called; `UpdateCastbars` duplicates the search inline |

---

## DB Key Inconsistencies (Documented, Not Migrated)

The following 7 keys use inconsistent casing or word order. They are **not** being renamed in this refactor. The code accesses each key by its actual name. A comment block at the top of `castbar.lua` documents them for future reference.

```
-- DB key inconsistencies (kept as-is, documented here):
-- partyCastbarShowText        lowercase b, should be CastBar      (used in gui.lua, castbar.lua)
-- partyCastbarShowBorder      lowercase b, should be CastBar      (used in gui.lua, castbar.lua)
-- showPartyCastBarIcon        prefix "show" instead of suffix      (used in gui.lua, castbar.lua)
-- showPetCastBarIcon          prefix "show" instead of suffix      (used in gui.lua, castbar.lua)
-- targetCastbarEdgeHighlight  lowercase b, should be CastBar      (used in gui.lua, castbar.lua)
-- partyCastbarSelf            lowercase b, should be CastBar      (used in gui.lua, castbar.lua)
-- playerCastBarTimerCenter    missing "d", should be Centered      (used in gui.lua, castbar.lua)
```

**Why not migrate?** Migration saves 0 lines, touches 6 files, and carries medium risk (one missed key = silent nil = setting disappears). The inconsistency is cosmetic. The code works. String concatenation for key access (`db[prefix .. "CastBar" .. property]`) is harder to read and grep than literal key names. If migration is desired later, it can be done independently as a separate change.

**Keys in other files:** `targetDetachCastbar` and `targetStaticCastbar` are used in `auras.lua`. These are not in the inconsistent set — they use a different naming convention (`targetDetachCastbar` vs `targetCastBarDetach`) but are not castbar-module-specific keys and should not be renamed here.

---

## Build Order

Fresh file, built section by section. Each step adds a working section to `temp_era/modules/castbar_poc.lua`. Test after each step. The old `temp_cata/modules/castbar.lua` is never touched — swap the TOC back to verify the original still works anytime.

### Step 0: Branch + TOC setup

- Create branch `refactor/castbar` off `main`
- Create `temp_era/modules/castbar_poc.lua` with no-op stubs for all 12 `BBF.*` functions exported by the original module
- Update `BetterBlizzFrames_Vanilla.toc` to load `temp_era/modules/castbar_poc.lua` instead of `temp_cata/modules/castbar.lua`

The original `temp_cata/modules/castbar.lua` exports these 12 public functions. All must exist as no-op stubs from day one — `BetterBlizzFrames.lua` and `gui.lua` call them at load time and from callbacks:

```lua
function BBF.UpdateCastbars() end            -- gui.lua, BetterBlizzFrames.lua
function BBF.UpdatePetCastbar() end          -- gui.lua
function BBF.ChangeCastbarSizes() end        -- gui.lua, BetterBlizzFrames.lua
function BBF.partyCastBarTestMode() end      -- gui.lua
function BBF.petCastBarTestMode() end        -- gui.lua
function BBF.CreateCastbars() end            -- BetterBlizzFrames.lua (merged into UpdateCastbars in rewrite)
function BBF.CastBarTimerCaller() end        -- BetterBlizzFrames.lua (replaced by AttachTimerHook in rewrite)
function BBF.CastbarRecolorWidgets() end     -- gui.lua, BetterBlizzFrames.lua
function BBF.ShowPlayerCastBarIcon() end     -- gui.lua, BetterBlizzFrames.lua
function BBF.UpdateClassicCastbarTexture() end -- BetterBlizzFrames.lua
function BBF.InitializeInterruptSpellID() end  -- internal only, but called from event wiring
function BBF.HookCastbarsForEvoker() end     -- BetterBlizzFrames.lua (dead in Era, stub only)
```

As each step replaces a stub with a real implementation, remove the stub comment for that function. Stubs that remain at the end (e.g. `HookCastbarsForEvoker`) are dead in Era and can be cleaned up in a later pass.

**Test:** `/reload` — addon loads without errors, no castbars appear (stubs do nothing)

### Step 1: Helpers (~80 lines)

Write `CreateBar`, `StyleBar`, `FitBorder`, `AttachTimerHook` + local constants/vars. No `BBF.*` functions yet — nothing calls these helpers.

**Test:** `/reload` — no errors, no visible change

### Step 2: Addon-owned bars — party + pet (~80 lines)

Write `BBF.UpdateCastbars` (party) and `BBF.UpdatePetCastbar` (pet) using `CreateBar` + `StyleBar`.

**Test:** Join a party — party castbars appear. Summon a pet — pet castbar appears. Resize via GUI sliders. Toggle icons, text, borders, timers. Detach/reattach pet bar.

### Step 3: Blizzard-owned bars — player + target (~60 lines)

Write `BBF.ChangeCastbarSizes` using `StyleBar` for player (`CastingBarFrame`) and target (`TargetFrameSpellBar`).

**Test:** Cast a spell — player bar is styled. Target a mob — target bar is styled. Resize via GUI sliders. Toggle icons, text, borders, timers.

### Step 4: One-time hooks (~50 lines)

Write `EnsurePlayerHooks` (spark, OnShow icon, SetScale persistence, OnEvent texture) and `EnsureTargetHooks` (OnEvent texture, draw layers). Called from `ChangeCastbarSizes`.

**Test:** Cast a spell — spark tracks correctly on custom-width player bar. Player icon shows on cast start. Resize player bar, `/reload`, verify scale persisted. Target a casting mob — texture stays custom after Blizzard reset events.

### Step 5: Interrupt highlighting (~50 lines)

Write `SPELL_UPDATE_COOLDOWN` caching, `GetInterruptState`, `HookTargetInterruptHighlight`. Target-only (no focus in Era).

**Test:** Target interruptible mob — bar color changes based on interrupt CD state. Target uninterruptible mob — default color. Friendly target — default color.

### Step 6: Test mode (~40 lines)

Write unified `BBF.CastbarTestMode`, `BBF.partyCastBarTestMode`, `BBF.petCastBarTestMode`.

**Test:** Toggle party test mode — 5 bars animate. Toggle pet test mode — pet bar animates. Toggle off — bars disappear. Icons/timers respect settings.

### Step 7: Refresh + event wiring (~40 lines)

Write `BBF.RefreshCastbars`. Wire `GROUP_ROSTER_UPDATE` and `UNIT_PET` event frames. Add summon spell detection listener for interrupt spell refresh.

**Test:** `/reload` in a party — everything wires up. Leave/join party — bars update. Summon different pets — interrupt spell list refreshes.

### Step 8: gui.lua cleanup (separate commit)

Remove focus castbar GUI section from `temp_era/gui.lua` (dead in Era).

**Test:** Open BBF settings — no focus castbar section. All other castbar settings still work.

### Mitigations

- Each step is a commit — revert any single step without losing the rest
- Swap TOC back to `temp_cata/modules/castbar.lua` anytime to verify the original still works
- Test each bar type individually (party, pet, player, target)
- Verify borders/icons/text at default AND custom sizes
- Test with different party frame types (PartyMemberFrame, CompactPartyFrame, CompactRaidFrame)

---

## Design Decisions

### Why `StyleBar(bar, opts)` instead of Apply* primitives?

An earlier draft proposed 5 separate `Apply*` functions (`ApplyBarGeometry`, `ApplyTextLayout`, `ApplyTimerLayout`, `ApplyIconLayout`, `ApplyBorderLayout`) composed via adapter functions (`ApplyTemplateBarStyle`, `ApplyBlizzardBarStyle`). That's 7 functions for 4 bar types — more functions than bar types. Every caller always needs all five in sequence, so splitting them adds indirection without reuse. One `StyleBar` function does the same work in one pass. Each caller passes explicit values, making every call site self-documenting and greppable.

### Why no BAR_DEFAULTS lookup table?

An earlier draft used a `BAR_DEFAULTS` table mapping type names to per-type constants. For 2 addon-owned + 2 Blizzard-owned bars, a lookup table adds a layer of indirection for 4 entries. The constants are instead inline at each call site — visible where they're used, not hidden in a table. A lookup table becomes worthwhile at 6+ bar types; Classic Era will not add more.

### Why not migrate DB keys?

Migration saves 0 lines, touches 6 files, and carries medium risk (one missed key = silent nil = setting disappears). String concatenation for key access (`db[prefix .. "CastBar" .. property]`) is harder to read and grep than literal key names. The 7 inconsistent keys are documented in a comment block and accessed by their actual names.

### Why keep per-type icon offsets instead of normalizing to -4?

Player/target use `-5` offset, party/pet use `-4`. These have different visual contexts (Blizzard frames vs custom frames) and users have tuned their `IconXPos` settings relative to these baselines. Changing the baseline would shift all existing user configurations by 1 pixel.

### Why keep player icon as ARTWORK instead of normalizing to OVERLAY?

Player icon uses `ARTWORK` draw layer, others use `OVERLAY`. Changing this would alter visual stacking order (ARTWORK renders behind OVERLAY), potentially causing the player icon to appear in front of elements it was previously behind. Preserving existing behavior avoids visual regressions.

### Why OnUpdate instead of C_Timer.NewTicker for test mode?

cfCastbars uses OnUpdate with `GetTime()` delta for test animations. This is simpler (no external timer reference to cancel), self-cleaning (stops when `testStartTime` is nil), and consistent with how the rest of the castbar system works. The ticker approach required explicit `Cancel()` calls and stored a reference per bar.

### Why SPELL_UPDATE_COOLDOWN caching for interrupt state?

The original code called `GetSpellCooldown` for every interrupt spell ID on every frame (~60+ times/second). Interrupt cooldown state only changes on `SPELL_UPDATE_COOLDOWN`. Caching on that event and reading the cache in OnUpdate eliminates per-frame API calls. The aggregate-state computation (`GetInterruptState`) runs once per OnUpdate tick and returns a single result, replacing the loop-and-overwrite pattern that set color inside the iteration.

### Why expand summon spell detection?

Classic Era supports warlock summons (688, 691, 712, 713) and priest Shadowfiend (34433). The original code only checked 691 and 108503, missing most warlock variants and all priest summons. The interrupt spell list needs refreshing when any pet is summoned because different pets have different interrupt abilities (e.g., Felhunter has Spell Lock, Imp does not).

---

## Summary

| Metric | Before (`temp_cata/modules/castbar.lua`) | After (`temp_era/modules/castbar_poc.lua`) |
|---|---|---|
| Total lines | 1087 | ~700-750 |
| Focus code (dead in Era) | ~100 lines | Not brought over |
| Duplicated blocks | 6+ | 0 |
| Helpers | N/A | 4: `CreateBar`, `StyleBar`, `FitBorder`, `AttachTimerHook` |
| Places that read DB settings | ~50 scattered | Explicit at each `StyleBar` call site |
| Mystery boolean parameters | `adjustCastBarBorder(bar, border, 15, nil, nil, true)` | `FitBorder(bar, border, false, 55, 10)` + named constants |
| Inconsistent draw layers | 3 different values | Preserved per-type (intentional) |
| DB key inconsistencies | 7 keys | 7 keys (documented, not migrated) |
| Dead code | ~170 lines (70 commented + 100 focus) | None (fresh file, nothing carried over) |
| Known bugs | 3 (all in focus code) | 0 (focus code not brought over) |
| Hooks | Missing guards, bare module-scope hooks | All guarded, all inside Ensure* functions |
| Interrupt highlight | Loop-and-overwrite per frame, per-frame API calls | Aggregate state, event-driven CD caching |
| Build steps | N/A | 8 steps (0: setup, 1-7: sections, 8: gui cleanup) |
| Old file | N/A | Untouched — swap TOC back anytime |
| Files in scope | N/A | 3 (new `castbar_poc.lua`, TOC update, `gui.lua` focus section removal) |
