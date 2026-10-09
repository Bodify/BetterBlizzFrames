local RUNE_READY = 4
local HOLDER_KEYS = { "Background", "ActiveTexture", "Glow", "ThinGlow" }

local UNIT_FRAME_BARS = {
    ROGUE = "RogueComboPointBarFrame",
    DRUID = "DruidComboPointBarFrame",
    WARLOCK = "WarlockPowerFrame",
    MAGE = "MageArcaneChargesFrame",
    MONK = "MonkHarmonyBarFrame",
    EVOKER = "EssencePlayerFrame",
    PALADIN = "PaladinPowerBarFrame",
    DEATHKNIGHT = "RuneFrame",
}

local CUSTOM_BARS = {
    "ComboPointBar",
    "ComboPointTargetBar",
    "MaelstromWeaponBar",
    "MaelstromWeaponPrdBar",
    "TipOfSpearBar",
    "TipOfSpearPrdBar",
}

local prdSetupHooked

local function GetMode(isUnitFrame)
    local db = BetterBlizzFramesDB
    if not db or (isUnitFrame and not db.comboVisibilityUnitFrames) then return nil end
    if db.hideEmptyComboPoints then return "bar" end
    if db.onlyActiveComboPoints then return "points" end
end

local function GetPoints(bar)
    if bar.ComboPoints then return bar.ComboPoints end
    if bar.classResourceButtonTable then return bar.classResourceButtonTable end
    if bar.Runes then return bar.Runes end
    if not bar.rune1 then return nil end

    local runes = bar.bbRunePoints
    if not runes then
        runes = {}
        local i = 1
        while bar["rune" .. i] do
            runes[i] = bar["rune" .. i]
            i = i + 1
        end
        bar.bbRunePoints = runes
    end
    return runes
end

local function GetCount(bar)
    local powerType = bar.powerType or (bar.rune1 and Enum.PowerType.HolyPower)
    if not powerType then return 0 end
    return UnitPower(bar.unit or "player", powerType) or 0
end

local function IsActive(point, index, count)
    if point.runeIndex then
        return point.visualState == RUNE_READY
    end
    if point.fillAmount ~= nil then
        return point.fillAmount > 0
    end
    if point.isFull ~= nil then
        return point.isFull
    end
    return index <= count
end

local function SetHolderArtShown(bar, shown)
    local art = bar.bbHolderArt
    if not art then
        if shown then return end
        art = CreateFrame("Frame", nil, bar)
        art:SetAllPoints(bar)
        art:SetFrameLevel(bar:GetFrameLevel())
        for _, key in ipairs(HOLDER_KEYS) do
            local texture = bar[key]
            if texture and texture:GetParent() == bar then
                texture:SetParent(art)
            end
        end
        bar.bbHolderArt = art
    end
    art:SetAlpha(shown and 1 or 0)
end

local function Restore(bar)
    local touched = bar.bbComboVisPoints
    if not touched then return end
    for point in pairs(touched) do
        point:SetAlpha(1)
    end
    bar.bbComboVisPoints = nil
    if bar.bbHolderArt then
        bar.bbHolderArt:SetAlpha(1)
    end
end

function BBF.ApplyComboVisibility(bar, isUnitFrame, count)
    if not bar or bar:IsForbidden() then return end

    local mode = GetMode(isUnitFrame)
    if not mode then
        Restore(bar)
        return
    end

    local points = GetPoints(bar)
    if not points then return end
    count = count or GetCount(bar)

    local anyActive = false
    for i, point in ipairs(points) do
        if IsActive(point, i, count) then
            anyActive = true
            break
        end
    end

    local touched = bar.bbComboVisPoints
    if not touched then
        touched = setmetatable({}, { __mode = "k" })
        bar.bbComboVisPoints = touched
    end

    for i, point in ipairs(points) do
        local shown = anyActive and (mode == "bar" or IsActive(point, i, count))
        point:SetAlpha(shown and 1 or 0)
        touched[point] = true
    end

    if bar.rune1 then
        SetHolderArtShown(bar, mode ~= "bar" or anyActive)
    end
end

local function FramesControlsPrd()
    local fdb = BBF and BetterBlizzFramesDB
    local pdb = BBP and BetterBlizzPlatesDB
    if not pdb then return true end
    if not fdb then return false end
    local framesMode = fdb.hideEmptyComboPoints or fdb.onlyActiveComboPoints
    local platesMode = pdb.hideEmptyComboPoints or pdb.onlyActiveComboPoints
    if fdb.prdResourceAdjust then
        return (framesMode or not platesMode) and true or false
    end
    return (framesMode and not platesMode) and true or false
end

local function ApplyUnitFrameBar(bar)
    BBF.ApplyComboVisibility(bar, true)
end

local function ApplyPrdClassFrame(bar)
    if not FramesControlsPrd() then return end
    BBF.ApplyComboVisibility(bar, false)
end

local function HookBar(bar, apply)
    if not bar or bar.bbfComboVisHooked then return end
    local method = bar.Runes and "UpdateRunes" or "UpdatePower"
    if type(bar[method]) ~= "function" then return end
    bar.bbfComboVisHooked = true
    hooksecurefunc(bar, method, apply)
end

local function GetComboRing()
    local ring = ComboFrame
    if ring and ring.ComboPoints and ring ~= BBF.LegacyComboFrame and ring.Update then
        return ring
    end
end

local function HookComboRing(ring)
    if ring.bbfComboVisHooked then return end
    ring.bbfComboVisHooked = true
    hooksecurefunc(ring, "Update", ApplyUnitFrameBar)
end

local function HookPrdClassFrame()
    local prd = PersonalResourceDisplayFrame
    if not prd then return end
    HookBar(prd.classFrame, ApplyPrdClassFrame)
    if prdSetupHooked or not prd.SetupClassBar then return end
    prdSetupHooked = true
    hooksecurefunc(prd, "SetupClassBar", function(self)
        if not self.classFrame then return end
        HookBar(self.classFrame, ApplyPrdClassFrame)
        ApplyPrdClassFrame(self.classFrame)
    end)
end

function BBF.UpdateComboVisibility(fromPlates)
    local barName = UNIT_FRAME_BARS[UnitClassBase("player")]
    local unitBar = barName and _G[barName]
    if unitBar then
        if GetMode(true) then
            HookBar(unitBar, ApplyUnitFrameBar)
        end
        ApplyUnitFrameBar(unitBar)
    end

    local ring = GetComboRing()
    if ring then
        if GetMode(true) then
            HookComboRing(ring)
        end
        ApplyUnitFrameBar(ring)
    end

    local prd = PersonalResourceDisplayFrame
    if GetMode(false) and FramesControlsPrd() then
        HookPrdClassFrame()
    end
    if prd and prd.classFrame then
        ApplyPrdClassFrame(prd.classFrame)
    end

    for _, key in ipairs(CUSTOM_BARS) do
        local bar = BBF[key]
        if bar and bar.UpdatePower then
            bar:UpdatePower()
        end
    end

    if not fromPlates and BBP and BBP.UpdateComboVisibility then
        BBP.UpdateComboVisibility(true)
    end
end
