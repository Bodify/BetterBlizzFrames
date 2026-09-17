local TIP_OF_THE_SPEAR = 260286
local MAX_POINTS = 3
local SURVIVAL_SPEC_INDEX = 3
local PRD_Y_OFFSET = 9

local playerBar, prdBar, updater, specWatcher, legacyActive

local function GetStacks()
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(TIP_OF_THE_SPEAR)
    return (aura and aura.applications) or 0
end

local function SetPointInstant(point, isFull)
    point:ResetVisuals()
    point.isFull = isFull
    point.isCharged = false

    point.BGActive:SetAlpha(isFull and 1 or 0)
    point.BGInactive:SetAlpha(isFull and 0 or 1)
    point.IconUncharged:SetAlpha(isFull and 1 or 0)
    point.FXUncharged:SetAlpha(isFull and 1 or 0)
    point.IconCharged:SetAlpha(0)
    point.FXCharged:SetAlpha(0)
    point.ChargedFrameActive:SetAlpha(0)
    point.ChargedFrameInactive:SetAlpha(0)
end

local function UpdateBar(bar, stacks)
    if not bar then return end
    local instant = BetterBlizzFramesDB.instantComboPoints
    for i = 1, MAX_POINTS do
        local point = bar.classResourceButtonTable[i]
        if point then
            local isFull = i <= stacks
            if instant then
                SetPointInstant(point, isFull)
            else
                point:Update(isFull, false)
            end
        end
    end
end

local function RecolorUnchargedArt(point)
    point.IconUncharged:SetAtlas("uf-roguecp-icon-blue", true)
    point.FXUncharged:SetAtlas("uf-roguecp-fx-blue", true)
    point.SlashFBUncharged:SetAtlas("uf-roguecp-slash-blue")

    point.IconUncharged:SetDesaturated(true)
    point.FXUncharged:SetDesaturated(true)
    point.SlashFBUncharged:SetDesaturated(true)

    point.IconUncharged:SetVertexColor(0.49, 1, 0.361, 1)
    point.FXUncharged:SetVertexColor(0.49, 1, 0.361, 1)
    point.SlashFBUncharged:SetVertexColor(0.49, 1, 0.361, 1)
end

local function CreatePoint(bar, index)
    local point = CreateFrame("Frame", nil, bar, "RogueComboPointTemplate")
    point.layoutIndex = index
    RecolorUnchargedArt(point)
    point:Setup()
    return point
end

local function CreateBar(name, parent)
    local bar = CreateFrame("Frame", name, parent, "HorizontalLayoutFrame")
    bar.spacing = 4
    bar.topPadding = 10
    bar.leftPadding = 0
    bar.maxUsablePoints = MAX_POINTS
    bar.powerType = Enum.PowerType.ComboPoints
    bar.classResourceButtonTable = {}

    for i = 1, MAX_POINTS do
        bar.classResourceButtonTable[i] = CreatePoint(bar, i)
    end

    bar.UpdatePower = function(self)
        UpdateBar(self, GetStacks())
    end

    bar:Layout()
    return bar
end

local function LegacyOwnsDisplay()
    return BetterBlizzFramesDB.enableLegacyComboPoints
        and BetterBlizzFramesDB.enableLegacyComboPointsMulticlass
        and C_CVar.GetCVar("comboPointLocation") == "1"
        and not BetterBlizzFramesDB.ignoreHunterLegacyCombos
end

local function PlatesWantsBar()
    local pdb = BBP and BetterBlizzPlatesDB
    return pdb and pdb.hunterTipOfSpearCombos and not pdb.disablePrdMovement
        and not BetterBlizzFramesDB.prdResourceAdjust and true or false
end

local function PlatesCoversPrd()
    if not PlatesWantsBar() then return false end
    local pdb = BetterBlizzPlatesDB
    local onTarget = pdb.nameplateResourceOnTarget == "1" or pdb.nameplateResourceOnTarget == true
    return not onTarget or pdb.nameplateResourceOnTargetAndNoTargetOnSelf == true
end

function BBF.TipOfSpearPlatesShouldShow()
    if not BetterBlizzFramesDB.hunterTipOfSpearCombos or LegacyOwnsDisplay() then return true end
    return PlatesWantsBar()
end

local function AnchorPrdBarToPrd(xOfs, yOfs)
    local prd = PersonalResourceDisplayFrame
    if not prd then return end

    local y = PRD_Y_OFFSET - prd:GetBarPadding()
    local point, relativeTo, relativePoint = "TOP", prd, "TOP"
    if prd.AlternatePowerBar and prd.AlternatePowerBar:IsShown() then
        relativeTo, relativePoint = prd.AlternatePowerBar, "BOTTOM"
    elseif not prd.hidePower then
        relativeTo, relativePoint = prd.PowerBar, "BOTTOM"
    elseif not prd.hideHealth then
        relativeTo, relativePoint = prd.HealthBarsContainer, "BOTTOM"
    else
        y = PRD_Y_OFFSET
    end
    prdBar:SetParent(prd)
    prdBar:ClearAllPoints()
    prdBar:SetPoint(point, relativeTo, relativePoint, xOfs or 0, y + (yOfs or 0))
end

function BBF.UpdateTipOfSpearPrdAnchor()
    if not prdBar then return end

    if BetterBlizzFramesDB.prdResourceAdjust then
        BBF.UpdatePrdResource()
        return
    end

    prdBar:SetScale(1)
    prdBar:SetFrameStrata("MEDIUM")
    AnchorPrdBarToPrd()
end

local function CreatePrdBar()
    local prd = PersonalResourceDisplayFrame
    if not prd then return end

    prdBar = CreateBar("BBFTipOfTheSpearBarPRD", prd)
    BBF.TipOfSpearPrdBar = prdBar
    prdBar.bbfPrdRestore = AnchorPrdBarToPrd
    AnchorPrdBarToPrd()

    hooksecurefunc(prd, "UpdateAdditionalBarAnchors", BBF.UpdateTipOfSpearPrdAnchor)

    if BBF.DarkModeNameplateResources then
        BBF.DarkModeNameplateResources()
    end
end

function BBF.UpdateTipOfSpearBar()
    if not playerBar then return end

    local show = BetterBlizzFramesDB.hunterTipOfSpearCombos
        and BBF.GetSpecialization() == SURVIVAL_SPEC_INDEX and not LegacyOwnsDisplay()
    local showPrd = show and not PlatesCoversPrd()
    if showPrd and not prdBar then
        CreatePrdBar()
        BBF.UpdateTipOfSpearPrdAnchor()
    end

    playerBar:SetShown(show)
    if prdBar then
        prdBar:SetShown(showPrd)
    end
    if not show then return end

    playerBar:UpdatePower()
    if showPrd and prdBar then
        prdBar:UpdatePower()
    end
end

local function CreateUpdater()
    updater = CreateFrame("Frame")
    updater:RegisterUnitEvent("UNIT_AURA", "player")
    updater:RegisterEvent("PLAYER_ENTERING_WORLD")
    updater:RegisterEvent("PLAYER_TARGET_CHANGED")
    updater:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    updater:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    updater:SetScript("OnEvent", function(_, event)
        if event == "UNIT_AURA" then
            BBF.UpdateTipOfSpearBar()
        elseif event == "PLAYER_ENTERING_WORLD" then
            BBF.UpdateTipOfSpearBar()
            BBF.UpdateTipOfSpearPrdAnchor()
        else
            BBF.UpdateTipOfSpearPrdAnchor()
        end
    end)
end

function BBF.CreateTipOfSpearBar()
    if not BetterBlizzFramesDB.hunterTipOfSpearCombos then return end
    if UnitClassBase("player") ~= "HUNTER" then return end
    if BBF.TipOfSpearBarsBuilt then
        BBF.UpdateTipOfSpearBar()
        return
    end

    if not specWatcher then
        specWatcher = CreateFrame("Frame")
        specWatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        specWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
        specWatcher:SetScript("OnEvent", function()
            BBF.CreateTipOfSpearBar()
        end)
    end

    if BBF.GetSpecialization() ~= SURVIVAL_SPEC_INDEX then return end

    playerBar = CreateBar("BBFTipOfTheSpearBar", PlayerFrame)
    playerBar:SetPoint("TOP", PlayerBottomManagedFrameContainer, "TOP", 0, 7)
    BBF.TipOfSpearBar = playerBar

    BBF.resourceFrames.HUNTER = playerBar
    BBF.classPowerFrames.HUNTER = playerBar

    CreateUpdater()

    BBF.TipOfSpearBarsBuilt = true
    BBF.UpdateTipOfSpearBar()
    BBF.UpdateTipOfSpearPrdAnchor()
end

function BBF.HunterLegacyTipOfSpear()
    if not BetterBlizzFramesDB.hunterTipOfSpearCombos then return end
    if UnitClassBase("player") ~= "HUNTER" then return end
    if legacyActive then return end
    if not LegacyOwnsDisplay() then return end
    if not ComboFrame or not ComboFrame.ComboPoints then return end

    local function UpdateHunterLegacyCombo()
        local frame = ComboFrame
        if not frame.ComboPoints then return end

        local stacks = BBF.GetSpecialization() == SURVIVAL_SPEC_INDEX and GetStacks() or 0
        local showAlways = BetterBlizzFramesDB.alwaysShowLegacyComboPoints
        local comboIndex = 2

        for i = 1, MAX_POINTS do
            local point = frame.ComboPoints[comboIndex]
            if point then
                local isActive = i <= stacks
                point:Show()
                point:SetAlpha(1)
                point:SetShown(showAlways or isActive)

                if point.Highlight then
                    point.Highlight:SetAlpha(isActive and 1 or 0)
                end

                comboIndex = comboIndex + 1
            end
        end

        if stacks == 0 and not showAlways then
            frame:Hide()
        else
            frame:SetAlpha(1)
            frame:Show()
        end

        BBF.UIFrameFadeRemoveFrame(frame)
    end

    hooksecurefunc("ComboFrame_Update", UpdateHunterLegacyCombo)

    local auraWatch = CreateFrame("Frame")
    auraWatch:RegisterUnitEvent("UNIT_AURA", "player")
    auraWatch:RegisterEvent("PLAYER_ENTERING_WORLD")
    auraWatch:SetScript("OnEvent", UpdateHunterLegacyCombo)

    legacyActive = true
    UpdateHunterLegacyCombo()
end
