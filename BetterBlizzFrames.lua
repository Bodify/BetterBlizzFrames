-- Setting up the database
BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}

-- My first addon, a lot could be done better but its a start for now
-- Things are getting more messy need a lot of cleaning lol

local addonVersion = "1.00" --too afraid to to touch for now
local addonUpdates = "1.0.8"
local sendUpdate = true
BBF.VersionNumber = addonUpdates
BBF.variablesLoaded = false

local defaultSettings = {
    version = addonVersion,
    updates = "empty",
    wasOnLoadingScreen = true,
    -- General
    removeRealmNames = true,
    centerNames = false,
    darkModeUi = false,
    darkModeColor = 0.20,
    hideGroupIndicator = false,
    hideFocusCombatGlow = false,
    targetToTScale = 1,
    focusToTScale = 1,
    targetToTXPos = 0,
    targetToTYPos = 0,
    focusToTXPos = 0,
    focusToTYPos = 0,
    targetToTAnchor = "BOTTOMRIGHT",
    focusToTAnchor = "BOTTOMRIGHT",
    targetToTCastbarAdjustment = true,
    focusToTCastbarAdjustment = true,
    playerReputationClassColor = true,

    --Sort group
    --sortGroupPlayerTop = true,
    --sortGroupPlayerBottom = false,

    -- Absorb Indicator
    absorbIndicatorScale = 1,
    playerAbsorbAnchor = "TOP",
    targetAbsorbAnchor = "TOP",
    playerAbsorbAmount = true,
    playerAbsorbIcon = true,
    targetAbsorbAmount = true,
    targetAbsorbIcon = true,
    focusAbsorbAmount = true,
    focusAbsorbIcon = true,
    playerAbsorbXPos = 0,
    playerAbsorbYPos = 0,
    targetAbsorbXPos = 0,
    targetAbsorbYPos = 0,
    --Combat Indicator
    combatIndicator = false,
    combatIndicatorShowSap = true,
    combatIndicatorShowSwords = true,
    playerCombatIndicator = true,
    targetCombatIndicator = true,
    focusCombatIndicator = true,
    combatIndicatorAnchor = "RIGHT",
    combatIndicatorScale = 1,
    combatIndicatorXPos = 0,
    combatIndicatorYPos = 0,

    --Party castbars
    partyCastBarScale = 1,
    partyCastBarIconScale = 1,
    partyCastBarXPos = 0,
    partyCastBarYPos = 0,
    partyCastBarWidth = 100,
    partyCastBarHeight = 12,
    partyCastBarTimer = false,
    showPartyCastBarIcon = true,

    --Pet Castbar
    petCastbar = false,
    petCastBarScale = 1,
    petCastBarIconScale = 1,
    petCastBarXPos = 0,
    petCastBarYPos = 0,
    petCastBarWidth = 103,
    petCastBarHeight = 10,
    showPetCastBarIcon = true,
    showPetCastBarTimer = false,

    --Target castbar
    targetCastBarScale = 1,
    targetCastBarIconScale = 1,
    targetCastBarXPos = 0,
    targetCastBarYPos = 0,
    targetCastBarWidth = 150,
    targetCastBarHeight = 10,
    targetCastBarTimer = false,

    --Focus castbar
    focusCastBarScale = 1,
    focusCastBarIconScale = 1,
    focusCastBarXPos = 0,
    focusCastBarYPos = 0,
    focusCastBarWidth = 150,
    focusCastBarHeight = 10,
    focusCastBarTimer = false,

    --Player castbar
    playerCastBarScale = 1,
    playerCastBarIconScale = 1,
    playerCastBarWidth = 208,
    playerCastBarHeight = 11,
    playerCastBarTimer = false,
    playerCastBarTimerCenter = false,

    --Auras
    --playerAuraMaxBuffsPerRow = 10,
    --playerAuraMaxDebuffsPerRow = 10,
    playerAuraSpacingX = 5,
    --playerAuraSpacingY = 3,
    maxBuffFrameBuffs = 32,
    maxDebuffFrameDebuffs = 16,
    printAuraSpellIds = false,
    showHiddenAurasIcon = true,
    PlayerAuraFrameBuffEnable = true,
    PlayerAuraFramedeBuffEnable = true,
    targetAndFocusAuraScale = 1,
    targetAndFocusAuraOffsetX = 0,
    targetAndFocusAuraOffsetY = 0,
    targetAndFocusHorizontalGap = 3,
    targetAndFocusVerticalGap = 4,
    targetAndFocusAurasPerRow = 6,

    frameAurasXPos = 0,
    frameAurasYPos = 0,
    frameAuraScale = 0,
    maxAurasOnFrame = 0,
    frameAuraRowAmount = 0,
    frameAuraWidthGap = 0,
    frameAuraHeightGap = 0,

    playerAuraFiltering = false,

    --Target buffs
    maxTargetBuffs = 32,
    maxTargetDebuffs = 16,
    targetBuffEnable = true,
    targetBuffFilterAll = true,
    targetBuffFilterWatchList = false,
    targetBuffFilterLessMinite = false,
    targetBuffFilterPurgeable = false,
    targetImportantAuraGlow = false,
    targetBuffFilterOnlyMe = false,
    --Target debuffs
    targetdeBuffEnable = true,
    targetdeBuffFilterAll = false,
    targetdeBuffFilterBlizzard = true,
    targetdeBuffFilterWatchList = false,
    targetdeBuffFilterLessMinite = false,
    targetdeBuffFilterOnlyMe = false,
    targetdeBuffPandemicGlow = false,

    --Focus buffs
    focusBuffEnable = true,
    focusBuffFilterAll = true,
    focusBuffFilterWatchList = false,
    focusBuffFilterLessMinite = false,
    focusBuffFilterOnlyMe = false,
    focusBuffFilterPurgeable = false,
    focusImportantAuraGlow = false,
    --Focus debuffs
    focusdeBuffEnable = true,
    focusdeBuffFilterAll = false,
    focusdeBuffFilterBlizzard = true,
    focusdeBuffFilterWatchList = false,
    focusdeBuffFilterLessMinite = false,
    focusdeBuffFilterOnlyMe = false,
    focusdeBuffPandemicGlow = false,

    PlayerAuraFrameBuffFilterWatchList = false,
    PlayerAuraFramedeBuffFilterWatchList = false,



    auraWhitelist = {
    },
    auraBlacklist = {
        {name = "Sign of the Skirmisher"},
        {name = "Sign of the Scourge"},
        {name = "Stormwind Champion"},
        {name = "Honorless Target"},
        {name = "Guild Champion"},
        {name = "Sign of Iron"},
        {id = 397734}, -- Word of a Worthy Ally
        {id = 186403}, -- Sign of Battle
        {id = 282559}, -- Enlisted
        {id = 32727}, -- Arena Preparation
        {id = 418563}, -- WoW's 19th Anniversary
        {id = 93805}, -- Ironforge Champion
    },
}

local function InitializeSavedVariables()
    if not BetterBlizzFramesDB then
        BetterBlizzFramesDB = {}
    end

    -- Check the stored version against the current addon version
    if not BetterBlizzFramesDB.version or BetterBlizzFramesDB.version ~= addonVersion then
        BetterBlizzFramesDB.version = addonVersion  -- Update the version number in the database
    end

    for key, defaultValue in pairs(defaultSettings) do
        if BetterBlizzFramesDB[key] == nil then
            BetterBlizzFramesDB[key] = defaultValue
        end
    end
end

local function FetchAndSaveValuesOnFirstLogin()
    -- Check if already saved the first login values
    if BetterBlizzFramesDB.hasSaved then
        return
    end



    local function GetUIInfo()
        if BBF.variablesLoaded then
            local function ShownChecker()
                if PlayerFrame:IsShown() then
                    BetterBlizzFramesDB.hidePrestigeBadge = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigeBadge:GetAlpha() ~= 1 or not PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigeBadge:IsShown()
                    BetterBlizzFramesDB.targetPrestigeBadgeAlpha = TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:GetAlpha() ~= 1 or not TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:IsShown()
                    BetterBlizzFramesDB.focusPrestigeBadgeAlpha = FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:GetAlpha() ~= 1 or not FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:IsShown()

--[[
                    print(BetterBlizzFramesDB.hideTargetPrestigeBadge)
                    BetterBlizzFramesDB.hideTargetPrestigeBadge = not TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait:IsShown()
                    print(BetterBlizzFramesDB.hideTargetPrestigeBadge)              
]]
                    BetterBlizzFramesDB.hasCheckedUi = true
                else
                    C_Timer.After(0.1, function()
                        ShownChecker()
                    end)
                end
            end
            ShownChecker()
        else
            C_Timer.After(1, function()
                GetUIInfo()
            end)
        end
    end
    GetUIInfo()


    C_Timer.After(5, function()
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames first run. Thank you for trying out my AddOn. Access settings with /bbf")
        BetterBlizzFramesDB.hasSaved = true
    end)
end

-- Define the popup window
StaticPopupDialogs["BetterBlizzFrames_COMBAT_WARNING"] = {
    text = "Leave combat to adjust this setting.",
    button1 = "Okay",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}


-- Update message
local function SendUpdateMessage()
    if sendUpdate then
        C_Timer.After(7, function()
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames " .. addonUpdates .. ":")
            DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Added \"Buffs on top\" aura logic for target and focus. Access settings with /bbf")
        end)
    end
end


local function CheckForUpdate()
    if not BetterBlizzFramesDB.hasSaved then
        BetterBlizzFramesDB.updates = addonUpdates
        return
    end
    if not BetterBlizzFramesDB.updates or BetterBlizzFramesDB.updates ~= addonUpdates then
        SendUpdateMessage()
        BetterBlizzFramesDB.updates = addonUpdates
    end
end

local function LoadingScreenDetector(_, event)
    if event == "PLAYER_ENTERING_WORLD" or event == "LOADING_SCREEN_ENABLED" then
        BetterBlizzFramesDB.wasOnLoadingScreen = true
    elseif event == "LOADING_SCREEN_DISABLED" or event == "PLAYER_LEAVING_WORLD" then
        if BetterBlizzFramesDB.playerFrameOCD then
            BBF.FixStupidBlizzPTRShit()
            BBF.ClassColorPlayerName()
        end
        C_Timer.After(2, function()
            BetterBlizzFramesDB.wasOnLoadingScreen = false
        end)
    end
end
local LoadingScreenFrame = CreateFrame("Frame")
LoadingScreenFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
LoadingScreenFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
LoadingScreenFrame:RegisterEvent("LOADING_SCREEN_ENABLED")
LoadingScreenFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
LoadingScreenFrame:SetScript("OnEvent", LoadingScreenDetector)

-- Function to check combat and show popup if in combat
function BBF.checkCombatAndWarn()
    if InCombatLockdown() then
        if not BetterBlizzFramesDB.wasOnLoadingScreen then
            if IsActiveBattlefieldArena() then
                return true -- Player is in combat but don't show the popup during arena
            else
                StaticPopup_Show("BetterBlizzFrames_COMBAT_WARNING")
                return true -- Player is in combat and outside of arena, so show the pop-up
            end
        end
    end
    return false -- Player is not in combat
end

function BBF.GetOppositeAnchor(anchor)
    local opposites = {
        LEFT = "RIGHT",
        RIGHT = "LEFT",
        TOP = "BOTTOM",
        BOTTOM = "TOP",
        TOPLEFT = "BOTTOMRIGHT",
        TOPRIGHT = "BOTTOMLEFT",
        BOTTOMLEFT = "TOPRIGHT",
        BOTTOMRIGHT = "TOPLEFT",
    }
    return opposites[anchor] or "CENTER"
end
--------------------------------------
-- Sort group
--------------------------------------
function BBF.SortGroup()
--[=[
    if BetterBlizzFramesDB.sortGroup then
        if BetterBlizzFramesDB.sortGroupPlayerTop then
            --RunNextFrame(function()
                CompactPartyFrame:SetFlowSortFunction(function(t1, t2)
                    if not UnitExists(t1) then
                        return false;
                    elseif not UnitExists(t2) then
                        return true
                    elseif UnitIsUnit(t1, 'player') then
                        return true;
                    elseif UnitIsUnit(t2, 'player') then
                        return false;
                    else
                        return t1 < t2;
                    end
                end)
            --end)
        elseif BetterBlizzFramesDB.sortGroupPlayerBottom then
            --RunNextFrame(function()
                CompactPartyFrame:SetFlowSortFunction(function(a, b)
                    if not UnitExists(a) then
                        return false
                    elseif not UnitExists(b) then
                        return true
                    elseif UnitIsUnit(a, "player") then
                        return false
                    elseif UnitIsUnit(b, "player") then
                        return true
                    else
                        return a < b
                    end
                end)
            --end)
        end
    end

]=]
end



--------------------------------------
-- CLICKTHROUGH
--------------------------------------
function BBF.ClickthroughFrames()
	if not InCombatLockdown() then
        local shift = IsShiftKeyDown()
        if BetterBlizzFramesDB.playerFrameClickthrough then
            PlayerFrame:SetMouseClickEnabled(shift)
        end

        if BetterBlizzFramesDB.targetFrameClickthrough then
            TargetFrame:SetMouseClickEnabled(shift)
            TargetFrameToT:SetMouseClickEnabled(false)
        end

        if BetterBlizzFramesDB.focusFrameClickthrough then
            FocusFrame:SetMouseClickEnabled(shift)
            FocusFrameToT:SetMouseClickEnabled(false)
        end
	end
end

--TODO Bodify, already in aura function, this is better perf tho so figure out how (debuffs only)
-- Make player debuffs clickthrough
local debuffFrame = DebuffFrame and DebuffFrame.AuraContainer
if debuffFrame then
    for i = 1, debuffFrame:GetNumChildren() do
        local child = select(i, debuffFrame:GetChildren())
        if child then
            child:SetMouseClickEnabled(false)
        end
    end
end

-- Warlock Alternate Power Clickthrough
local function DisableClickForWarlockPowerFrame()
    if WarlockPowerFrame then
        WarlockPowerFrame:SetMouseClickEnabled(false)
    end
end

-- Rogue Alternate Power Clickthrough
local function DisableClickForRogueComboPointBarFrame()
    if RogueComboPointBarFrame then
        RogueComboPointBarFrame:SetMouseClickEnabled(false)
    end
end

-- Druid Alternate Power Clickthrough
local function DisableClickForDruidComboPointBarFrame()
    if DruidComboPointBarFrame then
        DruidComboPointBarFrame:SetMouseClickEnabled(false)
    end
end

-- Paladin Alternate Power Clickthrough
local function DisableClickForPaladinPowerBarFrame()
    if PaladinPowerBarFrame then
        PaladinPowerBarFrame:SetMouseClickEnabled(false)
    end
end

-- Death Knight Alternate Power Clickthrough
local function DisableClickForRuneFrame()
    if RuneFrame then
        RuneFrame:SetMouseClickEnabled(false)
    end
end

-- Evoker Alternate Power Clickthrough
local function DisableClickForEssencePlayerFrame()
    if EssencePlayerFrame then
        EssencePlayerFrame:SetMouseClickEnabled(false)
    end
end

local function DisableClickForClassSpecificFrame()
    local _, playerClass = UnitClass("player")
    if playerClass == "WARLOCK" and WarlockPowerFrame then
        hooksecurefunc(WarlockPowerBar, "UpdatePower", DisableClickForWarlockPowerFrame)
    elseif playerClass == "ROGUE" and RogueComboPointBarFrame then
        hooksecurefunc(RogueComboPointBarFrame, "UpdatePower", DisableClickForRogueComboPointBarFrame)
    elseif playerClass == "DRUID" and DruidComboPointBarFrame then
        hooksecurefunc(DruidComboPointBarFrame, "UpdatePower", DisableClickForDruidComboPointBarFrame)
    elseif playerClass == "PALADIN" and PaladinPowerBarFrame then
        hooksecurefunc(PaladinPowerBar, "UpdatePower", DisableClickForPaladinPowerBarFrame)
    elseif playerClass == "DEATHKNIGHT" and RuneFrame then
        hooksecurefunc(RuneFrame, "UpdateRunes", DisableClickForRuneFrame)
    elseif playerClass == "EVOKER" and EssencePlayerFrame then
        hooksecurefunc(EssencePlayerFrame, "UpdatePower", DisableClickForEssencePlayerFrame)
    end
end

local ClickthroughFrames = CreateFrame("frame")
ClickthroughFrames:SetScript("OnEvent", function()
    BBF.ClickthroughFrames()
end)
ClickthroughFrames:RegisterEvent("MODIFIER_STATE_CHANGED")




function BBF.MoveToTFrames()
    TargetFrameToT:ClearAllPoints()
    if BetterBlizzFramesDB.targetToTAnchor == "BOTTOMRIGHT" then
	    TargetFrameToT:SetPoint(BBF.GetOppositeAnchor(BetterBlizzFramesDB.targetToTAnchor),TargetFrame,BetterBlizzFramesDB.targetToTAnchor,BetterBlizzFramesDB.targetToTXPos - 108,BetterBlizzFramesDB.targetToTYPos + 10)
    else
        TargetFrameToT:SetPoint(BBF.GetOppositeAnchor(BetterBlizzFramesDB.targetToTAnchor),TargetFrame,BetterBlizzFramesDB.targetToTAnchor,BetterBlizzFramesDB.targetToTXPos,BetterBlizzFramesDB.targetToTYPos)
    end
    TargetFrameToT:SetScale(BetterBlizzFramesDB.targetToTScale)
	--TargetFrameToT.SetPoint=function()end

    FocusFrameToT:ClearAllPoints()
    if BetterBlizzFramesDB.focusToTAnchor == "BOTTOMRIGHT" then
	    FocusFrameToT:SetPoint(BBF.GetOppositeAnchor(BetterBlizzFramesDB.focusToTAnchor),FocusFrame,BetterBlizzFramesDB.focusToTAnchor,BetterBlizzFramesDB.focusToTXPos - 108,BetterBlizzFramesDB.focusToTYPos + 10)
    else
        FocusFrameToT:SetPoint(BBF.GetOppositeAnchor(BetterBlizzFramesDB.focusToTAnchor),FocusFrame,BetterBlizzFramesDB.focusToTAnchor,BetterBlizzFramesDB.focusToTXPos,BetterBlizzFramesDB.focusToTYPos)
    end
    FocusFrameToT:SetScale(BetterBlizzFramesDB.focusToTScale)
    --FocusFrameToT.SetPoint=function()end
end


function BBF.FixStupidBlizzPTRShit()
    if InCombatLockdown() then return end
    -- For god knows what reason PTR has a gap between Portrait and PlayerFrame. This fixes it.
    PlayerFrame.PlayerFrameContainer.PlayerPortrait:SetScale(1.02)
    PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetScale(1.09)
    PlayerFrame.PlayerFrameContainer.PlayerPortrait:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", 24, -18)
    PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetSize(60,61)
    PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", 20, -15)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea.HealthBar.HealthBarMask:SetHeight(33)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.ManaBarMask:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar, "TOPLEFT", -2, 3)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.ManaBarMask:SetHeight(17)
    PlayerFrame.healthbar:SetHeight(21)
    PlayerFrame.manabar:SetSize(125,12)
    local p, r, rr, x, y = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:GetPoint()
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:SetPoint(p, r, rr, -3, 0)
    --local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:GetPoint()
    --TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:ClearAllPoints()
    --TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:SetPoint(a, b, c, d, 99)
    TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBar.HealthBarMask:SetWidth(129)
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetSize(136, 10)
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.ManaBarMask:SetSize(258, 16)
    local point, relativeTo, relativePoint, xOffset, yOffset = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetPoint(point, relativeTo, relativePoint, 9, yOffset)
    local p, r, rr, x, y = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:SetPoint(p, r, rr, -14, y)
    local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:SetPoint(a,b,c,3,e)
    FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBar.HealthBarMask:SetWidth(129)
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetSize(136, 10)
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.ManaBarMask:SetSize(258, 16)
    local point, relativeTo, relativePoint, xOffset, yOffset = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetPoint(point, relativeTo, relativePoint, 9, yOffset)
    local p, r, rr, x, y = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:SetPoint(p, r, rr, -14, y)
    local a, b, c, d, e = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:SetPoint(a,b,c,3,e)

    local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetPoint(a, b, c, d, -3)

    local a, b, c, d, e = FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetPoint(a, b, c, d, -3)

    local a, b, c, d, e = PlayerLevelText:GetPoint()
    PlayerLevelText:SetPoint(a,b,c,d,-28)
    --ToT
    local a, b, c, d, e = TargetFrame.totFrame.HealthBar:GetPoint()
    TargetFrame.totFrame.HealthBar:SetPoint(a,b,c,-5,-3)
    TargetFrame.totFrame.HealthBar:SetSize(71, 13)
    --anchor x = 5
    TargetFrame.totFrame.ManaBar:SetSize(77, 8)
    local a, b, c, d, e = TargetFrame.totFrame.ManaBar:GetPoint()
    TargetFrame.totFrame.ManaBar:SetPoint(a,b,c,-5,0)
    --anchor x = -5
    local a, b, c, d, e = TargetFrame.totFrame.Portrait:GetPoint()
    TargetFrame.totFrame.Portrait:SetPoint(a, b, c, 6, e)
    local a, b, c, d, e = FocusFrame.totFrame.HealthBar:GetPoint()
    FocusFrame.totFrame.HealthBar:SetPoint(a,b,c,-5,-3)
    FocusFrame.totFrame.HealthBar:SetSize(71, 13)
    --anchor x = 5
    FocusFrame.totFrame.ManaBar:SetSize(77, 8)
    local a, b, c, d, e = FocusFrame.totFrame.ManaBar:GetPoint()
    FocusFrame.totFrame.ManaBar:SetPoint(a,b,c,-5,0)
    --anchor x = -5
    local a, b, c, d, e = FocusFrame.totFrame.Portrait:GetPoint()
    FocusFrame.totFrame.Portrait:SetPoint(a, b, c, 6, e)
    for i = 1, 4 do
        local memberFrame = PartyFrame["MemberFrame" .. i]
        if memberFrame and memberFrame.Portrait then
            memberFrame.Portrait:SetHeight(38)
        end
    end

    TargetFrame.totFrame.HealthBar:SetHeight(12)
    local a, b, c, d, e = TargetFrame.totFrame.HealthBar:GetPoint()
    TargetFrame.totFrame.HealthBar:SetPoint(a, b, c, d, -4)

    local a,b,c,d,e = TargetFrame.totFrame.ManaBar:GetPoint()
    TargetFrame.totFrame.ManaBar:SetPoint(a,b,c,-4,1)

    FocusFrame.totFrame.HealthBar:SetHeight(12)
    local a, b, c, d, e = FocusFrame.totFrame.HealthBar:GetPoint()
    FocusFrame.totFrame.HealthBar:SetPoint(a, b, c, d, -4)

    local a,b,c,d,e = FocusFrame.totFrame.ManaBar:GetPoint()
    FocusFrame.totFrame.ManaBar:SetPoint(a,b,c,-4,1)

    local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetPoint(a, b, c, d, -24)
    --TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetHeight()

    local a, b, c, d, e = FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetPoint(a, b, c, d, -24)
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetHeight(20)

    FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetHeight(20)
end

local function TurnTestModesOff()
    BetterBlizzFramesDB.absorbIndicatorTestMode = false
    BetterBlizzFramesDB.partyCastBarTestMode = false
    BetterBlizzFramesDB.petCastBarTestMode = false
end

-- Event registration for PLAYER_LOGIN
local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")
--Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", function(...)

    CheckForUpdate()
    --BBF.HideFrames()
    DisableClickForClassSpecificFrame()
    BBF.MoveToTFrames()
    C_Timer.After(1, function()
       -- BBF.HideFrames()
        --BBF.MoveToTFrames()
       -- BBF.ChangeCastbarSizes()
        if BetterBlizzFramesDB.partyCastbars then
            --BBF.CreateCastbars()
        end
    end)

    local function LoginVariablesLoaded()
        if BBF.variablesLoaded then
            BBF.CastBarTimerCaller()
            BBF.ShowPlayerCastBarIcon()
            BBF.CombatIndicator(PlayerFrame, "player")
            if BetterBlizzFramesDB.hideArenaFrames then
                BBF.HideArenaFrames()
            end
            BBF.MoveToTFrames()
            local hidePartyName = BetterBlizzFramesDB.hidePartyNames
            local hidePartyRole = BetterBlizzFramesDB.hidePartyRoles
            if hidePartyName or hidePartyRole then
                BBF.OnUpdateName()
            end
            if BetterBlizzFramesDB.removeRealmNames or (BetterBlizzFramesDB.partyArenaNames or BetterBlizzFramesDB.targetAndFocusArenaNames) then
                BBF.AllCaller()
            end
            if BetterBlizzFramesDB.playerFrameOCD then
                BBF.FixStupidBlizzPTRShit()
            end
            BBF.SortGroup()
            C_Timer.After(1, function()
                if BetterBlizzFramesDB.playerFrameOCD then
                    BBF.FixStupidBlizzPTRShit()
                end
                if BetterBlizzFramesDB.classColorFrames then
                    BBF.UpdateFrames()
                end
                BBF.SetCenteredNamesCaller()
                BBF.DarkmodeFrames()
                BBF.PlayerReputationColor()
                BBF.ClassColorPlayerName()
            end)
            BBF.HideFrames()
            if BetterBlizzFramesDB.partyCastbars then
                BBF.CreateCastbars()
            end
            BBF.ChangeCastbarSizes()

        else
            C_Timer.After(1, function()
                LoginVariablesLoaded()
            end)
        end
    end
    LoginVariablesLoaded()

    if BetterBlizzFramesDB.reopenOptions then
        InterfaceOptionsFrame_OpenToCategory(BetterBlizzFrames)
        BetterBlizzFramesDB.reopenOptions = false
    end
end)

-- Slash command
SLASH_BBF1 = "/BBF"
SlashCmdList["BBF"] = function(msg)
    InterfaceOptionsFrame_OpenToCategory(BetterBlizzFrames)
end

-- Event registration for PLAYER_LOGIN
local First = CreateFrame("Frame")
First:RegisterEvent("ADDON_LOADED")
First:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName then
        if addonName == "BetterBlizzFrames" then
            BetterBlizzFramesDB.wasOnLoadingScreen = true

            InitializeSavedVariables()
            FetchAndSaveValuesOnFirstLogin()
            TurnTestModesOff()
            --TurnOnEnabledFeaturesOnLogin()
            BBF.InitializeOptions()
        end
    end
end)

local function OnVariablesLoaded(self, event)
    if event == "VARIABLES_LOADED" then
        BBF.variablesLoaded = true
    end
end

-- Register the frame to listen for the "VARIABLES_LOADED" event
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:SetScript("OnEvent", OnVariablesLoaded)

local PlayerEnteringWorld = CreateFrame("frame")
PlayerEnteringWorld:SetScript("OnEvent", function()
    BBF.DarkmodeFrames()
    BBF.ClickthroughFrames()
end)
PlayerEnteringWorld:RegisterEvent("PLAYER_ENTERING_WORLD")