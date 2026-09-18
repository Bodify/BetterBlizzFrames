local boundRings = {}
local ringRefreshers = {}
local ringsForcedHidden = false

local function BindLevelRing(levelText, ring)
    if not levelText or not ring then return end
    if boundRings[ring] then return end
    boundRings[ring] = true

    local originalParent = levelText:GetParent()
    local anchoredToRing = true

    local function Refresh()
        if ring.bbfRefreshing then return end
        ring.bbfRefreshing = true
        local ownedByBlizzard = anchoredToRing and levelText:GetParent() == originalParent
        if ringsForcedHidden or not ownedByBlizzard then
            ring:Hide()
        else
            ring:Show()
            ring:SetAlpha(levelText:GetAlpha())
        end
        ring.bbfRefreshing = false
    end

    tinsert(ringRefreshers, Refresh)

    hooksecurefunc(levelText, "SetPoint", function(_, _, relativeTo)
        anchoredToRing = (relativeTo == ring)
        Refresh()
    end)

    hooksecurefunc(levelText, "SetParent", Refresh)
    hooksecurefunc(levelText, "SetAlpha", Refresh)
    hooksecurefunc(ring, "Show", function()
        if ringsForcedHidden and not ring.bbfRefreshing then
            Refresh()
        end
    end)

    Refresh()
end

function BBF.SetLevelRingsHidden(hidden)
    ringsForcedHidden = hidden and true or false
    BBF.BindLevelRings()
    for _, Refresh in ipairs(ringRefreshers) do
        Refresh()
    end
end

function BBF.BindLevelRings()
    if BBF.levelRingsBound then return end
    BBF.levelRingsBound = true

    local playerMain = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
    BindLevelRing(PlayerLevelText, playerMain.LevelBackgroundCircle)

    local function BindTargetStyle(frame)
        if not frame or not frame.TargetFrameContent then return end
        local main = frame.TargetFrameContent.TargetFrameContentMain
        BindLevelRing(main.LevelText, main.LevelBackgroundCircle)
    end

    BindTargetStyle(TargetFrame)
    BindTargetStyle(FocusFrame)
    for i = 1, MAX_BOSS_FRAMES or 5 do
        BindTargetStyle(_G["Boss" .. i .. "TargetFrame"])
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    BBF.BindLevelRings()
    BBF.ApplyPlayerLevelColor()
end)

local pvpBadgeRegions = {}
local pvpBadgeParents = {}

local function CollectPvpBadge(container)
    if not container then return end
    if container.PvpBackgroundCircle then
        tinsert(pvpBadgeRegions, container.PvpBackgroundCircle)
    end
    if container.PvpBackgroundIcon then
        tinsert(pvpBadgeRegions, container.PvpBackgroundIcon)
    end
end

function BBF.SetPvpBadgeShown(shown)
    if #pvpBadgeRegions == 0 then
        CollectPvpBadge(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain)
        CollectPvpBadge(TargetFrame.TargetFrameContent.TargetFrameContentContextual)
        if FocusFrame then
            CollectPvpBadge(FocusFrame.TargetFrameContent.TargetFrameContentContextual)
        end
        for _, region in ipairs(pvpBadgeRegions) do
            pvpBadgeParents[region] = region:GetParent()
        end
    end

    for _, region in ipairs(pvpBadgeRegions) do
        if shown then
            region:SetParent(pvpBadgeParents[region])
        else
            region:SetParent(BBF.hiddenFrame)
        end
    end
end

local specInfo = C_SpecializationInfo

function BBF.GetSpecialization()
    if GetSpecialization then return GetSpecialization() end
    if specInfo and specInfo.GetSpecialization then return specInfo.GetSpecialization() end
    return nil
end

function BBF.GetSpecializationInfo(specIndex)
    if not specIndex then return nil end
    if GetSpecializationInfo then return GetSpecializationInfo(specIndex) end
    if specInfo and specInfo.GetSpecializationInfo then return specInfo.GetSpecializationInfo(specIndex) end
    return nil
end

local PLAYER_LEVEL_R, PLAYER_LEVEL_G, PLAYER_LEVEL_B = 1.0, 0.82, 0.0

local function BBFOwnsLevelColor()
    local db = BetterBlizzFramesDB
    if not db then return false end
    if db.unitFrameFontColor and db.unitFrameFontColorLvl then return true end
    if db.classColorTargetNames and db.classColorLevelText then return true end
    return false
end

function BBF.ApplyPlayerLevelColor()
    if not UnitExists("player") then return end
    if BBFOwnsLevelColor() then return end
    local unit = PlayerFrame.unit
    if UnitLevel(unit) ~= UnitEffectiveLevel(unit) then return end
    PlayerLevelText:SetVertexColor(PLAYER_LEVEL_R, PLAYER_LEVEL_G, PLAYER_LEVEL_B, 1.0)
end

hooksecurefunc("PlayerFrame_UpdateLevel", BBF.ApplyPlayerLevelColor)

local BRONZE_R, BRONZE_G, BRONZE_B = 1, 0.678, 0.49
local bronzedTextures = {}

local function BronzeTintActive()
    local db = BetterBlizzFramesDB
    return db.classicFrames and db.classicFramesBronzeTint and not db.darkModeUi and not db.classColorFrameTexture
end

local function SetBronze(texture)
    texture.bbfBronzeChanging = true
    texture:SetVertexColor(BRONZE_R, BRONZE_G, BRONZE_B, 1)
    texture.bbfBronzeChanging = false
end

local function BronzeTexture(texture)
    if not texture or texture:IsForbidden() then return end
    if not texture.bbfBronzeHooked then
        texture.bbfBronzeHooked = true
        tinsert(bronzedTextures, texture)
        hooksecurefunc(texture, "SetVertexColor", function(self)
            if self.bbfBronzeChanging or not BronzeTintActive() then return end
            SetBronze(self)
        end)
    end
    SetBronze(texture)
end

local function GetUnitFrameBorderTextures()
    local textures = {
        PlayerFrame.PlayerFrameContainer.FrameTexture,
        PlayerFrame.PlayerFrameContainer.FrameTextureBBF,
        PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture,
        PlayerFrame.PlayerFrameContainer.VehicleFrameTexture,
        TargetFrame.TargetFrameContainer.FrameTexture,
        TargetFrame.TargetFrameContainer.FrameTextureBBF,
        TargetFrame.totFrame and TargetFrame.totFrame.FrameTexture,
        FocusFrame and FocusFrame.TargetFrameContainer.FrameTexture,
        FocusFrameToT and FocusFrameToT.FrameTexture,
        PetFrameTexture,
    }
    for i = 1, 5 do
        local boss = _G["Boss" .. i .. "TargetFrame"]
        if boss then
            tinsert(textures, boss.TargetFrameContainer.FrameTexture)
        end
    end
    if PartyFrame then
        for i = 1, 4 do
            local member = PartyFrame["MemberFrame" .. i]
            if member then
                tinsert(textures, member.Texture)
            end
        end
    end
    return textures
end

local PVP_CIRCLE_R, PVP_CIRCLE_G, PVP_CIRCLE_B = 1, 0.9, 0.19

local function GetPvpCircles()
    return {
        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundCircle,
        TargetFrame.TargetFrameContent.TargetFrameContentContextual.PvpBackgroundCircle,
        FocusFrame and FocusFrame.TargetFrameContent.TargetFrameContentContextual.PvpBackgroundCircle,
    }
end

function BBF.UpdateClassicPvpCircles()
    if not BetterBlizzFramesDB.classicFrames then return end
    local r, g, b = PVP_CIRCLE_R, PVP_CIRCLE_G, PVP_CIRCLE_B
    if BronzeTintActive() then
        r, g, b = BRONZE_R, BRONZE_G, BRONZE_B
    end
    for _, circle in pairs(GetPvpCircles()) do
        if not circle:IsForbidden() then
            circle:SetDesaturated(true)
            circle:SetVertexColor(r, g, b, 1)
        end
    end
end

function BBF.UpdateBronzeTint()
    BBF.UpdateClassicPvpCircles()
    if BronzeTintActive() then
        for _, texture in pairs(GetUnitFrameBorderTextures()) do
            BronzeTexture(texture)
        end
    elseif not BetterBlizzFramesDB.darkModeUi then
        for _, texture in ipairs(bronzedTextures) do
            if not texture:IsForbidden() then
                texture:SetVertexColor(1, 1, 1, 1)
            end
        end
    end
end

local bagSlotNames = {"MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot", "CharacterBag2Slot", "CharacterBag3Slot"}
local bagSlotIconNames = {"MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot", "CharacterBag2Slot", "CharacterBag3Slot", "CharacterReagentBag0Slot"}
local desaturatedIconNames = {"MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot", "CharacterBag2Slot", "CharacterBag3Slot", "CharacterReagentBag0Slot", "KeyRingButton"}
local actionButtonPrefixes = {"ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button", "PetActionButton", "StanceButton"}

local function ActionBarBronzeRemovalActive()
    local db = BetterBlizzFramesDB
    return db.removeActionBarBronzeTint and not (db.darkModeUi and db.darkModeActionBars)
end

local function ReapplyDesaturated(self)
    if self.bbfDesatChanging or not ActionBarBronzeRemovalActive() then return end
    self.bbfDesatChanging = true
    self:SetDesaturated(true)
    self.bbfDesatChanging = false
end

local function ForceDesaturated(texture)
    if not texture or texture:IsForbidden() then return end
    if not texture.bbfDesatHooked then
        texture.bbfDesatHooked = true
        hooksecurefunc(texture, "SetDesaturated", ReapplyDesaturated)
        hooksecurefunc(texture, "SetTexture", ReapplyDesaturated)
        hooksecurefunc(texture, "SetAtlas", ReapplyDesaturated)
    end
    texture:SetDesaturated(true)
end

function BBF.UpdateActionBarBronzeTint()
    if not ActionBarBronzeRemovalActive() then return end
    if BBF.ApplyActionBarArt then
        BBF.ApplyActionBarArt(true, 1, 1)
    end
    for _, slotName in ipairs(desaturatedIconNames) do
        local slot = _G[slotName]
        ForceDesaturated(slot and slot.icon)
    end
    for _, prefix in ipairs(actionButtonPrefixes) do
        for i = 1, 12 do
            local button = _G[prefix .. i]
            ForceDesaturated(button and button.SlotArt)
        end
    end
end

local bagSlotTextureKeys = {"NormalTexture", "PushedTexture", "HighlightTexture", "SlotHighlightTexture"}

local function ReapplyDarkModeColor(texture)
    if texture and texture.bbfHooked and not texture:IsForbidden() then
        texture:SetVertexColor(texture:GetVertexColor())
    end
end

function BBF.UpdateBagSlotTextures()
    for _, slotName in ipairs(bagSlotIconNames) do
        local slot = _G[slotName]
        if slot then
            if not slot.bbfBagSlotHooked and slot.UpdateTextures then
                slot.bbfBagSlotHooked = true
                hooksecurefunc(slot, "UpdateTextures", BBF.UpdateBagSlotTextures)
            end
            if slot.icon and (slot == MainMenuBarBackpackButton or not GetInventoryItemTexture("player", slot:GetID())) then
                slot.icon:SetAtlas("UI-HUD-ActionBar-IconFrame-Slot")
            end
        end
    end
    local source = CharacterReagentBag0Slot
    if not source then return end
    for _, key in ipairs(bagSlotTextureKeys) do
        local sourceTexture = source[key]
        local atlas = sourceTexture and sourceTexture:GetAtlas()
        if atlas then
            for _, slotName in ipairs(bagSlotNames) do
                local slot = _G[slotName]
                local texture = slot and slot[key]
                if texture then
                    texture:SetAtlas(atlas)
                end
            end
        end
    end
    for _, slotName in ipairs(bagSlotIconNames) do
        local slot = _G[slotName]
        if slot then
            ReapplyDarkModeColor(slot.NormalTexture)
            ReapplyDarkModeColor(slot.PushedTexture)
        end
    end
end

function BBF.ForeverTweaks()
    BBF.UpdateBagSlotTextures()
    BBF.UpdateBronzeTint()
    BBF.UpdateActionBarBronzeTint()
end
