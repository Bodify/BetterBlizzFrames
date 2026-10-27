-- Mana feedback fix
local function ResolveOverlayTexture(overlay)
    if not overlay then return nil end
    if overlay.SetAtlas then return overlay end
    if overlay.Fill and overlay.Fill.SetAtlas then return overlay.Fill end
    return nil
end

local function SyncBarTexture(overlay, src)
    local texture = ResolveOverlayTexture(overlay)
    if not texture then return end
    if texture.bbfTexture then
        texture:SetTexture(texture.bbfTexture)
        return
    end
    local atlas = src:GetAtlas()
    if atlas then
        texture:SetAtlas(atlas, false)
    else
        local file = src:GetTexture()
        if file then
            texture:SetTexture(file)
        end
    end
end

local function SyncFeedbackTexture(bar)
    local src = bar:GetStatusBarTexture()
    if not src then return end
    SyncBarTexture(bar.FeedbackFrame and bar.FeedbackFrame.BarTexture, src)
    SyncBarTexture(bar.ManaCostPredictionBar, src)
end

local function HookFeedback(bar)
    if not bar or bar.bbfFeedbackHooked then return end
    if not bar.FeedbackFrame and not ResolveOverlayTexture(bar.ManaCostPredictionBar) then return end
    bar.bbfFeedbackHooked = true
    hooksecurefunc(bar, "SetStatusBarTexture", SyncFeedbackTexture)
    if bar.FeedbackFrame then
        hooksecurefunc(bar.FeedbackFrame, "Initialize", function()
            SyncFeedbackTexture(bar)
        end)
    end
    SyncFeedbackTexture(bar)
end

function BBF.FixFeedbackTextures()
    local db = BetterBlizzFramesDB
    if not db.tweakExtraBarTextures then return end
    if not db.hideManaFeedback then
        HookFeedback(PlayerFrame and PlayerFrame.manabar)
    end

    if not db.hidePersonalManaFX and not db.hideManaFeedback then
        HookFeedback(PersonalResourceDisplayFrame and PersonalResourceDisplayFrame.PowerBar)
    end
end

-- Heal prediction fix
local healSegments = { "MyHealPredictionBar", "OtherHealPredictionBar", "HealAbsorbBar", "TotalAbsorbBar" }

local function SetSegmentFill(seg, tex, useDefault)
    if not seg or not seg.Fill then return end
    if useDefault and seg.fillAtlas then
        seg.Fill:SetAtlas(seg.fillAtlas, TextureKitConstants.IgnoreAtlasSize)
    else
        seg.Fill:SetTexture(tex)
    end
end

local BAR_TEX = "Interface\\AddOns\\BetterBlizzFrames\\media\\barTextures\\"
local plainSegmentFills = {
    [BAR_TEX .. "BlizzardRetailBarGreen"] = BAR_TEX .. "BlizzardRetailBar",
    [BAR_TEX .. "BlizzardForeverBarGreen"] = BAR_TEX .. "BlizzardForeverBar",
}

function BBF.SetHealSegmentFills(statusBar, tex)
    if tex then
        tex = plainSegmentFills[tex] or tex
    end
    statusBar.bbfSegmentFill = tex
    for i = 1, #healSegments do
        SetSegmentFill(statusBar[healSegments[i]], tex, not tex)
    end
end

local function SyncHealPredictionBar(bar, overlay, src)
    if bar.bbfSegmentFill then
        SetSegmentFill(overlay, bar.bbfSegmentFill)
    elseif overlay and overlay.fillAtlas and src:GetAtlas() then
        SetSegmentFill(overlay, nil, true)
    else
        SyncBarTexture(overlay, src)
    end
end

local function SyncHealPrediction(bar, myBar, otherBar)
    local src = bar:GetStatusBarTexture()
    if not src then return end
    SyncHealPredictionBar(bar, myBar, src)
    SyncHealPredictionBar(bar, otherBar, src)
end

local function HookHealPrediction(bar, myBar, otherBar)
    if not bar or bar.bbfHealPredictionHooked then return end
    if not ResolveOverlayTexture(myBar) and not ResolveOverlayTexture(otherBar) then return end
    bar.bbfHealPredictionHooked = true
    hooksecurefunc(bar, "SetStatusBarTexture", function()
        SyncHealPrediction(bar, myBar, otherBar)
    end)
    SyncHealPrediction(bar, myBar, otherBar)
end

local playerHealthBgLayer

local function PlayerHealthBgLevel()
    local health = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar
    return math.max(health:GetFrameLevel() - 2, 0)
end

function BBF.PlayerHealthBgParent(bar)
    local health = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar
    if bar ~= health then return end
    if not playerHealthBgLayer then
        playerHealthBgLayer = CreateFrame("Frame", nil, health)
        playerHealthBgLayer:SetAllPoints(health)
        playerHealthBgLayer:SetFrameLevel(PlayerHealthBgLevel())
    end
    return playerHealthBgLayer
end

function BBF.PlayerHealthLossBelowFill()
    local container = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    local loss = container.PlayerFrameHealthBarAnimatedLoss
    if not loss then return end
    if InCombatLockdown() and loss:IsProtected() then
        BBF.RunAfterCombat(BBF.PlayerHealthLossBelowFill)
        return
    end
    loss:SetUsingParentLevel(false)
    loss:SetFrameLevel(math.max(container.HealthBar:GetFrameLevel() - 1, 0))
    if playerHealthBgLayer then
        playerHealthBgLayer:SetFrameLevel(PlayerHealthBgLevel())
    end
end

function BBF.FixHealPredictionTextures()
    if not BetterBlizzFramesDB.tweakExtraBarTextures then return end
    local prd = PersonalResourceDisplayFrame
    local prdHealth = prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar
    if prdHealth then
        HookHealPrediction(prdHealth, prdHealth.myHealPrediction, prdHealth.otherHealPrediction)
    end

    local frames = { PlayerFrame, TargetFrame, FocusFrame }
    for i = 1, #frames do
        local frame = frames[i]
        local healthbar = frame and frame.healthbar
        if healthbar then
            HookHealPrediction(healthbar, frame.myHealPredictionBar, frame.otherHealPredictionBar)
        end
    end
end

local strataOrder = {
    BACKGROUND = 1,
    LOW = 2,
    MEDIUM = 3,
    HIGH = 4,
    DIALOG = 5,
    FULLSCREEN = 6,
    FULLSCREEN_DIALOG = 7,
    TOOLTIP = 8,
}

local function TargetArtTop()
    local topStrata, topLevel = TargetFrame:GetFrameStrata(), TargetFrame:GetFrameLevel()
    local function Check(art)
        if not art then return end
        local strata, level = art:GetFrameStrata(), art:GetFrameLevel()
        if strataOrder[strata] > strataOrder[topStrata] or (strata == topStrata and level > topLevel) then
            topStrata, topLevel = strata, level
        end
    end
    Check(TargetFrame.ClassicFrame)
    Check(TargetFrame.noPortraitMode)
    return topStrata, topLevel
end

function BBF.RaiseAboveTargetArt(frame, minStrata, levelBump)
    if not frame or not TargetFrame then return end
    local topStrata, topLevel = TargetArtTop()
    local strata = topStrata
    if minStrata and strataOrder[minStrata] > strataOrder[topStrata] then
        strata = minStrata
    end
    if frame.SetFixedFrameStrata then
        frame:SetFixedFrameStrata(false)
        frame:SetFixedFrameLevel(false)
    end
    frame:SetFrameStrata(strata)
    if strata == topStrata then
        frame:SetFrameLevel(math.min(topLevel + (levelBump or 20), 9998))
    end
    if frame.SetFixedFrameStrata then
        frame:SetFixedFrameStrata(true)
        frame:SetFixedFrameLevel(true)
    end
end

function BBF.ReleaseTargetArtLayer(frame)
    if frame and frame.SetFixedFrameStrata then
        frame:SetFixedFrameStrata(false)
        frame:SetFixedFrameLevel(false)
    end
end

function BBF.RaiseCombosAboveTargetArt()
    local legacyCombo = BBF.LegacyComboFrame
    if legacyCombo and legacyCombo:GetParent() == TargetFrame then
        BBF.RaiseAboveTargetArt(legacyCombo, "HIGH")
    end
    if BBF.RaiseBlizzardComboRing then
        BBF.RaiseBlizzardComboRing()
    end
    if BBF.ApplyComboPointTargetLayout then
        BBF.ApplyComboPointTargetLayout()
    end
    if BBF.RaiseMovedResourceAboveTargetArt then
        BBF.RaiseMovedResourceAboveTargetArt()
    end
end

local unsnappedBars = {}

local function UnsnapBarTexture(bar)
    local texture = bar:GetStatusBarTexture()
    if not texture then return end
    texture:SetTexelSnappingBias(0)
    texture:SetSnapToPixelGrid(false)
end

local function UnsnapOnTextureChange(bar)
    local owner = bar.unitFrame
    if BBF.ToTUnit(owner) and not BBF.ToTChanged(owner, bar) then return end
    UnsnapBarTexture(bar)
end

function BBF.UnsnapSmallFrameBars()
    local bars = { PetFrameHealthBar, PetFrameManaBar }
    for _, frame in ipairs({ TargetFrame, FocusFrame }) do
        local tot = frame and frame.totFrame
        if tot then
            bars[#bars + 1] = tot.HealthBar
            bars[#bars + 1] = tot.ManaBar
        end
    end
    for i = 1, 4 do
        local member = PartyFrame and PartyFrame["MemberFrame" .. i]
        if member then
            bars[#bars + 1] = member.HealthBarContainer and member.HealthBarContainer.HealthBar
            bars[#bars + 1] = member.ManaBar
        end
    end
    for _, bar in pairs(bars) do
        if bar.GetStatusBarTexture then
            UnsnapBarTexture(bar)
            if not unsnappedBars[bar] then
                unsnappedBars[bar] = true
                hooksecurefunc(bar, "SetStatusBarTexture", UnsnapOnTextureChange)
            end
        end
    end
end

local totFrames, totGen, totSeen = {}, {}, {}
local totWatcher

local function AddToTFrame(frame, unit)
    if not frame then return end
    totFrames[frame] = unit
    totGen[frame] = 1
    totSeen[frame] = {}
end
AddToTFrame(TargetFrameToT, "targettarget")
AddToTFrame(FocusFrameToT, "focustarget")

local function BumpToT(frame)
    local gen = totGen[frame]
    if gen then
        totGen[frame] = gen + 1
    end
end

local function BumpAllToT()
    for frame in pairs(totGen) do
        BumpToT(frame)
    end
end
BBF.RefreshToT = BumpAllToT

local function OnToTEvent(_, event)
    if event == "PLAYER_TARGET_CHANGED" then
        BumpToT(TargetFrameToT)
    elseif event == "PLAYER_FOCUS_CHANGED" then
        BumpToT(FocusFrameToT)
    else
        BumpAllToT()
    end
end

local function WatchToT()
    totWatcher = CreateFrame("Frame")
    totWatcher:RegisterEvent("PLAYER_TARGET_CHANGED")
    totWatcher:RegisterEvent("PLAYER_FOCUS_CHANGED")
    totWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    totWatcher:RegisterEvent("GROUP_ROSTER_UPDATE")
    totWatcher:RegisterEvent("PLAYER_REGEN_DISABLED")
    totWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
    totWatcher:RegisterEvent("ARENA_OPPONENT_UPDATE")
    totWatcher:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
    totWatcher:RegisterUnitEvent("UNIT_TARGET", "target", "focus")
    totWatcher:RegisterUnitEvent("UNIT_FACTION", "targettarget", "focustarget")
    totWatcher:RegisterUnitEvent("UNIT_CONNECTION", "targettarget", "focustarget")
    totWatcher:RegisterUnitEvent("UNIT_DISPLAYPOWER", "targettarget", "focustarget")
    totWatcher:RegisterUnitEvent("UNIT_NAME_UPDATE", "targettarget", "focustarget")
    totWatcher:SetScript("OnEvent", OnToTEvent)
    for frame in pairs(totFrames) do
        frame:HookScript("OnShow", BumpToT)
    end
end

function BBF.ToTUnit(frame)
    return frame and totFrames[frame]
end

function BBF.ToTChanged(frame, key)
    local gen = totGen[frame]
    if not gen then return true end
    if not totWatcher then
        WatchToT()
    end
    local seen = totSeen[frame]
    if seen[key] == gen then return false end
    seen[key] = gen
    return true
end
