-- Setting up the database
BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}

-- My first addon, a lot could be done better but its a start for now
-- Things are getting more messy need a lot of cleaning lol

local addonVersion = "1.00" --too afraid to to touch for now
local addonUpdates = "1.4.3"
local sendUpdate = true
BBF.VersionNumber = addonUpdates
BBF.variablesLoaded = false
local isAddonLoaded = C_AddOns.IsAddOnLoaded

local defaultSettings = {
    version = addonVersion,
    updates = "empty",
    wasOnLoadingScreen = true,
    -- General
    removeRealmNames = true,
    centerNames = false,
    darkModeUi = false,
    darkModeActionBars = true,
    darkModeUiAura = true,
    darkModeCastbars = true,
    darkModeColor = 0.30,
    hideGroupIndicator = false,
    hideFocusCombatGlow = false,
    fixHealthbarText = true,
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
    enlargedAuraSize = 1.4,
    compactedAuraSize = 0.7,
    purgeableAuraSize = 1,
    onlyPandemicAuraMine = true,
    lossOfControlScale = 1,
    hidePetText = true,
    playerFrameScale = 1,
    targetFrameScale = 1,
    focusFrameScale = 1,
    playerFrameOCDZoom = true,

    --Target castbar
    playerCastbarIconXPos = 0,
    playerCastbarIconYPos = 0,
    targetCastbarIconXPos = 0,
    targetCastbarIconYPos = 0,
    focusCastbarIconXPos = 0,
    focusCastbarIconYPos = 0,
    targetEnlargeAuraEnemy = true,
    targetEnlargeAuraFriendly = true,
    focusEnlargeAuraEnemy = true,
    focusEnlargeAuraFriendly = true,

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
    --Race Indicator
    racialIndicator = false,
    targetRacialIndicator = true,
    focusRacialIndicator = true,
    racialIndicatorXPos = 0,
    racialIndicatorYPos = 0,
    racialIndicatorScale = 1,
    racialIndicatorOrc = true,
    racialIndicatorNelf = true,
    racialIndicatorHuman = true,
    racialIndicatorUndead = true,

    --Party castbars
    partyCastBarScale = 0.9,
    partyCastBarIconScale = 0.9,
    partyCastBarXPos = 0,
    partyCastBarYPos = 0,
    partyCastBarWidth = 137,
    partyCastBarHeight = 10,
    partyCastBarTimer = false,
    showPartyCastBarIcon = true,
    partyCastbarIconXPos = 0,
    partyCastbarIconYPos = 0,
    partyCastbarShowBorder = true,
    partyCastbarShowText = true,

    --Pet Castbar
    petCastbar = false,
    petCastBarScale = 0.92,
    petCastBarIconScale = 1,
    petCastBarXPos = 0,
    petCastBarYPos = 0,
    petCastBarWidth = 137,
    petCastBarHeight = 10,
    showPetCastBarIcon = true,
    showPetCastBarTimer = false,
    petCastBarShowText = true,
    petCastBarShowBorder = true,

    --Castbar edge highlight
    castBarInterruptHighlighterStartTime = 0.8,
    castBarInterruptHighlighterEndTime = 0.6,
    castBarInterruptHighlighterDontInterruptRGB = {1,0,0},
    castBarInterruptHighlighterInterruptRGB = {0,1,0},
    castBarNoInterruptColor = {1, 0, 0.01568627543747425},
    castBarDelayedInterruptColor = {1, 0.4784314036369324, 0.9568628072738647},

    --Target castbar
    targetCastBarScale = 1,
    targetCastBarIconScale = 1,
    targetCastBarXPos = 0,
    targetCastBarYPos = 0,
    targetCastBarWidth = 150,
    targetCastBarHeight = 11,
    targetCastBarTimer = false,
    targetToTAdjustmentOffsetY = 0,
    targetCastBarShowText = true,
    targetCastBarShowBorder = true,

    --Focus castbar
    focusCastBarScale = 1,
    focusCastBarIconScale = 1,
    focusCastBarXPos = 0,
    focusCastBarYPos = 0,
    focusCastBarWidth = 150,
    focusCastBarHeight = 11,
    focusCastBarTimer = false,
    focusToTAdjustmentOffsetY = 0,
    focusCastBarShowText = true,
    focusCastBarShowBorder = true,

    --Player castbar
    playerCastBarXPos = 0,
    playerCastBarYPos = 0,
    playerCastBarScale = 1,
    playerCastBarIconScale = 1,
    playerCastBarWidth = 195,
    playerCastBarHeight = 13,
    playerCastBarTimer = false,
    playerCastBarTimerCenter = false,
    playerCastBarShowText = true,
    playerCastBarShowBorder = true,

    --Auras
    --playerAuraMaxBuffsPerRow = 10,
    --playerAuraMaxDebuffsPerRow = 10,
    auraToggleIconTexture = 134430,
    enablePlayerBuffFiltering = true,
    enablePlayerDebuffFiltering = false,
    playerdeBuffFilterBlacklist = true,
    playerBuffFilterBlacklist = true,
    focusdeBuffFilterBlacklist = true,
    focusBuffFilterBlacklist = true,
    targetdeBuffFilterBlacklist = true,
    targetBuffFilterBlacklist = true,
    auraTypeGap = 4,
    maxPlayerAurasPerRow = 10,
    playerAuraBuffScale = 1,
    playerAuraSpacingX = 3,
    playerAuraSpacingY = 0,
    playerAuraXOffset = 0,
    playerAuraYOffset = 0,
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
    targetAndFocusSmallAuraScale = 1,
    purgeTextureColorRGB = {0.3686274588108063,0.9803922176361084,1,1,},

    frameAurasXPos = 0,
    frameAurasYPos = 0,
    frameAuraScale = 0,
    maxAurasOnFrame = 0,
    frameAuraRowAmount = 0,
    frameAuraWidthGap = 0,
    frameAuraHeightGap = 0,

    playerAuraFiltering = false,
    displayDispelGlowAlways = false,
    overShieldsUnitFrames = true,
    overShieldsCompactUnitFrames = true,
    playerAuraGlows = true,
    playerAuraImportantGlow = true,

    --Target buffs
    targetAuraGlows = true,
    targetEnlargeAura = true,
    targetCompactAura = true,

    maxTargetBuffs = 32,
    maxTargetDebuffs = 16,
    targetBuffEnable = true,
    targetBuffFilterAll = true,
    targetBuffFilterWatchList = false,
    targetBuffFilterLessMinite = false,
    targetBuffFilterPurgeable = false,
    targetImportantAuraGlow = true,
    targetBuffFilterOnlyMe = false,
    --Target debuffs
    targetdeBuffEnable = true,
    targetdeBuffFilterAll = false,
    targetdeBuffFilterBlizzard = false,
    targetdeBuffFilterWatchList = false,
    targetdeBuffFilterLessMinite = false,
    targetdeBuffFilterOnlyMe = false,
    targetdeBuffPandemicGlow = true,

    --Focus buffs
    focusAuraGlows = true,
    focusEnlargeAura = true,
    focusCompactAura = true,

    focusBuffEnable = true,
    focusBuffFilterAll = true,
    focusBuffFilterWatchList = false,
    focusBuffFilterLessMinite = false,
    focusBuffFilterOnlyMe = false,
    focusBuffFilterPurgeable = false,
    focusImportantAuraGlow = true,
    --Focus debuffs
    focusdeBuffEnable = true,
    focusdeBuffFilterAll = false,
    focusdeBuffFilterBlizzard = false,
    focusdeBuffFilterWatchList = false,
    focusdeBuffFilterLessMinite = false,
    focusdeBuffFilterOnlyMe = false,
    focusdeBuffPandemicGlow = true,

    PlayerAuraFrameBuffFilterWatchList = false,
    PlayerAuraFramedeBuffFilterWatchList = false,

    -- Interrupt icon
    castBarInterruptIconScale = 1,
    castBarInterruptIconXPos = 0,
    castBarInterruptIconYPos = 0,
    castBarInterruptIconAnchor = "RIGHT",
    castBarInterruptIconTarget = true,
    castBarInterruptIconFocus = true,
    castBarInterruptIconShowActiveOnly = false,
    castBarInterruptIconDisplayCD = true,
    interruptIconBorder = true,

    auraWhitelist = {
        {["name"] = "Example Aura :3 (delete me)"}
    },
    auraBlacklist = {},
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



    BetterBlizzFramesDB.hasCheckedUi = true


    C_Timer.After(5, function()
        if not C_AddOns.IsAddOnLoaded("SkillCapped") then
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames first run. Thank you for trying out my AddOn. Access settings with /bbf")
        end
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

StaticPopupDialogs["BBF_NEW_VERSION"] = {
    text = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames " .. "Cata Beta 0.0.8" .. ":\n\nTWO IMPORTANT CHANGES:\n\n1) I've reset TargetToT & FocusToT positions.\nYou will have to change them to your preferred locations again.\n\n2) I've also added scale settings for Player, Target and FocusFrame.\n\nIf you have scripts/other addons adjusting this make sure you set the same value in BBF or turn off the other things.\n\nSorry for the inconvenience.\nThis change was needed due to wrong initial values when making the Beta.\nIt wont happen again.",
    button1 = "OK",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local function UpdateAuraColorsToGreen()
    if BetterBlizzFramesDB and BetterBlizzFramesDB["auraWhitelist"] then
        for _, entry in pairs(BetterBlizzFramesDB["auraWhitelist"]) do
            if entry.entryColors and entry.entryColors.text then
                -- Update to green color
                entry.entryColors.text.r = 0
                entry.entryColors.text.g = 1
                entry.entryColors.text.b = 0
            else
                entry.entryColors = { text = { r = 0, g = 1, b = 0 } }
            end
        end
    end
end

local function AddAlphaValuesToAuraColors()
    if BetterBlizzFramesDB and BetterBlizzFramesDB["auraWhitelist"] then
        for _, entry in pairs(BetterBlizzFramesDB["auraWhitelist"]) do
            if entry.entryColors and entry.entryColors.text then
                entry.entryColors.text.a = 1
            else
                entry.entryColors = { text = { r = 0, g = 1, b = 0, a = 1 } }
            end
        end
    end
end

local function ResetBBF()
    BetterBlizzFramesDB = {}
    ReloadUI()
end

StaticPopupDialogs["CONFIRM_RESET_BETTERBLIZZFRAMESDB"] = {
    text = "Are you sure you want to reset all BetterBlizzFrames settings?\nThis action cannot be undone.",
    button1 = "Confirm",
    button2 = "Cancel",
    OnAccept = function()
        ResetBBF()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Update message
local function SendUpdateMessage()
    if sendUpdate then
        if not BetterBlizzFramesDB.scStart then
            if not BetterBlizzFramesDB.totPosUpdatedForCata then
                if BetterBlizzFramesDB.playerAuraFiltering then
                    BetterBlizzFramesDB.targetToTXPos = 42
                    BBF.targetToTXPos:SetValue(42)
                    BetterBlizzFramesDB.targetToTYPos = -10
                    BBF.targetToTYPos:SetValue(-10)
                    BetterBlizzFramesDB.focusToTXPos = 42
                    BBF.focusToTXPos:SetValue(42)
                    BetterBlizzFramesDB.focusToTYPos = -10
                    BBF.focusToTYPos:SetValue(-10)
                    BBF.MoveToTFrames()
                else
                    BetterBlizzFramesDB.targetToTXPos = 0
                    BBF.targetToTXPos:SetValue(0)
                    BetterBlizzFramesDB.focusToTXPos = 0
                    BBF.focusToTXPos:SetValue(0)
                    BetterBlizzFramesDB.targetToTYPos = 0
                    BBF.targetToTYPos:SetValue(0)
                    BetterBlizzFramesDB.focusToTYPos = 0
                    BBF.focusToTYPos:SetValue(0)
                    BBF.MoveToTFrames()
                end
                BetterBlizzFramesDB.totPosUpdatedForCata = true
            end
            C_Timer.After(7, function()
                StaticPopup_Show("BBF_NEW_VERSION")

                DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames news:")
                -- DEFAULT_CHAT_FRAME:AddMessage("|A:QuestNormal:16:16|a New Stuff:")
                DEFAULT_CHAT_FRAME:AddMessage("|A:QuestNormal:16:16|a Two important changes. To read again type /bbf news")
                -- DEFAULT_CHAT_FRAME:AddMessage("   - Absorb Indicator + Overshields now working (Potentially).")
                -- -- DEFAULT_CHAT_FRAME:AddMessage("   - Sort Purgeable Auras setting (Buffs & Debuffs).")

                -- DEFAULT_CHAT_FRAME:AddMessage("|A:Professions-Crafting-Orders-Icon:16:16|a Bugfixes:")
                -- DEFAULT_CHAT_FRAME:AddMessage("   Castbar settings should now be better on Cata, might still need some tweaks.")
                -- DEFAULT_CHAT_FRAME:AddMessage("   +Many more... Keep bug reporting please.")
                -- -- DEFAULT_CHAT_FRAME:AddMessage("   Reverted all name logic to 1.3.8b version. It's old and not optimal but at least it doesn't taint(?). I will never touch this again until TWW >_>")
                -- --DEFAULT_CHAT_FRAME:AddMessage("   A lot of behind the scenes Name logic changed. Should now work better and be happier with other addons.")
            end)
        else
            BetterBlizzFramesDB.scStart = nil
        end
    end
end

local function NewsUpdateMessage()
    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames news:")
    DEFAULT_CHAT_FRAME:AddMessage("|A:QuestNormal:16:16|a New Settings:")
    DEFAULT_CHAT_FRAME:AddMessage("   - Castbar Edge Highlighter now uses seconds instead of percentages.")
    DEFAULT_CHAT_FRAME:AddMessage("   - Added \"Hide Player Guide Flag\" setting.")

    DEFAULT_CHAT_FRAME:AddMessage("|A:Professions-Crafting-Orders-Icon:16:16|a Bugfixes:")
    DEFAULT_CHAT_FRAME:AddMessage("   Fixed Overshields for PlayerFrame/TargetFrame etc after Blizzard change.")
    DEFAULT_CHAT_FRAME:AddMessage("   A lot of behind the scenes Name logic changed. Should now work better and be happier with other addons.")

    DEFAULT_CHAT_FRAME:AddMessage("|A:GarrisonTroops-Health:16:16|a Patreon link: www.patreon.com/bodydev")
end

-- added minimap hider and auto hider

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

        BBF.MinimapHider()

    elseif event == "LOADING_SCREEN_DISABLED" or event == "PLAYER_LEAVING_WORLD" then
        if BetterBlizzFramesDB.playerFrameOCD then
            BBF.FixStupidBlizzPTRShit()
        end

        BBF.MinimapHider()

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

function BBF.ScaleUnitFrames()
    local db = BetterBlizzFramesDB
    PlayerFrame:SetScale(db.playerFrameScale)
    TargetFrame:SetScale(db.targetFrameScale)
    FocusFrame:SetScale(db.focusFrameScale)
end

-- Function to toggle test mode on and off
function BBF.ToggleLossOfControlTestMode()
    if not cataReady then return end
    local LossOfControlFrameAlphaBg = BetterBlizzFramesDB.hideLossOfControlFrameBg and 0 or 0.6
    local LossOfControlFrameAlphaLines = BetterBlizzFramesDB.hideLossOfControlFrameLines and 0 or 1
    if not _G.FakeBBFLossOfControlFrame then  -- Changed to a global reference for wider access
        -- Main Frame Creation
        local frame = CreateFrame("Frame", "FakeBBFLossOfControlFrame", UIParent, "BackdropTemplate")
        frame:SetSize(256, 58)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        frame:SetFrameStrata("MEDIUM")
        frame:SetToplevel(true)
        frame:Hide()

        -- Background Texture
        local blackBg = frame:CreateTexture(nil, "BACKGROUND")
        blackBg:SetTexture(LossOfControlFrame.blackBg:GetTexture())
        blackBg:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0)
        blackBg:SetSize(256, 58)
        frame.blackBg = blackBg  -- Correctly scoped

        -- Red Lines Textures
        local redLineTop = frame:CreateTexture(nil, "BACKGROUND")
        redLineTop:SetTexture("Interface\\Cooldown\\Loc-RedLine")
        redLineTop:SetSize(236, 27)
        redLineTop:SetPoint("BOTTOM", frame, "TOP", 0, 0)
        frame.RedLineTop = redLineTop  -- Correctly scoped

        local redLineBottom = frame:CreateTexture(nil, "BACKGROUND")
        redLineBottom:SetTexture("Interface\\Cooldown\\Loc-RedLine")
        redLineBottom:SetSize(236, 27)
        redLineBottom:SetPoint("TOP", frame, "BOTTOM", 0, 0)
        redLineBottom:SetTexCoord(0, 1, 1, 0)
        frame.RedLineBottom = redLineBottom  -- Correctly scoped

        -- Icon Texture
        local icon = frame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(48, 48)
        icon:SetPoint("LEFT", frame, "LEFT", 42, 0)
        icon:SetTexture(132298)
        frame.Icon = icon  -- Correctly scoped

        -- Ability Name FontString
        local abilityName = frame:CreateFontString(nil, "ARTWORK", "MovieSubtitleFont")
        abilityName:SetPoint("TOPLEFT", icon, "TOPRIGHT", 5, -4)
        abilityName:SetSize(0, 20)
        abilityName:SetText("Stunned")
        frame.AbilityName = abilityName  -- Correctly scoped

        -- Time Left Frame
        local timeLeft = CreateFrame("Frame", nil, frame)
        timeLeft:SetSize(200, 20)
        timeLeft:SetPoint("TOPLEFT", abilityName, "BOTTOMLEFT", 0, 0)
        frame.TimeLeft = timeLeft  -- Correctly scoped

        -- Number and Seconds Text
        local numberText = timeLeft:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
        numberText:SetText("5.5 seconds")
        numberText:SetPoint("LEFT", timeLeft, "LEFT", 0, -3)
        numberText:SetShadowOffset(2, -2)
        numberText:SetTextColor(1,1,1)
        timeLeft.NumberText = numberText  -- Correctly scoped

        -- Stop Testing Button
        local stopButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        stopButton:SetSize(120, 30)
        stopButton:SetPoint("BOTTOM", redLineBottom, "BOTTOM", 0, -35)
        stopButton:SetText("Stop Testing")
        stopButton:SetScript("OnClick", function() frame:Hide() end)
        frame.StopButton = stopButton  -- Correctly scoped

        _G.FakeBBFLossOfControlFrame = frame  -- Store the frame globally
    end
    FakeBBFLossOfControlFrame:SetScale(BetterBlizzFramesDB.lossOfControlScale)
    FakeBBFLossOfControlFrame.blackBg:SetAlpha(LossOfControlFrameAlphaBg)
    FakeBBFLossOfControlFrame.RedLineTop:SetAlpha(LossOfControlFrameAlphaLines)
    FakeBBFLossOfControlFrame.RedLineBottom:SetAlpha(LossOfControlFrameAlphaLines)
    FakeBBFLossOfControlFrame:Show()
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
    if not cataReady then return end
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



function BBF.ActionBarIconZoom()
    --local texCoords = BetterBlizzFramesDB.playerFrameOCDZoom and {0.06, 0.94, 0.06, 0.94} or {0, 1, 0, 1}
    local texCoords = (BetterBlizzFramesDB.playerFrameOCD and BetterBlizzFramesDB.playerFrameOCDZoom) and {0.04, 0.98, 0.04, 0.95} or {0, 1, 0, 1}
    local function applyTexCoord(frame)
        if frame and frame.SetTexCoord then
            frame:SetTexCoord(unpack(texCoords))
        end
    end
    for i = 1, 12 do
        local icons = {
            _G["ActionButton" .. i .. "Icon"],
            _G["MultiBarBottomLeftButton" .. i .. "Icon"],
            _G["MultiBarBottomRightButton" .. i .. "Icon"],
            _G["MultiBarRightButton" .. i .. "Icon"],
            _G["MultiBarLeftButton" .. i .. "Icon"],
            _G["MultiBar5Button" .. i .. "Icon"],
            _G["MultiBar6Button" .. i .. "Icon"],
            _G["MultiBar7Button" .. i .. "Icon"],
            _G["PetActionButton" .. i .. "Icon"],
            _G["StanceButton" .. i .. "Icon"]
        }
        for _, icon in ipairs(icons) do
            applyTexCoord(icon)
        end
    end
end


function BBF.MoveToTFrames()
    if not InCombatLockdown() then
        TargetFrameToT:ClearAllPoints()
        if BetterBlizzFramesDB.targetToTAnchor == "BOTTOMRIGHT" then
            --TargetFrameToT:SetPoint(BBF.GetOppositeAnchor(BetterBlizzFramesDB.targetToTAnchor),TargetFrame,BetterBlizzFramesDB.targetToTAnchor,BetterBlizzFramesDB.targetToTXPos - 108,BetterBlizzFramesDB.targetToTYPos + 10)
            TargetFrameToT:SetPoint(BetterBlizzFramesDB.targetToTAnchor,TargetFrame,BetterBlizzFramesDB.targetToTAnchor,BetterBlizzFramesDB.targetToTXPos - 35,BetterBlizzFramesDB.targetToTYPos - 10)
        else
            TargetFrameToT:SetPoint(BBF.GetOppositeAnchor(BetterBlizzFramesDB.targetToTAnchor),TargetFrame,BetterBlizzFramesDB.targetToTAnchor,BetterBlizzFramesDB.targetToTXPos,BetterBlizzFramesDB.targetToTYPos)
        end
        TargetFrameToT:SetScale(BetterBlizzFramesDB.targetToTScale)
        --TargetFrameToT.SetPoint=function()end

        FocusFrameToT:ClearAllPoints()
        if BetterBlizzFramesDB.focusToTAnchor == "BOTTOMRIGHT" then
            --FocusFrameToT:SetPoint(BBF.GetOppositeAnchor(BetterBlizzFramesDB.focusToTAnchor),FocusFrame,BetterBlizzFramesDB.focusToTAnchor,BetterBlizzFramesDB.focusToTXPos - 108,BetterBlizzFramesDB.focusToTYPos + 10)
            FocusFrameToT:SetPoint(BetterBlizzFramesDB.focusToTAnchor,FocusFrame,BetterBlizzFramesDB.focusToTAnchor,BetterBlizzFramesDB.focusToTXPos - 35,BetterBlizzFramesDB.focusToTYPos - 10)
        else
            FocusFrameToT:SetPoint(BBF.GetOppositeAnchor(BetterBlizzFramesDB.focusToTAnchor),FocusFrame,BetterBlizzFramesDB.focusToTAnchor,BetterBlizzFramesDB.focusToTXPos,BetterBlizzFramesDB.focusToTYPos)
        end
        FocusFrameToT:SetScale(BetterBlizzFramesDB.focusToTScale)
        --FocusFrameToT.SetPoint=function()end
    else
        C_Timer.After(1.5, function()
            BBF.MoveToTFrames()
        end)
    end
end

-- Local table to store the original settings
local originalSettings = {
    backedUp = false,
    positions = {},
    sizes = {},
    texCoords = {}
}

-- Function to back up current settings
local function backupSettings()
    if not originalSettings.backedUp then
        -- Back up positions
        originalSettings.positions = {
            MainMenuBarTexture3 = {MainMenuBarTexture3:GetPoint()},
            CharacterMicroButton = {CharacterMicroButton:GetPoint()},
            SpellbookMicroButton = {SpellbookMicroButton:GetPoint()},
            TalentMicroButton = {TalentMicroButton:GetPoint()},
            AchievementMicroButton = {AchievementMicroButton:GetPoint()},
            QuestLogMicroButton = {QuestLogMicroButton:GetPoint()},
            GuildMicroButton = {GuildMicroButton:GetPoint()},
            CollectionsMicroButton = {CollectionsMicroButton:GetPoint()},
            PVPMicroButton = {PVPMicroButton:GetPoint()},
            LFGMicroButton = {LFGMicroButton:GetPoint()},
            EJMicroButton = {EJMicroButton:GetPoint()},
            MainMenuMicroButton = {MainMenuMicroButton:GetPoint()},
            HelpMicroButton = {HelpMicroButton:GetPoint()},
            MainMenuBarBackpackButton = {MainMenuBarBackpackButton:GetPoint()},
            CharacterBag1Slot = {CharacterBag1Slot:GetPoint()},
            CharacterBag2Slot = {CharacterBag2Slot:GetPoint()},
            CharacterBag3Slot = {CharacterBag3Slot:GetPoint()},
            MainMenuExpBar = {MainMenuExpBar:GetPoint()},
            MainMenuXPBarTexture0 = {MainMenuXPBarTexture0:GetPoint()},
            MainMenuXPBarTexture1 = {MainMenuXPBarTexture1:GetPoint()},
            MainMenuXPBarTexture2 = {MainMenuXPBarTexture2:GetPoint()},
            MainMenuXPBarTexture3 = {MainMenuXPBarTexture3:GetPoint()},
            MainMenuBarRightEndCap = {MainMenuBarRightEndCap:GetPoint()},
            MainMenuMaxLevelBar0 = {MainMenuMaxLevelBar0:GetPoint()},
            MainMenuMaxLevelBar1 = {MainMenuMaxLevelBar1:GetPoint()},
            MainMenuMaxLevelBar2 = {MainMenuMaxLevelBar2:GetPoint()},
            MainMenuMaxLevelBar3 = {MainMenuMaxLevelBar3:GetPoint()},
            ReputationWatchBar = {ReputationWatchBar:GetPoint()},
            ReputationWatchBar_StatusBar_XPBarTexture0 = {ReputationWatchBar.StatusBar.XPBarTexture0:GetPoint()},
            ReputationWatchBar_StatusBar_XPBarTexture1 = {ReputationWatchBar.StatusBar.XPBarTexture1:GetPoint()},
            ReputationWatchBar_StatusBar_XPBarTexture2 = {ReputationWatchBar.StatusBar.XPBarTexture2:GetPoint()},
            ReputationWatchBar_StatusBar_XPBarTexture3 = {ReputationWatchBar.StatusBar.XPBarTexture3:GetPoint()}
        }
        
        -- Back up other sizes
        originalSettings.sizes = {
            MainMenuBarTexture3 = {MainMenuBarTexture3:GetSize()},
            MainMenuBarBackpackButton = {MainMenuBarBackpackButton:GetSize()},
            MainMenuBarBackpackButtonNormalTexture = {MainMenuBarBackpackButtonNormalTexture:GetSize()},
            MainMenuExpBar = {MainMenuExpBar:GetSize()},
            MainMenuXPBarTexture0 = {MainMenuXPBarTexture0:GetSize()},
            MainMenuXPBarTexture1 = {MainMenuXPBarTexture1:GetSize()},
            MainMenuXPBarTexture2 = {MainMenuXPBarTexture2:GetSize()},
            MainMenuXPBarTexture3 = {MainMenuXPBarTexture3:GetSize()},
            MainMenuMaxLevelBar0 = {MainMenuMaxLevelBar0:GetSize()},
            MainMenuMaxLevelBar1 = {MainMenuMaxLevelBar1:GetSize()},
            MainMenuMaxLevelBar2 = {MainMenuMaxLevelBar2:GetSize()},
            MainMenuMaxLevelBar3 = {MainMenuMaxLevelBar3:GetSize()},
            ReputationWatchBar = {ReputationWatchBar:GetSize()},
            ReputationWatchBar_StatusBar = {ReputationWatchBar.StatusBar:GetSize()}
        }
        
        -- Mark as backed up
        originalSettings.backedUp = true
    end
end

-- Function to restore original settings
local function restoreSettings()
    if originalSettings.backedUp then
        -- Restore positions
        MainMenuBarTexture3:SetPoint(unpack(originalSettings.positions.MainMenuBarTexture3))
        CharacterMicroButton:SetPoint(unpack(originalSettings.positions.CharacterMicroButton))
        SpellbookMicroButton:SetPoint(unpack(originalSettings.positions.SpellbookMicroButton))
        TalentMicroButton:SetPoint(unpack(originalSettings.positions.TalentMicroButton))
        AchievementMicroButton:SetPoint(unpack(originalSettings.positions.AchievementMicroButton))
        QuestLogMicroButton:SetPoint(unpack(originalSettings.positions.QuestLogMicroButton))
        GuildMicroButton:SetPoint(unpack(originalSettings.positions.GuildMicroButton))
        CollectionsMicroButton:SetPoint(unpack(originalSettings.positions.CollectionsMicroButton))
        PVPMicroButton:SetPoint(unpack(originalSettings.positions.PVPMicroButton))
        LFGMicroButton:SetPoint(unpack(originalSettings.positions.LFGMicroButton))
        EJMicroButton:SetPoint(unpack(originalSettings.positions.EJMicroButton))
        MainMenuMicroButton:SetPoint(unpack(originalSettings.positions.MainMenuMicroButton))
        HelpMicroButton:SetPoint(unpack(originalSettings.positions.HelpMicroButton))
        MainMenuBarBackpackButton:SetPoint(unpack(originalSettings.positions.MainMenuBarBackpackButton))
        CharacterBag1Slot:SetPoint(unpack(originalSettings.positions.CharacterBag1Slot))
        CharacterBag2Slot:SetPoint(unpack(originalSettings.positions.CharacterBag2Slot))
        CharacterBag3Slot:SetPoint(unpack(originalSettings.positions.CharacterBag3Slot))
        MainMenuExpBar:SetPoint(unpack(originalSettings.positions.MainMenuExpBar))
        MainMenuXPBarTexture0:SetPoint(unpack(originalSettings.positions.MainMenuXPBarTexture0))
        MainMenuXPBarTexture1:SetPoint(unpack(originalSettings.positions.MainMenuXPBarTexture1))
        MainMenuXPBarTexture2:SetPoint(unpack(originalSettings.positions.MainMenuXPBarTexture2))
        MainMenuXPBarTexture3:SetPoint(unpack(originalSettings.positions.MainMenuXPBarTexture3))
        MainMenuBarRightEndCap:SetPoint(unpack(originalSettings.positions.MainMenuBarRightEndCap))
        MainMenuMaxLevelBar0:SetPoint(unpack(originalSettings.positions.MainMenuMaxLevelBar0))
        MainMenuMaxLevelBar1:SetPoint(unpack(originalSettings.positions.MainMenuMaxLevelBar1))
        MainMenuMaxLevelBar2:SetPoint(unpack(originalSettings.positions.MainMenuMaxLevelBar2))
        MainMenuMaxLevelBar3:SetPoint(unpack(originalSettings.positions.MainMenuMaxLevelBar3))
        ReputationWatchBar:SetPoint(unpack(originalSettings.positions.ReputationWatchBar))
        ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint(unpack(originalSettings.positions.ReputationWatchBar_StatusBar_XPBarTexture0))
        ReputationWatchBar.StatusBar.XPBarTexture1:SetPoint(unpack(originalSettings.positions.ReputationWatchBar_StatusBar_XPBarTexture1))
        ReputationWatchBar.StatusBar.XPBarTexture2:SetPoint(unpack(originalSettings.positions.ReputationWatchBar_StatusBar_XPBarTexture2))
        ReputationWatchBar.StatusBar.XPBarTexture3:SetPoint(unpack(originalSettings.positions.ReputationWatchBar_StatusBar_XPBarTexture3))
        
        -- Restore sizes and texCoords for character bags
        for i = 0, 3 do
            local border = _G["CharacterBag"..i.."SlotNormalTexture"]
            local icon = _G["CharacterBag"..i.."SlotIconTexture"]
            border:SetSize(64,64)
            icon:SetSize(30,30)
            icon:SetTexCoord(0,1,0,1)
        end
        
        -- Restore other sizes
        MainMenuBarTexture3:SetSize(unpack(originalSettings.sizes.MainMenuBarTexture3))
        MainMenuBarBackpackButton:SetSize(unpack(originalSettings.sizes.MainMenuBarBackpackButton))
        MainMenuBarBackpackButtonNormalTexture:SetSize(unpack(originalSettings.sizes.MainMenuBarBackpackButtonNormalTexture))
        MainMenuExpBar:SetSize(unpack(originalSettings.sizes.MainMenuExpBar))
        MainMenuXPBarTexture0:SetSize(unpack(originalSettings.sizes.MainMenuXPBarTexture0))
        MainMenuXPBarTexture1:SetSize(unpack(originalSettings.sizes.MainMenuXPBarTexture1))
        MainMenuXPBarTexture2:SetSize(unpack(originalSettings.sizes.MainMenuXPBarTexture2))
        MainMenuXPBarTexture3:SetSize(unpack(originalSettings.sizes.MainMenuXPBarTexture3))
        MainMenuMaxLevelBar0:SetSize(unpack(originalSettings.sizes.MainMenuMaxLevelBar0))
        MainMenuMaxLevelBar1:SetSize(unpack(originalSettings.sizes.MainMenuMaxLevelBar1))
        MainMenuMaxLevelBar2:SetSize(unpack(originalSettings.sizes.MainMenuMaxLevelBar2))
        MainMenuMaxLevelBar3:SetSize(unpack(originalSettings.sizes.MainMenuMaxLevelBar3))
        ReputationWatchBar:SetSize(unpack(originalSettings.sizes.ReputationWatchBar))
        ReputationWatchBar.StatusBar:SetSize(unpack(originalSettings.sizes.ReputationWatchBar_StatusBar))
    end
end

function BBF.FixStupidBlizzPTRShit()
    if BetterBlizzFramesDB.playerFrameOCD then
        if not originalSettings.backedUp then
            backupSettings()
        end
        
        if C_AddOns.IsAddOnLoaded("Bartender4") then return end
        MainMenuBarTextureExtender:Hide()
        MainMenuBarTexture3:SetPoint("BOTTOM", MainMenuBarArtFrame, "BOTTOM", 371, 0)
        MainMenuBarTexture3:SetWidth(260)
        CharacterMicroButton:SetPoint("BOTTOMLEFT", MainMenuBarArtFrame, "BOTTOMLEFT", 550, 2)
        SpellbookMicroButton:SetPoint("BOTTOMLEFT", CharacterMicroButton, "BOTTOMRIGHT", -3.5, 0)
        TalentMicroButton:SetPoint("BOTTOMLEFT", SpellbookMicroButton, "BOTTOMRIGHT", -3.5, 0)
        AchievementMicroButton:SetPoint("BOTTOMLEFT", TalentMicroButton, "BOTTOMRIGHT", -3.5, 0)
        QuestLogMicroButton:SetPoint("BOTTOMLEFT", AchievementMicroButton, "BOTTOMRIGHT", -3.5, 0)
        GuildMicroButton:SetPoint("BOTTOMLEFT", QuestLogMicroButton, "BOTTOMRIGHT", -3.5, 0)
        CollectionsMicroButton:SetPoint("BOTTOMLEFT", GuildMicroButton, "BOTTOMRIGHT", -3.5, 0)
        PVPMicroButton:SetPoint("BOTTOMLEFT", CollectionsMicroButton, "BOTTOMRIGHT", -3.5, 0)
        LFGMicroButton:SetPoint("BOTTOMLEFT", PVPMicroButton, "BOTTOMRIGHT", -3.5, 0)
        EJMicroButton:SetPoint("BOTTOMLEFT", LFGMicroButton, "BOTTOMRIGHT", -3.5, 0)
        MainMenuMicroButton:SetPoint("BOTTOMLEFT", EJMicroButton, "BOTTOMRIGHT", -3.5, 0)
        HelpMicroButton:SetPoint("BOTTOMLEFT", MainMenuMicroButton, "BOTTOMRIGHT", -3.5, 0)

        MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", MainMenuBarArtFrame, "BOTTOMRIGHT", -25, 6)
        CharacterBag1Slot:SetPoint("RIGHT", CharacterBag0Slot, "LEFT", -2, 0)
        CharacterBag2Slot:SetPoint("RIGHT", CharacterBag1Slot, "LEFT", -2, 0)
        CharacterBag3Slot:SetPoint("RIGHT", CharacterBag2Slot, "LEFT", -2, 0)

        MainMenuBarBackpackButton:SetSize(32, 32)
        MainMenuBarBackpackButtonNormalTexture:SetSize(51, 52)
        for i = 0, 3 do
            local border = _G["CharacterBag" .. i .. "SlotNormalTexture"]
            local icon = _G["CharacterBag" .. i .. "SlotIconTexture"]
            icon:SetSize(32, 33)
            icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
            border:SetSize(52, 53)
        end

        MainMenuExpBar:SetWidth(1012)
        MainMenuExpBar:SetPoint("TOP", MainMenuBar, "TOP", -10, 0)
        MainMenuXPBarTexture0:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", -382, 3)
        MainMenuXPBarTexture0:SetWidth(255)
        MainMenuXPBarTexture1:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", -126, 3)
        MainMenuXPBarTexture1:SetWidth(255)
        MainMenuXPBarTexture2:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", 126, 3)
        MainMenuXPBarTexture2:SetWidth(255)
        MainMenuXPBarTexture3:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", 381, 3)
        MainMenuXPBarTexture3:SetWidth(255)
        MainMenuBarRightEndCap:SetPoint("BOTTOM", MainMenuBarArtFrame, "BOTTOM", 533, 0)

        MainMenuMaxLevelBar0:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", -382, 3)
        MainMenuMaxLevelBar0:SetWidth(255)
        MainMenuMaxLevelBar1:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", -126, 3)
        MainMenuMaxLevelBar1:SetWidth(255)
        MainMenuMaxLevelBar2:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", 126, 3)
        MainMenuMaxLevelBar2:SetWidth(255)
        MainMenuMaxLevelBar3:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", 381, 3)
        MainMenuMaxLevelBar3:SetWidth(255)

        ReputationWatchBar:SetWidth(1012)
        ReputationWatchBar.StatusBar:SetWidth(1015)
        ReputationWatchBar:SetPoint("TOP", MainMenuBar, "TOP", -13, 0)
        ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", -382, 3)
        ReputationWatchBar.StatusBar.XPBarTexture0:SetWidth(255)
        ReputationWatchBar.StatusBar.XPBarTexture1:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", -126, 3)
        ReputationWatchBar.StatusBar.XPBarTexture1:SetWidth(255)
        ReputationWatchBar.StatusBar.XPBarTexture2:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", 126, 3)
        ReputationWatchBar.StatusBar.XPBarTexture2:SetWidth(255)
        ReputationWatchBar.StatusBar.XPBarTexture3:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", 381, 3)
        ReputationWatchBar.StatusBar.XPBarTexture3:SetWidth(255)
        
        BBF.ActionBarIconZoom()
    else
        MainMenuBarTextureExtender:Show()
        restoreSettings()
        BBF.ActionBarIconZoom()
    end
end


local function TurnTestModesOff()
    BetterBlizzFramesDB.absorbIndicatorTestMode = false
    BetterBlizzFramesDB.partyCastBarTestMode = false
    BetterBlizzFramesDB.petCastBarTestMode = false
end


function BBF.MovePetFrame()
    BBF.MoveRegion(PetActionBarFrame, "LEFT", MainMenuBar, "LEFT", 36, 93)
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
    BBF.HookHealthbarColors()

    local function LoginVariablesLoaded()
        if BBF.variablesLoaded then
            -- add setings updates
            BBF.UpdateUserDarkModeSettings()
            BBF.ChatFilterCaller()

            BBF.HookOverShields()
            BBF.HookCastbarsForEvoker()
            BBF.StealthIndicator()
            BBF.CastbarRecolorWidgets()
            BBF.CastBarTimerCaller()
            BBF.ShowPlayerCastBarIcon()
            BBF.CombatIndicator(PlayerFrame, "player")
            if BetterBlizzFramesDB.hideArenaFrames then
                BBF.HideArenaFrames()
            end
            if BetterBlizzFramesDB.fixPlayerPetPosition then
                BBF.MovePetFrame()
            end
            BBF.ScaleUnitFrames()
            BBF.MoveToTFrames()
            BBF.UpdateUserAuraSettings()
            --BBF.HookPlayerAndTargetAuras()a
            if BetterBlizzFramesDB.enableMasque then
                BBF.SetupMasqueSupport()
            end


            -- local hidePartyName = BetterBlizzFramesDB.hidePartyNames
            -- local hidePartyRole = BetterBlizzFramesDB.hidePartyRoles
            -- if hidePartyName or hidePartyRole then
            --     BBF.OnUpdateName()
            -- end

            if BetterBlizzFramesDB.playerFrameOCD then
                BBF.FixStupidBlizzPTRShit()
            end
            C_Timer.After(1, function()
                if BetterBlizzFramesDB.classColorTargetNames and BetterBlizzFramesDB.classColorLevelText then
                    BBF.HookLevelText()
                end
                BBF.HookPlayerAndTargetAuras()
                if BetterBlizzFramesDB.playerFrameOCD then
                    BBF.FixStupidBlizzPTRShit()
                end
                if BetterBlizzFramesDB.classColorFrames then
                    BBF.UpdateFrames()
                end
                BBF.DarkmodeFrames()
                BBF.PlayerReputationColor()
                BBF.ClassColorPlayerName()
                --BBF.CheckForAuraBorders() bodify cata
                -- if BetterBlizzFramesDB.useMiniFocusFrame then
                --     BBF.MiniFocusFrame()
                -- end
                if BetterBlizzFramesDB.biggerHealthbars then
                    BBF.HookBiggerHealthbars()
                end
                BBF.ToggleCastbarInterruptIcon()
                BBF.UpdateUserTargetSettings()
                BBF.UpdateCastbars()
                BBF.ChangeCastbarSizes()
                BBF.HideFrames()
                --BBF.HookUnitFrameName()
            end)
            if BetterBlizzFramesDB.partyCastbars then
                BBF.CreateCastbars()
            end

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
    local command = string.lower(msg)
    if command == "news" then
        --NewsUpdateMessage()
        StaticPopup_Show("BBF_NEW_VERSION")
    elseif command == "test" then
        --playerFrameTest()
    elseif command == "nahj" then
        StaticPopup_Show("BBF_CONFIRM_NAHJ_PROFILE")
    elseif command == "magnusz" then
        StaticPopup_Show("BBF_CONFIRM_MAGNUSZ_PROFILE")
    else
        InterfaceOptionsFrame_OpenToCategory(BetterBlizzFrames)
    end
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

            if not BetterBlizzFramesDB.auraWhitelistColorsUpdated then
                UpdateAuraColorsToGreen() --update default yellow text to green for new color feature
                BetterBlizzFramesDB.auraWhitelistColorsUpdated = true
            end

            if not BetterBlizzFramesDB.auraWhitelistAlphaUpdated then
                AddAlphaValuesToAuraColors()
                BetterBlizzFramesDB.auraWhitelistAlphaUpdated = true
            end

            if BetterBlizzFramesDB.partyCastbarHideBorder then
                BetterBlizzFramesDB.partyCastbarShowBorder = false
                BetterBlizzFramesDB.partyCastbarHideBorder = nil
            end

            if BetterBlizzFramesDB.hideLossOfControlFrameLines == nil then
                if BetterBlizzFramesDB.hideLossOfControlFrameBg then
                    BetterBlizzFramesDB.hideLossOfControlFrameLines = true
                end
            end

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
    BBF.CheckForAuraBorders()
    BBF.RepositionBuffFrame()
    -- if not isAddonLoaded("ClassicFrames") then
    --     --BBF.HookNameChangeStuff()
    --     TargetFrame:SetFrameStrata("MEDIUM")
    --     TargetFrameSpellBar:SetFrameStrata("HIGH")
    --     FocusFrameSpellBar:SetFrameStrata("HIGH")
    -- end
    if BetterBlizzFramesDB.fixHealthbarText then
        --temp fix blizz bodify
        SetTextStatusBarText(PlayerFrameManaBar, PlayerFrameManaBarText)
        SetTextStatusBarText(PlayerFrameHealthBar, PlayerFrameHealthBarText)
        TextStatusBar_UpdateTextString(PlayerFrameHealthBar)
        TextStatusBar_UpdateTextString(PlayerFrameManaBar)
    end
end)
PlayerEnteringWorld:RegisterEvent("PLAYER_ENTERING_WORLD")


TargetFrame.HealthBar.OtherHealPredictionBar.Fill:SetVertexColor(0,1,0)
TargetFrame.HealthBar.MyHealPredictionBar.Fill:SetVertexColor(0,1,0)

-- TargetFrame.HealthBar.BBPFill = TargetFrame.HealthBar.OtherHealPredictionBar:CreateTexture(nil, "OVERLAY");
-- TargetFrame.HealthBar.BBPFill:SetTexture(137012)
-- TargetFrame.HealthBar.BBPFill:SetPoint("CENTER", TargetFrame.HealthBar.MyHealPredictionBar.FillMask, "CENTER", 0, 0)
-- -- TargetFrame.HealthBar.MyHealPredictionBar.FillMask:HookScript("OnUpdate", function()
-- --     TargetFrame.HealthBar.BBPFill:SetWidth(TargetFrame.HealthBar.MyHealPredictionBar.FillMask:GetWidth())
-- -- end)

-- BBF.HookAndDo(TargetFrame.HealthBar.MyHealPredictionBar.FillMask, "SetSize", function(frame, width, height, flag)
--     TargetFrame.HealthBar.BBPFill:SetSize(120, 42, flag)
-- end)

-- BBF.HookAndDo(TargetFrame.HealthBar.MyHealPredictionBar.FillMask, "SetWidth", function(frame, width, flag)
--     TargetFrame.HealthBar.BBPFill:SetWidth(TargetFrame.HealthBar.MyHealPredictionBar.FillMask:GetWidth(), flag)
-- end)
--TargetFrame.HealthBar.OtherHealPredictionBar.Fill:SetBlendMode("MOD")