-- I did not know what a variable was when I started. I know a little bit more now and I am so sorry.

local addonVersion = "1.00" --too afraid to to touch for now
local addonUpdates = C_AddOns.GetAddOnMetadata("BetterBlizzFrames", "Version")
local sendUpdate = true
BBF.VersionNumber = addonUpdates.."c"
BBF.variablesLoaded = false
local isAddonLoaded = C_AddOns.IsAddOnLoaded

local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()

local defaultSettings = {
    version = addonVersion,
    updates = "empty",
    wasOnLoadingScreen = true,
    skipGUI = true,
    -- General
    removeRealmNames = true,
    centerNames = false,
    darkModeUi = false,
    darkModeActionBars = true,
    darkModeUiAura = true,
    darkModeCastbars = true,
    darkModeColor = 0.20,
    darkModeVigor = true,
    hideGroupIndicator = false,
    hideFocusCombatGlow = false,
    hideDragonFlying = true,
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
    onlyPandemicAuraMine = true,
    lossOfControlScale = 1,
    customCode = "-- Enter custom code below here. Feel free to contact me @bodify",
    queueTimerID = 567458,
    queueTimerWarning = false,
    queueTimerAudio = true,
    queueTimerWarningTime = 6,
    minimizeObjectiveTracker = true,
    fadeMicroMenuExceptQueue = true,
    surrenderArena = true,
    uiWidgetPowerBarScale = 1,
    druidOverstacks = true,
    --partyFrameScale = 1,

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
    racialIndicatorDwarf = true,
    racialIndicatorDarkIronDwarf = true,

    --Party castbars
    partyCastBarScale = 1,
    partyCastBarIconScale = 1,
    partyCastBarXPos = 0,
    partyCastBarYPos = 0,
    partyCastBarWidth = 100,
    partyCastBarHeight = 12,
    partyCastBarTimer = false,
    showPartyCastBarIcon = true,
    partyCastbarIconXPos = 0,
    partyCastbarIconYPos = 0,

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
    targetCastBarHeight = 10,
    targetCastBarTimer = false,
    targetToTAdjustmentOffsetY = 0,

    --Focus castbar
    focusCastBarScale = 1,
    focusCastBarIconScale = 1,
    focusCastBarXPos = 0,
    focusCastBarYPos = 0,
    focusCastBarWidth = 150,
    focusCastBarHeight = 10,
    focusCastBarTimer = false,
    focusToTAdjustmentOffsetY = 0,

    --Player castbar
    --playerCastBarScale = 1,
    playerCastBarIconScale = 1,
    playerCastBarWidth = 208,
    playerCastBarHeight = 11,
    playerCastBarTimer = false,
    playerCastBarTimerCenter = false,

    --Auras
    --playerAuraMaxBuffsPerRow = 10,
    --playerAuraMaxDebuffsPerRow = 10,
    customImportantAuraSorting = true,
    customLargeSmallAuraSorting = true,
    allowLargeAuraFirst = true,
    auraStackSize = 1,
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
    playerAuraSpacingX = 5,
    playerAuraSpacingY = 0,
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
    purgeTextureColorRGB = {0, 0.92, 1, 0.85},
    hiddenIconDirection = "BOTTOM",

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

    auraImportantDispelIcon = true,

    --Target buffs
    maxTargetBuffs = 32,
    maxTargetDebuffs = 16,
    targetBuffEnable = true,
    targetBuffFilterAll = true,
    targetBuffFilterWatchList = false,
    targetBuffFilterLessMinite = false,
    targetBuffFilterPurgeable = false,
    targetImportantAuraGlow = true,
    targetBuffFilterOnlyMe = false,
    targetAuraGlows = true,
    targetEnlargeAura = true,
    targetCompactAura = true,

    --Target debuffs
    targetdeBuffEnable = true,
    targetdeBuffFilterAll = false,
    targetdeBuffFilterBlizzard = true,
    targetdeBuffFilterWatchList = false,
    targetdeBuffFilterLessMinite = false,
    targetdeBuffFilterOnlyMe = false,
    targetdeBuffPandemicGlow = true,

    --Focus buffs
    focusBuffEnable = true,
    focusBuffFilterAll = true,
    focusBuffFilterWatchList = false,
    focusBuffFilterLessMinite = false,
    focusBuffFilterOnlyMe = false,
    focusBuffFilterPurgeable = false,
    focusAuraGlows = true,
    focusEnlargeAura = true,
    focusCompactAura = true,
    focusImportantAuraGlow = true,

    --Focus debuffs
    focusdeBuffEnable = true,
    focusdeBuffFilterAll = false,
    focusdeBuffFilterBlizzard = true,
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

    moveResourceToTargetPaladinBG = true,
    unitFrameBgTextureColor = {0,0,0,0.5},


    auraWhitelist = {
        ["example aura :3 (delete me)"] = {name = "Example Aura :3 (delete me)"}
    },
    auraBlacklist = {
        ["sign of the skirmisher"] = {name = "Sign of the Skirmisher"},
        ["sign of the scourge"] = {name = "Sign of the Scourge"},
        ["stormwind champion"] = {name = "Stormwind Champion"},
        ["honorless target"] = {name = "Honorless Target"},
        ["guild champion"] = {name = "Guild Champion"},
        ["sign of iron"] = {name = "Sign of Iron"},
        ["enlisted"] = {name = "Enlisted"},
        [397734] = {name = "Word of a Worthy Ally", id = 397734},
        [186403] = {name = "Sign of Battle", id = 186403},
        [32727] = {name = "Arena Preparation", id = 32727},
        [93805] = {name = "Ironforge Champion", id = 93805},
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



    local function GetUIInfo() --uhhh yeah idk, not needed delete eventually TODO:
        if BBF.variablesLoaded then
            BetterBlizzFramesDB.hasCheckedUi = true
        else
            C_Timer.After(1, function()
                GetUIInfo()
            end)
        end
    end
    GetUIInfo()

    BetterBlizzFramesDB.hasNotOpenedSettings = true


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
    text = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames " .. addonUpdates .. ":\n\nIMPORTANT CHANGE\n\nPlease verify your aura white & blacklists are still intact.\n\nIf they are not go to your SavedVariables and backup both BetterBlizzFrames.lua and .lua.bak files before logging out or reloading.",
    button1 = "OK",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

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
        BetterBlizzFramesDB.skipGUI = true
        if not BetterBlizzFramesDB.scStart then
            C_Timer.After(7, function()
                --StaticPopup_Show("BBF_NEW_VERSION")
                if BetterBlizzFramesDB.playerAuraFiltering then
                    DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames "..addonUpdates..":")
                    --DEFAULT_CHAT_FRAME:AddMessage("|A:QuestNormal:16:16|a New stuff:")
                    DEFAULT_CHAT_FRAME:AddMessage("|A:QuestNormal:16:16|a Important Note: Some of the Buffs & Debuffs sorting settings are now enabled by default. Because of this they may have turned on for you, please double check your aura settings in the Buffs & Debuffs section.")
                end
                -- DEFAULT_CHAT_FRAME:AddMessage("|A:Professions-Crafting-Orders-Icon:16:16|a Tweak:")
                -- DEFAULT_CHAT_FRAME:AddMessage("   - Reset castbar interrupt icon y offset to 0 due to default positional changes You may have to readjust to your liking.")

                -- end
                -- DEFAULT_CHAT_FRAME:AddMessage("   Reverted all name logic to 1.3.8b version. It's old and not optimal but at least it doesn't taint(?). I will never touch this again until TWW >_>")
                --DEFAULT_CHAT_FRAME:AddMessage("   A lot of behind the scenes Name logic changed. Should now work better and be happier with other addons.")
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
    --#######TEMPORARY BUGFIX FOR BLIZZARD#########
    local _, instanceType = GetInstanceInfo()
    local inArena = instanceType == "arena" or instanceType == "pvp"
    --#######TEMPORARY BUGFIX FOR BLIZZARD#########
    if event == "PLAYER_ENTERING_WORLD" or event == "LOADING_SCREEN_ENABLED" then
        BetterBlizzFramesDB.wasOnLoadingScreen = true

        BBF.MinimapHider()
        BBF.FadeMicroMenu()

        --#######TEMPORARY BUGFIX FOR BLIZZARD#########
        if BetterBlizzFramesDB.hideDragonFlying then
            if inArena and UIWidgetPowerBarContainerFrame then
                for _, child in ipairs({UIWidgetPowerBarContainerFrame:GetChildren()}) do
                    if child.DecorLeft then
                        child.DecorLeft:SetAlpha(0)
                    end
                    if child.DecorRight then
                        child.DecorRight:SetAlpha(0)
                    end
                end
            else
                for _, child in ipairs({UIWidgetPowerBarContainerFrame:GetChildren()}) do
                    if child.DecorLeft then
                        child.DecorLeft:SetAlpha(1)
                    end
                    if child.DecorRight then
                        child.DecorRight:SetAlpha(1)
                    end
                end
            end
        end
        --#######TEMPORARY BUGFIX FOR BLIZZARD#########
    elseif event == "LOADING_SCREEN_DISABLED" or event == "PLAYER_LEAVING_WORLD" then
        if BetterBlizzFramesDB.playerFrameOCD then
            BBF.FixStupidBlizzPTRShit()
        end

        BBF.MinimapHider()

        --#######TEMPORARY BUGFIX FOR BLIZZARD#########
        if BetterBlizzFramesDB.hideDragonFlying then
            if inArena and UIWidgetPowerBarContainerFrame then
                for _, child in ipairs({UIWidgetPowerBarContainerFrame:GetChildren()}) do
                    if child.DecorLeft then
                        child.DecorLeft:SetAlpha(0)
                    end
                    if child.DecorRight then
                        child.DecorRight:SetAlpha(0)
                    end
                end
            else
                for _, child in ipairs({UIWidgetPowerBarContainerFrame:GetChildren()}) do
                    if child.DecorLeft then
                        child.DecorLeft:SetAlpha(1)
                    end
                    if child.DecorRight then
                        child.DecorRight:SetAlpha(1)
                    end
                end
            end
        end
        --#######TEMPORARY BUGFIX FOR BLIZZARD#########
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
        local db = BetterBlizzFramesDB
        if db.playerFrameClickthrough then
            PlayerFrame:SetMouseClickEnabled(shift)
        end

        if db.targetFrameClickthrough then
            TargetFrame:SetMouseClickEnabled(shift)
            TargetFrameToT:SetMouseClickEnabled(shift)
        end

        if db.focusFrameClickthrough then
            FocusFrame:SetMouseClickEnabled(shift)
            FocusFrameToT:SetMouseClickEnabled(shift)
        end
	end
end

-- Function to toggle test mode on and off
function BBF.ToggleLossOfControlTestMode()
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

function BBF.ChangeLossOfControlScale()
    LossOfControlFrame:SetScale(BetterBlizzFramesDB.lossOfControlScale)
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

function BBF.SurrenderNotLeaveArena()
    if not BetterBlizzFramesDB.surrenderArena then return end
    local function bbfPrint(msg)
        print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: "..msg)
    end

    local surrenderFailed

    SlashCmdList["CHAT_AFK"] = function(msg)
        if IsActiveBattlefieldArena() then
            if CanSurrenderArena() then
                SurrenderArena()
            else
                if not surrenderFailed then
                    surrenderFailed = true
                    bbfPrint("Can't surrender. Type /afk again to leave.")
                else
                    LeaveBattlefield()
                    surrenderFailed = nil
                end
            end
        else
            SendChatMessage(msg, "AFK")
        end
    end
end


--######################################################################
-- Move Resource Frames to TargetFrame
local hookedResourceFrames
local comboPointCache = {} -- Cache for original combo point order and number of points

-- Function to reposition combo points after dragging
local function RepositionIndividualComboPoints(comboPointFrame, positions, scale, expectedClass)
    if not comboPointCache[comboPointFrame] then
        comboPointCache[comboPointFrame] = {
            points = {},
            numPoints = 0
        }
    end

    local currentComboPoints = {}
    local allPointsReady = true
    local numComboPoints = 0

    for i = 1, comboPointFrame:GetNumChildren() do
        local child = select(i, comboPointFrame:GetChildren())
        if child ~= comboPointFrame.layoutParent and child:IsShown() then
            local point, _, relativePoint, x, y = child:GetPoint()
            if x then
                table.insert(currentComboPoints, { child = child, x = x, index = i })
                numComboPoints = numComboPoints + 1
            else
                allPointsReady = false
                break
            end
        end
    end

    if numComboPoints ~= comboPointCache[comboPointFrame].numPoints then
        comboPointCache[comboPointFrame].numPoints = numComboPoints
        table.sort(currentComboPoints, function(a, b) return a.x < b.x end)
        comboPointCache[comboPointFrame].points = {}
        for i, info in ipairs(currentComboPoints) do
            table.insert(comboPointCache[comboPointFrame].points, info.child)
        end
    elseif not allPointsReady then
        C_Timer.After(0.5, function()
            RepositionIndividualComboPoints(comboPointFrame, positions, scale, expectedClass)
        end)
        return
    end

    for i, child in ipairs(comboPointCache[comboPointFrame].points) do
        local savedPos = BetterBlizzFramesDB.moveResourceToTargetCustom and BetterBlizzFramesDB.customComboPositions and BetterBlizzFramesDB.customComboPositions[expectedClass] and BetterBlizzFramesDB.customComboPositions[expectedClass][i]
        child:ClearAllPoints()
        if savedPos then
            savedPos[2] = _G.UIParent
            child:SetPoint(unpack(savedPos))
        else
            child:SetPoint(unpack(positions[i]))
        end
        child:SetScale(scale)
    end
end

-- Function to setup combo points for any class
local function SetupClassComboPoints(comboPointFrame, positions, expectedClass, scale, xPos, yPos, changeDrawLayer)
    if select(2, UnitClass("player")) ~= expectedClass then return end
    if not hookedResourceFrames then
        if comboPointFrame and changeDrawLayer then
            local drawLayerOrder = {"BACKGROUND", "BORDER", "ARTWORK", "OVERLAY"}
            local function getNextDrawLayer(currentLayer)
                for i, layer in ipairs(drawLayerOrder) do
                    if layer == currentLayer then
                        if i < #drawLayerOrder then
                            return drawLayerOrder[i + 1], false
                        else
                            return currentLayer, true
                        end
                    end
                end
                return currentLayer
            end
            for _, frameChild in pairs({comboPointFrame:GetChildren()}) do
                for i = 1, frameChild:GetNumRegions() do
                    local region = select(i, frameChild:GetRegions())
                    if region:IsObjectType("Texture") then
                        local currentLayer, sublevel = region:GetDrawLayer()
                        local nextLayer, isOverlay = getNextDrawLayer(currentLayer)
                        if isOverlay then
                            region:SetDrawLayer(currentLayer, sublevel + 1)
                        else
                            region:SetDrawLayer(nextLayer, sublevel + 1)
                        end
                    end
                end
            end
        end

        if expectedClass == "PALADIN" then
            comboPointFrame.Background:SetParent(hiddenFrame)
            comboPointFrame.Glow:SetParent(hiddenFrame)
            comboPointFrame.ThinGlow:SetParent(hiddenFrame)
            comboPointFrame.ActiveTexture:SetParent(hiddenFrame)
            if BetterBlizzFramesDB.moveResourceToTargetPaladinBG then
                local paladinRunes = {comboPointFrame.rune1, comboPointFrame.rune2, comboPointFrame.rune3, comboPointFrame.rune4, comboPointFrame.rune5}
                for i, rune in ipairs(paladinRunes) do
                    local glowTexture = rune.ActiveTexture
                    if glowTexture and glowTexture:GetAtlas() then
                        local bgTexture = rune:CreateTexture(nil, "BACKGROUND")
                        bgTexture:SetAtlas(glowTexture:GetAtlas(), true)
                        bgTexture:SetPoint("CENTER", rune, "CENTER", 0, 0)
                        bgTexture:SetDesaturated(true)
                        bgTexture:SetVertexColor(0, 0, 0)
                        bgTexture:SetDrawLayer("BACKGROUND", -1)
                    end
                end
            end
        end

        hooksecurefunc(comboPointFrame, "SetPoint", function(self)
            if self.changing or self:IsProtected() then return end
            self.changing = true
            comboPointFrame:SetParent(TargetFrame)
            comboPointFrame:ClearAllPoints()
            comboPointFrame:SetPoint("LEFT", TargetFrame, "RIGHT", xPos, yPos or -2)
            comboPointFrame:SetMouseClickEnabled(false)
            comboPointFrame:SetFrameStrata("MEDIUM")
            RepositionIndividualComboPoints(comboPointFrame, positions, scale, expectedClass)
            self.changing = false
        end)


        -- Function to enable/disable edit mode
        function BBF.ToggleEditMode(state)
            if not BetterBlizzFramesDB.customComboPositions then
                BetterBlizzFramesDB.customComboPositions = {}
            end
            BBF.selectedComboPoint = nil
            if not BBF.EditModeController then
                -- Create an invisible frame to capture key presses
                local EditModeController = CreateFrame("Frame", "BBF_EditModeController", UIParent)
                EditModeController:SetSize(1, 1) -- Invisible but focusable
                EditModeController:SetPoint("CENTER")
                EditModeController:EnableKeyboard(true)
                EditModeController:SetPropagateKeyboardInput(false)
                EditModeController:Hide()
                BBF.EditModeController = EditModeController
                EditModeController:SetScript("OnKeyDown", function(self, key)
                    if BBF.selectedComboPoint then
                        local point, relativeTo, relativePoint, x, y = BBF.selectedComboPoint:GetPoint()
                        if key == "UP" then
                            BBF.selectedComboPoint:SetPoint(point, relativeTo, relativePoint, x, y + 0.5)
                        elseif key == "DOWN" then
                            BBF.selectedComboPoint:SetPoint(point, relativeTo, relativePoint, x, y - 0.5)
                        elseif key == "LEFT" then
                            BBF.selectedComboPoint:SetPoint(point, relativeTo, relativePoint, x - 0.5, y)
                        elseif key == "RIGHT" then
                            BBF.selectedComboPoint:SetPoint(point, relativeTo, relativePoint, x + 0.5, y)
                        end
                    end
                end)
            end
            for frame, data in pairs(comboPointCache) do
                for index, child in ipairs(data.points) do
                    if not child.numberOverlay then
                        local numOverlay = child:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                        numOverlay:SetTextColor(1, 1, 1, 1)
                        numOverlay:SetPoint("CENTER", child, "CENTER")
                        numOverlay:SetText(index)
                        child.numberOverlay = numOverlay
                    end
                    child.numberOverlay:SetShown(state)
                    child:EnableMouse(state)
                    child:SetMovable(state)
                    child:SetFrameStrata("HIGH")
                    child:RegisterForDrag("LeftButton")

                    -- Drag Start
                    child:SetScript("OnDragStart", state and function(self)
                        self:StartMoving()
                        self.numberOverlay:Show()
                        BBF.selectedComboPoint = self -- Track the currently moved child
                        BBF.EditModeController:Show() -- Enable key listening
                    end or nil)

                    -- Drag Stop
                    child:SetScript("OnDragStop", state and function(self)
                        self:StopMovingOrSizing()
                        self.numberOverlay:Hide()
                        BBF.selectedComboPoint = nil -- Clear selection when dragging stops
                        BBF.EditModeController:Hide()
                        local point, relativeTo, relativePoint, x, y = self:GetPoint()
                        BetterBlizzFramesDB.customComboPositions[expectedClass] = BetterBlizzFramesDB.customComboPositions[expectedClass] or {}
                        BetterBlizzFramesDB.customComboPositions[expectedClass][index] = { point, nil, relativePoint, x, y }
                    end or nil)

                    -- Immediate activation on mouse down
                    child:SetScript("OnMouseDown", state and function(self, button)
                        if button == "LeftButton" then
                            BBF.selectedComboPoint = self
                            BBF.EditModeController:Show()
                        end
                    end or nil)

                    -- Drag Stop
                    child:SetScript("OnMouseUp", state and function(self, button)
                        if button == "LeftButton" then
                            local point, relativeTo, relativePoint, x, y = self:GetPoint()
                            BetterBlizzFramesDB.customComboPositions[expectedClass] = BetterBlizzFramesDB.customComboPositions[expectedClass] or {}
                            BetterBlizzFramesDB.customComboPositions[expectedClass][index] = { point, nil, relativePoint, x, y }
                            BBF.selectedComboPoint = nil
                            BBF.EditModeController:Hide()
                        end
                    end or nil)
                end
            end
        end
    end

    RepositionIndividualComboPoints(comboPointFrame, positions, scale, expectedClass)
end

local roguePositions = {
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 2, 44 },
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 18.5, 30 },
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 29, 11.5 },
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 33, -11 },
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 29, -34 },
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 18.5, -53 },
    { "TOPLEFT", RogueComboPointBarFrame, "TOPLEFT", 2.5, -67.5 },
}

local druidPositions = {
    { "TOPLEFT", DruidComboPointBarFrame, "TOPLEFT", 34, 32.5 },
    { "TOPLEFT", DruidComboPointBarFrame, "TOPLEFT", 45, 14 },
    { "TOPLEFT", DruidComboPointBarFrame, "TOPLEFT", 48, -7 },
    { "TOPLEFT", DruidComboPointBarFrame, "TOPLEFT", 44, -28 },
    { "TOPLEFT", DruidComboPointBarFrame, "TOPLEFT", 33.5, -46.5 },
}

local warlockPositions = {
    { "TOPLEFT", WarlockPowerFrame, "TOPLEFT", 34, 32.5 },
    { "TOPLEFT", WarlockPowerFrame, "TOPLEFT", 45, 14 },
    { "TOPLEFT", WarlockPowerFrame, "TOPLEFT", 48, -7 },
    { "TOPLEFT", WarlockPowerFrame, "TOPLEFT", 44, -28 },
    { "TOPLEFT", WarlockPowerFrame, "TOPLEFT", 33.5, -46.5 },
}

local magePositions = {
    { "TOPLEFT", MageArcaneChargesFrame, "TOPLEFT", 39, 33 },
    { "TOPLEFT", MageArcaneChargesFrame, "TOPLEFT", 48, 11.5 },
    { "TOPLEFT", MageArcaneChargesFrame, "TOPLEFT", 48, -11.5 },
    { "TOPLEFT", MageArcaneChargesFrame, "TOPLEFT", 39, -33 },
}

local monkPositions = {
    { "TOPLEFT", MonkHarmonyBarFrame, "TOPLEFT", 15, 38.5 },
    { "TOPLEFT", MonkHarmonyBarFrame, "TOPLEFT", 27, 22 },
    { "TOPLEFT", MonkHarmonyBarFrame, "TOPLEFT", 33, 2 },
    { "TOPLEFT", MonkHarmonyBarFrame, "TOPLEFT", 33, -19 },
    { "TOPLEFT", MonkHarmonyBarFrame, "TOPLEFT", 27, -39 },
    { "TOPLEFT", MonkHarmonyBarFrame, "TOPLEFT", 15, -55 },
}

local evokerPositions = {
    { "TOPLEFT", EssencePlayerFrame, "TOPLEFT", 15, 33 },
    { "TOPLEFT", EssencePlayerFrame, "TOPLEFT", 27, 19 },
    { "TOPLEFT", EssencePlayerFrame, "TOPLEFT", 33, 1 },
    { "TOPLEFT", EssencePlayerFrame, "TOPLEFT", 33, -18 },
    { "TOPLEFT", EssencePlayerFrame, "TOPLEFT", 27, -36 },
    { "TOPLEFT", EssencePlayerFrame, "TOPLEFT", 15, -50 },
}

local paladinPositions = {
    { "TOPLEFT", PaladinPowerBarFrame, "TOPLEFT", 30, 32 },
    { "TOPLEFT", PaladinPowerBarFrame, "TOPLEFT", 41, 13 },
    { "TOPLEFT", PaladinPowerBarFrame, "TOPLEFT", 48, -7 },
    { "TOPLEFT", PaladinPowerBarFrame, "TOPLEFT", 44, -27 },
    { "TOPLEFT", PaladinPowerBarFrame, "TOPLEFT", 33, -45 },
}

local dkPositions = {
    { "TOPLEFT", RuneFrame, "TOPLEFT", 11, 40 },
    { "TOPLEFT", RuneFrame, "TOPLEFT", 25, 24 },
    { "TOPLEFT", RuneFrame, "TOPLEFT", 33, 4 },
    { "TOPLEFT", RuneFrame, "TOPLEFT", 33, -18 },
    { "TOPLEFT", RuneFrame, "TOPLEFT", 25, -38 },
    { "TOPLEFT", RuneFrame, "TOPLEFT", 11, -54 },
}

local function HookClassComboPoints()
    local db = BetterBlizzFramesDB
    if db.moveResourceToTarget then
        if db.moveResourceToTargetRogue then SetupClassComboPoints(RogueComboPointBarFrame, roguePositions, "ROGUE", 0.5, -44, -2, true) end
        if db.moveResourceToTargetDruid then SetupClassComboPoints(DruidComboPointBarFrame, druidPositions, "DRUID", 0.55, -53, -2, true) end
        if db.moveResourceToTargetWarlock then SetupClassComboPoints(WarlockPowerFrame, warlockPositions, "WARLOCK", 0.6, -56, 1) end
        if db.moveResourceToTargetMage then SetupClassComboPoints(MageArcaneChargesFrame, magePositions, "MAGE", 0.7, -61, -4) end
        if db.moveResourceToTargetMonk then SetupClassComboPoints(MonkHarmonyBarFrame, monkPositions, "ROGUE", 0.5, -44, -2, true) end
        if db.moveResourceToTargetEvoker then SetupClassComboPoints(EssencePlayerFrame, evokerPositions, "EVOKER", 0.65, -50, 0.5, true) end
        if db.moveResourceToTargetPaladin then SetupClassComboPoints(PaladinPowerBarFrame, paladinPositions, "PALADIN", 0.75, -61, -8, true) end
        if db.moveResourceToTargetDK then SetupClassComboPoints(RuneFrame, dkPositions, "DEATHKNIGHT", 0.7, -50.5, 0.5, true) end

        hookedResourceFrames = true
    end
end

local function ScaleClassResource()
    local _, playerClass = UnitClass("player")
    local key = "classResource" .. playerClass .. "Scale"
    local scale = BetterBlizzFramesDB[key] or 1.0

    local frames = {
        RogueComboPointBarFrame,
        DruidComboPointBarFrame,
        WarlockPowerFrame,
        MageArcaneChargesFrame,
        MonkHarmonyBarFrame,
        EssencePlayerFrame,
        PaladinPowerBarFrame,
        RuneFrame
    }

    for _, frame in ipairs(frames) do
        if frame then
            frame:SetScale(scale)
        end
    end
end


function BBF.UpdateClassComboPoints()
    HookClassComboPoints()
    ScaleClassResource()
end

--########################################################
function BBF.MiniFrame(frame)
    local db = BetterBlizzFramesDB
    local useMiniFrame

    -- Determine which setting to use based on frame type
    if frame == PlayerFrame then
        useMiniFrame = db.useMiniPlayerFrame
    elseif frame == TargetFrame then
        useMiniFrame = db.useMiniTargetFrame
    elseif frame == FocusFrame then
        useMiniFrame = db.useMiniFocusFrame
    end

    if not useMiniFrame then return end

    -- Set up common variables for target/focus frames
    local healthBar, manaBar, compactRing, frameTexture, flash, reputationColor, levelText, name

    if frame ~= PlayerFrame then
        -- Variables for Target and Focus Frames
        healthBar = frame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
        manaBar = frame.TargetFrameContent.TargetFrameContentMain.ManaBar
        compactRing = frame.TargetFrameContainer.compactRing
        frameTexture = frame.TargetFrameContainer.FrameTexture
        flash = frame.TargetFrameContainer.Flash
        reputationColor = frame.TargetFrameContent.TargetFrameContentMain.ReputationColor
        levelText = frame.TargetFrameContent.TargetFrameContentMain.LevelText
        name = frame.bbfName or frame.TargetFrameContent.TargetFrameContentMain.Name

        -- Common customization for Target and Focus Frames
        healthBar:SetAlpha(0)
        manaBar:SetAlpha(0)

        if not compactRing then
            compactRing = frame.TargetFrameContainer:CreateTexture(nil, "ARTWORK")
            compactRing:SetAtlas("Map_Faction_Ring")
            compactRing:SetSize(71, 70)
            compactRing:SetPoint("CENTER", frame.TargetFrameContainer.Portrait, "CENTER", 1, -2)
            frame.TargetFrameContainer.compactRing = compactRing

            if db.darkModeUi then
                compactRing:SetDesaturated(true)
                local color = db.darkModeColor
                compactRing:SetVertexColor(color, color, color)
            end
        end
        compactRing:Show()

        frameTexture:Hide()
        flash:SetAlpha(0)
        reputationColor:SetAlpha(0)

        name:SetScale(1.4)
        name:ClearAllPoints()
        name:SetJustifyH("RIGHT")
        name:SetPoint("RIGHT", frame.TargetFrameContainer.Portrait, "LEFT", -9, 10)
        name:SetWidth(180)

        levelText:Hide()
        levelText:ClearAllPoints()
        levelText:SetPoint("CENTER", hiddenFrame, "CENTER")

    else
        -- Variables specific to the Player Frame
        healthBar = frame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
        manaBar = frame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar
        frameTexture = frame.PlayerFrameContainer.FrameTexture
        flash = frame.PlayerFrameContainer.FrameFlash
        name = PlayerFrame.bbfName or PlayerName
        local altTexture = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture
        local levelText = PlayerLevelText
        levelText:SetParent(hiddenFrame)
        name:SetWidth(180)

        -- Customize Player Frame differently if needed
        healthBar:SetAlpha(0)
        manaBar:SetAlpha(0)
        frameTexture:SetParent(hiddenFrame)
        altTexture:SetParent(hiddenFrame)
        if AlternatePowerBar then
            AlternatePowerBar:SetParent(hiddenFrame)
        end
        flash:SetAlpha(0)
        PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetAtlas("CircleMask")
        PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetSize(57,57)
        local a,b,c,d,e = PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:GetPoint()
        PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetPoint(a,b,c,d,e-2)

        if not compactRing then
            compactRing = frame.PlayerFrameContainer:CreateTexture(nil, "ARTWORK")
            compactRing:SetAtlas("Map_Faction_Ring")
            compactRing:SetSize(71, 70)
            compactRing:SetPoint("CENTER", frame.PlayerFrameContainer.PlayerPortrait, "CENTER", 0, -2)
            frame.PlayerFrameContainer.compactRing = compactRing

            if db.darkModeUi then
                compactRing:SetDesaturated(true)
                local color = db.darkModeColor
                compactRing:SetVertexColor(color, color, color)
            end
        end
        compactRing:Show()

        name:SetScale(1.4)
        name:ClearAllPoints()
        name:SetJustifyH("LEFT")
        name:SetPoint("LEFT", frame.PlayerFrameContainer, "TOP", -16, -26)
    end
end

function BBF.MoveToTFrames()
    if not InCombatLockdown() then
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
    else
        C_Timer.After(1.5, function()
            BBF.MoveToTFrames()
        end)
    end
end

function BBF.CompactPartyFrameScale()
    if BetterBlizzFramesDB.partyFrameScale then
        CompactPartyFrame:SetScale(BetterBlizzFramesDB.partyFrameScale)
    else
        C_Timer.After(3, function()
            BetterBlizzFramesDB.partyFrameScale = CompactPartyFrame:GetScale()
        end)
    end
end

function BBF.RecolorHpTempLoss()
    -- Player Frame
    local player = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    local playerTexture = player.PlayerFrameTempMaxHealthLoss:GetStatusBarTexture()
    if playerTexture then
        playerTexture:SetVertexColor(1,0,0)
        playerTexture:SetBlendMode("ADD")
    end

    -- Hide the TempMaxHealthLossDivider if it exists
    if player.TempMaxHealthLossDivider then
        player.TempMaxHealthLossDivider:SetAlpha(0)
    end

    -- Target Frame
    local target = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.TempMaxHealthLoss.TempMaxHealthLossTexture
    if target then
        target:SetVertexColor(1,0,0)
        target:SetBlendMode("ADD")
    end

    -- Focus Frame
    local focus = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.TempMaxHealthLoss.TempMaxHealthLossTexture
    if focus then
        focus:SetVertexColor(1,0,0)
        focus:SetBlendMode("ADD")
    end

    -- Party Frames
    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember"..i.."TempMaxHealthLoss"]
        if frame then
            local texture = frame:GetStatusBarTexture()
            if texture then
                texture:SetVertexColor(1,0,0,0.9)
                texture:SetBlendMode("ADD")
            end
        end
    end
end

function BBF.ResizeUIWidgetPowerBarFrame()
    if not UIWidgetPowerBarContainerFrame then return end
    local scale = BetterBlizzFramesDB.uiWidgetPowerBarScale
    if scale == 1 and UIWidgetPowerBarContainerFrame:GetScale() == 1 then return end
    UIWidgetPowerBarContainerFrame:SetScale(scale)
end


local LSM = LibStub("LibSharedMedia-3.0")

local texture = "Interface\\Addons\\BetterBlizzPlates\\media\\DragonflightTextureHD"
local manaTexture = "Interface\\Addons\\BetterBlizzPlates\\media\\DragonflightTextureHD"
local raidHpTexture = "Interface\\Addons\\BetterBlizzPlates\\media\\DragonflightTextureHD"
local raidManaTexture = "Interface\\Addons\\BetterBlizzPlates\\media\\DragonflightTextureHD"

local manaTextureUnits = {}

function BBF.UpdateCustomTextures()
    local db = BetterBlizzFramesDB
    texture = LSM:Fetch(LSM.MediaType.STATUSBAR, db.unitFrameHealthbarTexture)
    manaTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, db.unitFrameManabarTexture)
    raidHpTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, db.raidFrameHealthbarTexture)
    raidManaTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, db.raidFrameManabarTexture)

    BBF.HookTextures()
end

local LocalPowerBarColor = {}
for k, v in pairs(PowerBarColor) do
    if type(v) == "table" then
        LocalPowerBarColor[k] = { r = v.r, g = v.g, b = v.b }
    else
        LocalPowerBarColor[k] = v
    end
end
BBF.LocalPowerBarColor = LocalPowerBarColor

-- Helper function to change the texture and retain the original draw layer
local function ApplyTextureChange(type, statusBar, parent, classic)
    if not statusBar.GetStatusBarTexture then
        statusBar:SetTexture(texture)
        return
    end
    -- Get the original texture and draw layer
    local originalTexture = statusBar:GetStatusBarTexture()
    local originalLayer = originalTexture:GetDrawLayer()

    -- Change the texture
    statusBar:SetStatusBarTexture(type == "health" and texture or manaTexture)
    statusBar.bbfChangedTexture = true

    -- Restore the original draw layer
    originalTexture:SetDrawLayer(originalLayer)

    -- Hook SetStatusBarTexture to ensure the texture remains consistent
    if parent and type == "health" then
        if not parent.hookedHealthBarsTexture then
            hooksecurefunc(parent, "Update", function()
                statusBar:SetStatusBarTexture(texture)
                originalTexture:SetDrawLayer(originalLayer)
            end)
            parent.hookedHealthBarsTexture = true
        end
    elseif type == "mana" then
        -- Function to get the color of the unit's current power type and apply it
        local function SetUnitPowerColor(manabar, unit)
            -- Retrieve the unit's power type
            local _, powerToken = UnitPowerType(unit)
            -- Use the WoW PowerBarColor table to get the color
            local color = LocalPowerBarColor[powerToken]
            if color then
                manabar:SetStatusBarColor(color.r, color.g, color.b)
            end
        end
        SetUnitPowerColor(statusBar, statusBar.unit)

        if classic and not statusBar.bbfTextureHook then
            statusBar:SetStatusBarTexture(manaTexture)
            hooksecurefunc(statusBar, "SetStatusBarTexture", function(self)
                if self.changing then return end
                self.changing = true
                self:SetStatusBarTexture(manaTexture)
                self.changing = false
            end)
            statusBar.bbfTextureHook = true
        end

        if not BBF.hookedManaBarsTexture then
            hooksecurefunc("UnitFrameManaBar_UpdateType", function(manabar)
                if not manaTextureUnits[manabar.unit] then return end
                manabar:SetStatusBarTexture(manaTexture)
                SetUnitPowerColor(manabar, manabar.unit)
            end)
            BBF.hookedManaBarsTexture = true
        end
    end
end

-- Main function to apply texture changes to unit frames
    function HookUnitFrameTextures()
        local db = BetterBlizzFramesDB
        local classicFramesLoaded = C_AddOns.IsAddOnLoaded("ClassicFrames")

        if classicFramesLoaded then
            -- ClassicFrames is enabled: Modify ClassicFrames unit frames only
            if db.changeUnitFrameHealthbarTexture then
                ApplyTextureChange("health", CfPlayerFrameHealthBar)
                ApplyTextureChange("health", CfTargetFrameHealthBar, TargetFrame)
                ApplyTextureChange("health", TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, TargetFrame)
                ApplyTextureChange("health", FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, FocusFrame)
                ApplyTextureChange("health", CfFocusFrameHealthBar, FocusFrame)
                if PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ReputationColor then
                    ApplyTextureChange("health", PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ReputationColor)
                end

                ApplyTextureChange("health", TargetFrame.totFrame.HealthBar, TargetFrameToT)
                ApplyTextureChange("health", FocusFrame.totFrame.HealthBar, FocusFrameToT)
            end

            if db.changeUnitFrameManabarTexture then
                ApplyTextureChange("mana", CfPlayerFrameManaBar)
                ApplyTextureChange("mana", CfTargetFrameManaBar, nil, true)
                ApplyTextureChange("mana", CfFocusFrameManaBar, nil, true)
            end

            -- Apply class color override if enabled
            if not db.classColorFrames then
                local healthbars = {
                    CfPlayerFrameHealthBar,
                    CfTargetFrameHealthBar,
                    CfFocusFrameHealthBar
                }

                for _, healthbar in ipairs(healthbars) do
                    healthbar:SetStatusBarColor(0,1,0)
                end
            end
        else
            -- ClassicFrames is NOT enabled: Modify Blizzard's default unit frames
            if db.changeUnitFrameHealthbarTexture then
                ApplyTextureChange("health", PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar)
                ApplyTextureChange("health", PetFrame.healthbar, PetFrame)
                ApplyTextureChange("health", TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar, TargetFrame)
                ApplyTextureChange("health", FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar, FocusFrame)

                ApplyTextureChange("health", TargetFrame.totFrame.HealthBar, TargetFrameToT)
                ApplyTextureChange("health", FocusFrame.totFrame.HealthBar, FocusFrameToT)
            end

            if db.changeUnitFrameManabarTexture then
                manaTextureUnits["player"] = true
                manaTextureUnits["target"] = true
                manaTextureUnits["focus"] = true
                manaTextureUnits["pet"] = true

                ApplyTextureChange("mana", PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar)
                ApplyTextureChange("mana", PetFrame.manabar)
                ApplyTextureChange("mana", TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar)
                ApplyTextureChange("mana", FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar)

                manaTextureUnits["targettarget"] = true
                manaTextureUnits["focustarget"] = true
                ApplyTextureChange("mana", TargetFrame.totFrame.ManaBar)
                ApplyTextureChange("mana", FocusFrame.totFrame.ManaBar)
            end

            -- Apply class color override if enabled
            if not db.classColorFrames then
                local healthbars = {
                    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar,
                    PetFrame.healthbar,
                    TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar,
                    FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar,
                    TargetFrame.totFrame.HealthBar,
                    FocusFrame.totFrame.HealthBar
                }

                for _, healthbar in ipairs(healthbars) do
                    healthbar:SetStatusBarColor(0,1,0)
                end
            end
        end
    end


local function SetRaidFrameTextures(frame)
    --if not frame:IsShown() then return end
    local db = BetterBlizzFramesDB
    -- Retexture healthbars
    if db.changeRaidFrameHealthbarTexture then
        local originalTexture = frame.healthBar:GetStatusBarTexture()
        local originalLayer = originalTexture:GetDrawLayer()
        frame.healthBar:SetStatusBarTexture(raidHpTexture)
        originalTexture:SetDrawLayer(originalLayer)
    end

    -- Retexture manabars
    -- BetterBlizzFramesDB.textureSwapRaidFramesMana
    if db.changeRaidFrameManabarTexture then
        if not frame.powerBar then return end
        local originalTexture = frame.powerBar:GetStatusBarTexture()
        if not originalTexture then return end
        local originalLayer = originalTexture:GetDrawLayer()
        frame.powerBar:SetStatusBarTexture(raidManaTexture)
        originalTexture:SetDrawLayer(originalLayer)
    end
end

local function SetRaidFramePetTextures(frame)
    local db = BetterBlizzFramesDB
    -- Retexture healthbars
    if db.changeRaidFrameHealthbarTexture then
        local originalTexture = frame.healthBar:GetStatusBarTexture()
        local originalLayer = originalTexture:GetDrawLayer()
        frame.healthBar:SetStatusBarTexture(raidHpTexture)
        originalTexture:SetDrawLayer(originalLayer)
        frame.horizTopBorder:Hide()
        frame.horizBottomBorder:Hide()
        frame.vertLeftBorder:Hide()
        frame.vertRightBorder:Hide()
    end
end

local function HookRaidFrameTextures()
    hooksecurefunc("DefaultCompactUnitFrameSetup", SetRaidFrameTextures)
    if C_CVar.GetCVar("raidOptionDisplayPets") == "1" or C_CVar.GetCVar("raidOptionDisplayMainTankAndAssist") == "1" then
        hooksecurefunc("DefaultCompactMiniFrameSetup", SetRaidFramePetTextures)
        hooksecurefunc("CompactUnitFrame_SetUnit", function(frame)
            if frame.unit and (frame.unit:match("raidpet") or frame.unit:match("target")) then
                SetRaidFramePetTextures(frame)
            end
        end)
    end
end

function BBF.HookTextures()
    local db = BetterBlizzFramesDB
    -- Hook UnitFrames
    -- BetterBlizzFramesDB.textureSwapUnitFrames
    if db.changeUnitFrameHealthbarTexture or db.changeUnitFrameManabarTexture then
        HookUnitFrameTextures()
    end

    -- Hook Raidframes
    -- BetterBlizzFramesDB.textureSwapRaidFrames
    if db.changeRaidFrameHealthbarTexture or db.changeRaidFrameManabarTexture then
        if not BBF.HookRaidFrameTextures then
            HookRaidFrameTextures()
            BBF.HookRaidFrameTextures = true
        end

        for i = 1, 40 do
            local frame = _G["CompactPartyFrameMember"..i]
            if frame then
                SetRaidFrameTextures(frame)
            end
        end

        for i = 1, 8 do
            for j = 1, 5 do
                local raidFrame = _G["CompactRaidGroup" .. i .. "Member" .. j]
                if raidFrame then
                    SetRaidFrameTextures(raidFrame)
                end
            end
        end

        C_Timer.After(1, function()
            for i = 1, 5 do
                local frame = _G["CompactPartyFramePet"..i]
                if frame then
                    SetRaidFrameTextures(frame)
                end
            end
        end)
    end

end


function BBF.SymmetricPlayerFrame()
    if not BetterBlizzFramesDB.symmetricPlayerFrame then return end
    if InCombatLockdown() then
        print("BBF: Leave combat to enable this setting")
        return
    end
    -- Update Player Portrait Mask
    local portraitMask = PlayerFrame.PlayerFrameContainer.PlayerPortraitMask
    portraitMask:SetAtlas("CircleMask")
    portraitMask:SetSize(56, 56)
    portraitMask:SetPoint(select(1, portraitMask:GetPoint()), 27, -20)

    local a,b,c,d,e = PlayerLevelText:GetPoint()
    PlayerLevelText:SetPoint(a,b,c,-24,-27.7)

    local a,b,c,d,e = TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetPoint(a,b,c,d+1,e)

    -- Prevent portrait size changes
    hooksecurefunc(portraitMask, "SetSize", function(self)
        if not self.changing then
            self.changing = true
            self:SetSize(56, 56)
            self.changing = false
        end
    end)

    PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:SetAtlas(nil)

    -- Update Mana Bar
    local manaBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar
    manaBar:SetWidth(132)
    manaBar:SetPoint(select(1, manaBar:GetPoint()), 77, select(5, manaBar:GetPoint()))

    -- Store original points for text
    local leftTextPoint = { manaBar.LeftText:GetPoint() }
    local rightTextPoint = { manaBar.RightText:GetPoint() }
    local centerTextPoint = { manaBar.ManaBarText:GetPoint() }

    manaBar.LeftText:SetPoint(leftTextPoint[1], leftTextPoint[2], leftTextPoint[3], 11, leftTextPoint[5])
    manaBar.RightText:SetPoint(rightTextPoint[1], rightTextPoint[2], rightTextPoint[3], -5, rightTextPoint[5])
    manaBar.ManaBarText:SetPoint(centerTextPoint[1], centerTextPoint[2], centerTextPoint[3], 4.5, centerTextPoint[5])

    -- Hook for Mana Bar positioning and width
    hooksecurefunc(manaBar, "SetPoint", function(self)
        if not self.changing then
            self.changing = true
            self:SetPoint(select(1, manaBar:GetPoint()), 76, select(5, manaBar:GetPoint()))
            self.LeftText:SetPoint(leftTextPoint[1], leftTextPoint[2], leftTextPoint[3], 11, leftTextPoint[5])
            self.RightText:SetPoint(rightTextPoint[1], rightTextPoint[2], rightTextPoint[3], -5, rightTextPoint[5])
            self.ManaBarText:SetPoint(centerTextPoint[1], centerTextPoint[2], centerTextPoint[3], 4.5, centerTextPoint[5])
            self.changing = false
        end
    end)

    hooksecurefunc(manaBar, "SetWidth", function(self)
        if InCombatLockdown() then return end
        if not self.changing then
            self.changing = true
            self:SetWidth(136)
            self.changing = false
        end
    end)

    -- Update ManaBarMask texture
    local playerManaMask = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.ManaBarMask
    playerManaMask:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UIUnitFrameTargetManaMask2x-Flipped")
    playerManaMask:SetWidth(258.5)
    playerManaMask:SetPoint(select(1, playerManaMask:GetPoint()), -64, select(5, playerManaMask:GetPoint()))
    hooksecurefunc(playerManaMask, "SetAtlas", function(self)
        self:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UIUnitFrameTargetManaMask2x-Flipped")
        self:SetWidth(258.5)
        self:SetPoint(select(1, self:GetPoint()), -64, select(5, self:GetPoint()))
    end)

    -- Update Health Bar Mask texture
    local healthbarMask = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBarMask
    hooksecurefunc(healthbarMask, "SetAtlas", function(self)
        self:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UIUnitFrameTargetHealthMask2x-Flipped")
    end)
    healthbarMask:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UIUnitFrameTargetHealthMask2x-Flipped")

    healthbarMask:SetSize(129,32)

    hooksecurefunc(healthbarMask, "SetHeight", function(self)
        if self.changing then return end
        self.changing = true
        self:SetHeight(32)
        self.changing = false
    end)

    hooksecurefunc(playerManaMask, "SetWidth", function(self)
        if InCombatLockdown() then return end
        if self.changing then return end
        self.changing = true
        self:SetWidth(258.5)
        self.changing = false
    end)


    -- Hook for Health Bar positioning and width (+1 width, -1 x position)
    local healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar
    local healthBarPoint = { healthBar:GetPoint() }

    hooksecurefunc(healthBar, "SetPoint", function(self)
        if not self.changing then
            self.changing = true
            self:SetPoint(healthBarPoint[1], healthBarPoint[2], healthBarPoint[3], healthBarPoint[4] - 1.5, healthBarPoint[5]+1)
            self.changing = false
        end
    end)
    healthBar:SetPoint(healthBarPoint[1], healthBarPoint[2], healthBarPoint[3], healthBarPoint[4] - 1.5, healthBarPoint[5]+1)

    local playerPortrait = PlayerFrame.PlayerFrameContainer.PlayerPortrait
    local playerPortraitPoint = { playerPortrait:GetPoint() }
    playerPortrait:SetSize(58.5, 58.5)
    playerPortrait:SetPoint(playerPortraitPoint[1], playerPortraitPoint[2], playerPortraitPoint[3], playerPortraitPoint[4] + 2, playerPortraitPoint[5]+1)

    -- Hook for HealthBarsContainer width
    local healthBarsContainer = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
    hooksecurefunc(healthBarsContainer, "SetWidth", function(self)
        if InCombatLockdown() then return end
        if not self.changing then
            self.changing = true
            self:SetWidth(126)
            self.changing = false
        end
    end)
    healthBarsContainer:SetWidth(126)

    hooksecurefunc(healthBarsContainer, "SetHeight", function(self)
        if not self.changing then
            self.changing = true
            self:SetHeight(20.5)
            self.changing = false
        end
    end)
    healthBarsContainer:SetHeight(20.5)

    local rightTextPoint = { healthBarsContainer.RightText:GetPoint() }
    local leftTextPoint = { healthBarsContainer.LeftText:GetPoint() }
    local centerTextPoint = { healthBarsContainer.HealthBarText:GetPoint() }
    healthBarsContainer.RightText:SetPoint(rightTextPoint[1], rightTextPoint[2], rightTextPoint[3], -4, rightTextPoint[5]+1)
    healthBarsContainer.LeftText:SetPoint(leftTextPoint[1], leftTextPoint[2], leftTextPoint[3], leftTextPoint[4], leftTextPoint[5]+1)
    healthBarsContainer.HealthBarText:SetPoint(centerTextPoint[1], centerTextPoint[2], centerTextPoint[3], centerTextPoint[4], centerTextPoint[5]+1)

    -- Hook for Health Bar width
    hooksecurefunc(healthBar, "SetHeight", function(self)
        if InCombatLockdown() then return end
        if not self.changing then
            self.changing = true
            self:SetHeight(20)
            self.changing = false
        end
    end)
    healthBar:SetHeight(20)
    healthBar:SetWidth(126)


    local playerTex = PlayerFrame.PlayerFrameContainer.FrameTexture
    if BetterBlizzFramesDB.hideUnitFrameShadow then
        local targetTex = TargetFrame.TargetFrameContainer.FrameTexture:GetTexture()
        playerTex:SetTexture(targetTex)
        playerTex:SetSize(192, 67)
        playerTex:SetTexCoord(1,0,0,1)
        hooksecurefunc(playerTex, "SetAtlas", function(self)
            local targetTex = TargetFrame.TargetFrameContainer.FrameTexture:GetTexture()
            self:SetTexture(targetTex)
            self:SetSize(192, 67)
            self:SetTexCoord(1,0,0,1)
        end)
    else
        playerTex:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn")
        playerTex:SetSize(192, 67)
        playerTex:SetTexCoord(1,0,0,1)
        hooksecurefunc(playerTex, "SetAtlas", function(self)
            if self.changing then return end
            self.changing = true
            self:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn")
            self:SetSize(192, 67)
            self:SetTexCoord(1,0,0,1)
            self.changing = false
        end)
    end


    local playerFlash = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture
    hooksecurefunc(playerFlash, "SetAtlas", function(self)
        if self.changing then return end
        self.changing = true
        self:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn-Status")
        self:SetSize(194, 70)
        self:SetTexCoord(1,0,0,1)
        self.changing = false
    end)
    playerFlash:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn-Status")
    playerFlash:SetTexCoord(1,0,0,1)
    playerFlash:SetSize(194, 70)
    local a,b,c,d,e = playerFlash:GetPoint()
    playerFlash:SetPoint(a,b,c,20,-13.5)

    hooksecurefunc(playerFlash, "SetPoint", function(self)
        if self.changing then return end
        self.changing = true
        playerFlash:SetPoint(a,b,c,20,-13.5)
        self.changing = false
    end)

    local playerAltTex = PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture
    local altTex = BetterBlizzFramesDB.hideUnitFrameShadow and "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Target-PortraitOn-NoShadow-Alt" or "Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Target-PortraitOn-Alt"
    playerAltTex:SetTexture(altTex)
    playerAltTex:SetSize(192, 67)
    local a,b,c,d,e = playerAltTex:GetPoint()
    PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:SetPoint(a,b,c,0,-0.5)

    local playerThreat = PlayerFrame.threatIndicator
    hooksecurefunc(playerThreat, "SetAtlas", function(self)
        if self.changing then return end
        self.changing = true
        if playerAltTex:IsShown() then
            self:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-PortraitOn-InCombat-Alt")
            self:SetSize(192, 67.5)
        else
            self:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-InCombat")
            self:SetSize(188, 67)
            self:SetTexCoord(1,0,0,1)
        end
        self.changing = false
    end)
    if playerAltTex:IsShown() then
        playerThreat:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-PortraitOn-InCombat-Alt")
        playerThreat:SetSize(192, 67.5)
    else
        playerThreat:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-InCombat")
        playerThreat:SetTexCoord(1,0,0,1)
        playerThreat:SetSize(188, 67)
    end

    local a,b,c,d,e = playerThreat:GetPoint()
    if playerAltTex:IsShown() then
        playerThreat:SetPoint(a,b,c,0,1.5)
    else
        playerThreat:SetPoint(a,b,c,d+2,e)
    end
    hooksecurefunc(playerThreat, "SetPoint", function(self)
        if self.changing then return end
        self.changing = true
        if playerAltTex:IsShown() then
            playerThreat:SetPoint(a,b,c,0,1.5)
        else
            playerThreat:SetPoint(a,b,c,d+2,e)
        end

        self.changing = false
    end)

    local function ConfigurePowerBar(frame)
        -- Set point and width for the main power bar
        local a, b, c, d, e = frame:GetPoint()
        frame:SetPoint(a, b, c, 77, -72.5)
        frame:SetWidth(133)
        frame:SetHeight(10)

        -- Adjust the LeftText position
        local a, b, c, d, e = frame.LeftText:GetPoint()
        frame.LeftText:SetPoint(a, b, c, 10, e+0.5)

        -- Adjust the TextString position
        local a, b, c, d, e = frame.TextString:GetPoint()
        frame.TextString:SetPoint(a, b, c, 10, e+0.5)

        -- Adjust the TextString position
        local a, b, c, d, e = frame.RightText:GetPoint()
        frame.RightText:SetPoint(a, b, c,-3, e+0.5)

        -- Hook the PowerBarMask SetAtlas function
        hooksecurefunc(frame.PowerBarMask, "SetAtlas", function(self)
            self:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UIUnitFrameTargetManaMask2x-Alt")
            self:SetWidth(249)
        end)

        -- Apply settings to the PowerBarMask
        frame.PowerBarMask:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UIUnitFrameTargetManaMask2x-Alt")
        frame.PowerBarMask:SetWidth(249)
        frame.PowerBarMask:SetHeight(13)

        -- Adjust the PowerBarMask position
        local a, b, c, d, e = frame.PowerBarMask:GetPoint()
        frame.PowerBarMask:SetPoint(a, b, c, -57, 3)
    end

    -- Call the function for each frame
    local _, playerClass = UnitClass("player")

    if playerClass == "MONK" then
        ConfigurePowerBar(MonkStaggerBar)
    elseif playerClass == "EVOKER" then
        ConfigurePowerBar(EvokerEbonMightBar)
    elseif playerClass == "SHAMAN" or playerClass == "PRIEST" or playerClass == "DRUID" then
        ConfigurePowerBar(AlternatePowerBar)
    end
end

function BBF.AddBackgroundTextureToUnitFrames(frame)
    if not BetterBlizzFramesDB.addUnitFrameBgTexture and not frame.bbfBgTexture then
        return
    end

    local color = BetterBlizzFramesDB.unitFrameBgTextureColor
    if frame.bbfBgTexture then
        frame.bbfBgTexture:SetShown(not frame.bbfBgTexture:IsShown())
        frame.bbfBgTexture:SetColorTexture(unpack(color))
        return
    end
    local bgTex = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
    bgTex:SetColorTexture(unpack(color))

    local topAnchor = frame.healthbar or frame
    local bottomAnchor = frame.manabar or frame

    bgTex:SetPoint("TOPLEFT", topAnchor, "TOPLEFT", 0, 0)
    bgTex:SetPoint("BOTTOMRIGHT", bottomAnchor, "BOTTOMRIGHT", 0, 0)

    frame.bbfBgTexture = bgTex
end

function BBF.UnitFrameBackgroundTexture()
    BBF.AddBackgroundTextureToUnitFrames(PlayerFrame)
    BBF.AddBackgroundTextureToUnitFrames(TargetFrame)
    BBF.AddBackgroundTextureToUnitFrames(FocusFrame)
end




function BBF.HideTalkingHeads()
    if not BetterBlizzFramesDB.hideTalkingHeads then return end
    if BBF.hidingTalkingHeads then return end
    hooksecurefunc(TalkingHeadFrame, "PlayCurrent", function(self)
        self:Hide()
    end)
    BBF.hidingTalkingHeads = true
end

function BBF.FixStupidBlizzPTRShit()
    if InCombatLockdown() then return end
    if isAddonLoaded("ClassicFrames") then return end
    -- For god knows what reason PTR has a gap between Portrait and PlayerFrame. This fixes it + other gaps.
    --PlayerFrame.PlayerFrameContainer.PlayerPortrait:SetScale(1.02)
    PlayerFrame.PlayerFrameContainer.PlayerPortrait:SetSize(61,61)
    -- PlayerFrame.PlayerFrameContainer.PlayerPortrait:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", 22, -17)
    -- PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetScale(1.01)
    -- PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetSize(63,63)
    -- PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer, "TOPLEFT", 22, -16)

    -- local a, b, c, d, e = TargetFrame.totFrame.Portrait:GetPoint()
    -- TargetFrame.totFrame.Portrait:SetPoint(a, b, c, 6, -4)
    -- TargetFrame.TargetFrameContainer.Portrait:SetSize(57,57)

    -- local a, b, c, d, e = FocusFrame.totFrame.Portrait:GetPoint()
    -- FocusFrame.totFrame.Portrait:SetPoint(a, b, c, 6, -4)

    TargetFrame.totFrame.Portrait:SetSize(36,36)
    FocusFrame.totFrame.Portrait:SetSize(36,36)
    PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:SetSize(61,60)

    for i = 1, 4 do
        local memberFrame = PartyFrame["MemberFrame" .. i]
        if memberFrame and memberFrame.Portrait then
            memberFrame.Portrait:SetHeight(38)
        end
    end

    --Omniauras mask
    if C_AddOns.IsAddOnLoaded("OmniAuras") then
        for _, child in ipairs({PlayerFrame.PlayerFrameContainer:GetChildren()}) do
            if child:IsObjectType("Button") then
                local mask = child.mask
                if mask and mask.SetTexture then
                    mask:SetAtlas("UI-HUD-UnitFrame-Player-Portrait-Mask")
                    child:ClearAllPoints()
                    child:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContainer.PlayerPortrait, "TOPLEFT", 0, 0)
                    child:SetPoint("BOTTOMRIGHT", PlayerFrame.PlayerFrameContainer.PlayerPortrait, "BOTTOMRIGHT", 1, -1)
                    break
                end
            end
        end
    end

    --BBF.ShiftNamesCuzOCD()

    local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetPoint(a, b, c, d, -24)
    if not BBF.ocdAdjusted then
        local a,b,c,d,e = TargetFrame.bbfName:GetPoint()
        TargetFrame.bbfName:SetPoint(a,b,c,d,-2)
        local a,b,c,d,e = FocusFrame.bbfName:GetPoint()
        FocusFrame.bbfName:SetPoint(a,b,c,d,-2)
        BBF.ocdAdjusted = true
    end
    --TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetHeight()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetHeight(20)
    local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:GetPoint()
    TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetPoint(a, b, c, d, -3)

    local a, b, c, d, e = FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetPoint(a, b, c, d, -24)
    FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetHeight(20)
    local a, b, c, d, e = FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:GetPoint()
    FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetPoint(a, b, c, d, -3)


    -- HealthBarColorActive
    --if not BetterBlizzFramesDB.playerFrameOCDTextureBypass then
        local a, b, c, d, e = PlayerLevelText:GetPoint()
        PlayerLevelText:SetPoint(a,b,c,d,-28)
        -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBarMask:SetHeight(33)
        -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.ManaBarMask:SetPoint("TOPLEFT", PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar, "TOPLEFT", -2, 3)
        -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.ManaBarMask:SetHeight(17)
        -- PlayerFrame.healthbar:SetHeight(21)
        -- PlayerFrame.manabar:SetSize(125,12)
        -- local p, r, rr, x, y = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:GetPoint()
        -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:SetPoint(p, r, rr, -3, 0)
        -- --local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:GetPoint()
        -- --TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:ClearAllPoints()
        -- --TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:SetPoint(a, b, c, d, 99)
        -- TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBarMask:SetWidth(129)
        TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetSize(136, 10)
        TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.ManaBarMask:SetSize(258, 16)
        local point, relativeTo, relativePoint, xOffset, yOffset = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:GetPoint()
        TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetPoint(point, relativeTo, relativePoint, 9, yOffset)
        local p, r, rr, x, y = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:GetPoint()
        TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:SetPoint(p, r, rr, -14, y)
        local a, b, c, d, e = TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:GetPoint()
        TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:SetPoint(a,b,c,3,e)
        FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBarMask:SetWidth(129)
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetSize(136, 10)
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.ManaBarMask:SetSize(258, 16)
        local point, relativeTo, relativePoint, xOffset, yOffset = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:GetPoint()
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar:SetPoint(point, relativeTo, relativePoint, 9, yOffset)
        local p, r, rr, x, y = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:GetPoint()
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.RightText:SetPoint(p, r, rr, -14, y)
        local a, b, c, d, e = FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:GetPoint()
        FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar.LeftText:SetPoint(a,b,c,3,e)


        local a, b, c, d, e = TargetFrame.totFrame.HealthBar:GetPoint()
        TargetFrame.totFrame.HealthBar:SetPoint(a,b,c,-5,-5)
        TargetFrame.totFrame.HealthBar:SetSize(71, 13)
        TargetFrame.totFrame.ManaBar:SetSize(76, 8)
        local a, b, c, d, e = TargetFrame.totFrame.ManaBar:GetPoint()
        TargetFrame.totFrame.ManaBar:SetPoint(a,b,c,-5,3)
        TargetFrame.totFrame.ManaBar.ManaBarMask:SetWidth(130)
        TargetFrame.totFrame.ManaBar.ManaBarMask:SetHeight(17)
        local a, b, c, d, e = FocusFrame.totFrame.HealthBar:GetPoint()
        FocusFrame.totFrame.HealthBar:SetPoint(a,b,c,-5,-5)
        FocusFrame.totFrame.HealthBar:SetSize(71, 13)
        FocusFrame.totFrame.ManaBar:SetSize(77, 10)
        local a, b, c, d, e = FocusFrame.totFrame.ManaBar:GetPoint()
        FocusFrame.totFrame.ManaBar:SetPoint(a,b,c,-5,3)
        FocusFrame.totFrame.ManaBar.ManaBarMask:SetWidth(130)
        FocusFrame.totFrame.ManaBar.ManaBarMask:SetHeight(17)


        -- Textures to fill some gaps
        local v = (BetterBlizzFramesDB.darkModeUi and BetterBlizzFramesDB.darkModeColor == 0 and 0.2) or 0.35
        local texture = PlayerFrame:CreateTexture(nil, "BACKGROUND")
        texture:SetColorTexture(v, v, v, 1)
        texture:SetPoint("TOPLEFT", PlayerFrame.healthbar, "BOTTOMLEFT", 0, 0)
        texture:SetPoint("BOTTOMRIGHT", PlayerFrame.manabar, "TOPRIGHT", 0, -1)
        local texture = PlayerFrame:CreateTexture(nil, "BACKGROUND")
        texture:SetColorTexture(v, v, v, 1)
        texture:SetPoint("TOPLEFT", PlayerFrame.manabar, "BOTTOMLEFT", 0, 0)
        texture:SetPoint("BOTTOMRIGHT", PlayerFrame.manabar, "BOTTOMRIGHT", 0, -1)
        local texture = PlayerFrame:CreateTexture(nil, "BACKGROUND")
        texture:SetColorTexture(v, v, v, 1)
        texture:SetPoint("BOTTOMLEFT", PlayerFrame.healthbar, "TOPLEFT", 0, 0)
        texture:SetPoint("BOTTOMRIGHT", PlayerFrame.manabar, "TOPRIGHT", -2, 1)



        -- local a,b,c,d,e = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:GetPoint()
        -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:ClearAllPoints()
        -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.RightText:SetPoint(a,b,c,d,e-0.2)

        -- local a,b,c,d,e = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.LeftText:GetPoint()
        -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.LeftText:ClearAllPoints()
        -- PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar.LeftText:SetPoint(a,b,c,d,e-0.2)
    --end
end

function BBF.NormalizeGameMenu(enabled)
    if C_AddOns.IsAddOnLoaded("ClassicFrames") then return end
    GameMenuFrame:ClearAllPoints()
    GameMenuFrame:SetPoint("CENTER", UIParent, "CENTER", 0, enabled and 65 or 0)
    GameMenuFrame:SetScale(enabled and 0.75 or 1)
end

function BBF.MoveableFPSCounter(reset, font)
    if not BetterBlizzFramesDB.moveableFPSCounter then return end
    if reset then
        BetterBlizzFramesDB.fpsFramePos = nil
        FramerateFrame:UpdatePosition()
    end
    if font then
        local f,s,o = FramerateFrame.Label:GetFont()
        local newOutline
        if o ~= "OUTLINE" then
            newOutline = "OUTLINE"
        end
        FramerateFrame.FramerateText:SetFont(f,s,newOutline)
        FramerateFrame.Label:SetFont(f,s,newOutline)
    end
    if FramerateFrame.moveable then return end
    -- Make the frame movable
    FramerateFrame:SetMovable(true)
    FramerateFrame:EnableMouse(true)
    FramerateFrame:RegisterForDrag("LeftButton")
    --FramerateFrame:SetFrameStrata("FULLSCREEN_DIALOG")

    -- Restore position if saved
    local pos = BetterBlizzFramesDB.fpsFramePos
    if pos and pos.point then
        FramerateFrame:ClearAllPoints()
        FramerateFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)

        hooksecurefunc(FramerateFrame, "SetPoint", function(self)
            if self.changing then return end
            self.changing = true
            local pos = BetterBlizzFramesDB.fpsFramePos
            if not pos then
                self.changing = false
                return
            end
            self:ClearAllPoints()
            self:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
            self.changing = false
        end)
    end

    local BBF_FramerateFrame = CreateFrame("Frame")
    FramerateFrame:SetParent(BBF_FramerateFrame)

    -- Drag handlers
    FramerateFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    FramerateFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()

        -- Save new position
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        BetterBlizzFramesDB.fpsFramePos = {
            point = point,
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs
        }
    end)
    FramerateFrame.moveable = true
end

function BBF.MinimizeObjectiveTracker()
    if not ObjectiveTrackerFrame.Header.MinimizeButton.bbfHook then
        ObjectiveTrackerFrame.Header.MinimizeButton:HookScript("OnClick", function(self)
            local isCollapsed = ObjectiveTrackerFrame.isCollapsed
            ObjectiveTrackerFrame.Header.Background:SetAlpha(isCollapsed and 0 or 1)
            ObjectiveTrackerFrame.Header.Text:SetAlpha(isCollapsed and 0 or 1)
        end)
        ObjectiveTrackerFrame.Header.MinimizeButton.bbfHook = true
    end
end

function BBF.ActionBarMods()
    local db = BetterBlizzFramesDB

    -- Hide cast animation on action bar icons
    if db.hideActionBarCastAnimation then
        if not BBF.hideActionBarCastAnimation then
            local events = {
                "UNIT_SPELLCAST_INTERRUPTED",
                "UNIT_SPELLCAST_SUCCEEDED",
                "UNIT_SPELLCAST_FAILED",
                "UNIT_SPELLCAST_START",
                "UNIT_SPELLCAST_STOP",
                "UNIT_SPELLCAST_CHANNEL_START",
                "UNIT_SPELLCAST_CHANNEL_STOP",
                "UNIT_SPELLCAST_RETICLE_TARGET",
                "UNIT_SPELLCAST_RETICLE_CLEAR",
                "UNIT_SPELLCAST_EMPOWER_START",
                "UNIT_SPELLCAST_EMPOWER_STOP",
            }

            for _, event in ipairs(events) do
                ActionBarActionEventsFrame:UnregisterEvent(event)
            end
            BBF.hideActionBarCastAnimation = true
        end
    end

    -- Hide big proc glow on action bars
    if db.hideActionBarBigProcGlow then
        if not BBF.hideActionBarBigProcGlow then
            hooksecurefunc("ActionButton_ShowOverlayGlow", function(button)
                if button.SpellActivationAlert.ProcStartAnim:IsPlaying() then
                    button.SpellActivationAlert:SetAlpha(0)
                    C_Timer.After(0.26, function()
                        button.SpellActivationAlert:SetAlpha(1)
                    end)
                end
            end)
            BBF.hideActionBarBigProcGlow = true
        end
    end
end

local function TurnTestModesOff()
    BetterBlizzFramesDB.absorbIndicatorTestMode = false
    BetterBlizzFramesDB.partyCastBarTestMode = false
    BetterBlizzFramesDB.petCastBarTestMode = false
end

local function executeCustomCode()
    if BetterBlizzFramesDB and BetterBlizzFramesDB.customCode then
        local func, errorMsg = loadstring(BetterBlizzFramesDB.customCode)
        if func then
            func() -- Execute the custom code
        else
            print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Error in custom code:", errorMsg)
        end
    end
end

-- Event registration for PLAYER_LOGIN
local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")
--Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", function(...)

    executeCustomCode()
    CheckForUpdate()
    BBF.CompactPartyFrameScale()
    --BBF.HideFrames()
    DisableClickForClassSpecificFrame()
    BBF.MoveToTFrames()
    BBF.HookHealthbarColors()
    BBF.ResizeUIWidgetPowerBarFrame()

    local function LoginVariablesLoaded()
        if BBF.variablesLoaded then
            -- add setings updates
            BBF.AllNameChanges()
            BBF.UpdateUserDarkModeSettings()
            BBF.ChatFilterCaller()
            HookClassComboPoints()
            BBF.FadeMicroMenu()
            BBF.MoveQueueStatusEye()
            BBF.HideTalkingHeads()



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
            if BetterBlizzFramesDB.minimizeObjectiveTracker then
                BBF.MinimizeObjectiveTracker()
            end
            BBF.MoveToTFrames()
            BBF.UpdateUserAuraSettings()
            if BetterBlizzFramesDB.enableMasque then
                BBF.SetupMasqueSupport()
            end
            BBF.HookPlayerAndTargetAuras()

            if BetterBlizzFramesDB.playerFrameOCD then
                BBF.FixStupidBlizzPTRShit()
            end

            if BetterBlizzFramesDB.recolorTempHpLoss then
                BBF.RecolorHpTempLoss()
            end
            C_Timer.After(1, function()
                if BetterBlizzFramesDB.playerFrameOCD then
                    BBF.FixStupidBlizzPTRShit()
                end
                if BetterBlizzFramesDB.classColorFrames then
                    BBF.UpdateFrames()
                end
                if BetterBlizzFramesDB.normalizeGameMenu then
                    BBF.NormalizeGameMenu(true)
                end
                BBF.SetCenteredNamesCaller()
                BBF.ToggleCastbarInterruptIcon()
                BBF.DarkmodeFrames()
                --BBF.PlayerReputationColor()
                --BBF.ClassColorPlayerName()--bodify
                BBF.CheckForAuraBorders()
                BBF.MiniFrame(FocusFrame)
                BBF.MiniFrame(TargetFrame)
                BBF.MiniFrame(PlayerFrame)
                BBF.UpdateCastbars()
                BBF.ChangeLossOfControlScale()
                BBF.ChangeCastbarSizes()
            end)
            BBF.HideFrames()
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
        --InterfaceOptionsFrame_OpenToCategory(BetterBlizzFrames)
        if not BBF.category then
            print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Settings disabled. Likely due to error. Please update your addon.")
            --BBF.InitializeOptions()
            --Settings.OpenToCategory(BBF.category.ID)
        else
            Settings.OpenToCategory(BBF.category.ID)
        end
        BetterBlizzFramesDB.reopenOptions = false
    end
end)

-- Slash command
SLASH_BBF1 = "/BBF"
SlashCmdList["BBF"] = function(msg)
    local command, arg = msg:match("^(%S*)%s*(.-)$") -- Capture the command and argument
    command = string.lower(command or "")

    if command == "news" then
        NewsUpdateMessage()
    elseif command == "test" then
        --playerFrameTest()
    elseif command == "nahj" then
        StaticPopup_Show("BBF_CONFIRM_NAHJ_PROFILE")
    elseif command == "magnusz" then
        StaticPopup_Show("BBF_CONFIRM_MAGNUSZ_PROFILE")
    elseif command == "whitelist" or command == "wl" then
        if arg and arg ~= "" then
            if tonumber(arg) then
                -- The argument is a number, treat it as a spell ID
                local spellId = tonumber(arg)
                local spellName, _, icon = BBF.TWWGetSpellInfo(spellId)
                if spellName then
                    local iconString = "|T" .. icon .. ":16:16:0:0|t" -- Format the icon for display
                    BBF.auraWhitelist(spellId)
                    print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. spellId .. ") added to |cff00ff00whitelist|r.")
                else
                    print("Error: Invalid spell ID.")
                end
            else
                -- The argument is not a number, treat it as a spell name
                local spellName = arg
                BBF.auraWhitelist(spellName)
                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. spellName .. " was added to |cff00ff00whitelist|r.")
            end
        else
            print("Usage: /bbf whitelist <spellID or auraName>")
        end
    elseif command == "blacklist" or command == "bl" then
        if arg and arg ~= "" then
            if tonumber(arg) then
                -- The argument is a number, treat it as a spell ID
                local spellId = tonumber(arg)
                local spellName, _, icon = BBF.TWWGetSpellInfo(spellId)
                if spellName then
                    local iconString = "|T" .. icon .. ":16:16:0:0|t" -- Format the icon for display
                    BBF.auraBlacklist(spellId)
                    print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. iconString .. " " .. spellName .. " (" .. spellId .. ") added to |cffff0000blacklist|r.")
                else
                    print("Error: Invalid spell ID.")
                end
            else
                -- The argument is not a number, treat it as a spell name
                local spellName = arg
                BBF.auraBlacklist(spellName)
                print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: " .. spellName .. " was added to |cffff0000blacklist|r.")
            end
        else
            print("Usage: /bbf blacklist <spellID or auraName>")
        end
    elseif command == "ver" or command == "version" then
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames Version "..addonUpdates)
    elseif command == "dump" then
        local exportVersion = BetterBlizzFramesDB.exportVersion or "No export version registered"
        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: "..exportVersion)
    elseif command == "intro" then
        BBF.CreateIntroMessageWindow()
    else
        -- InterfaceOptionsFrame_OpenToCategory(BetterBlizzFrames)
        if not BBF.category then
            print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames: Settings disabled. Likely due to error. Please update your addon.")
            --BBF.InitializeOptions()
            --Settings.OpenToCategory(BBF.category.ID)
        else
            if not BetterBlizzFrames.guiLoaded then
                BBF.LoadGUI()
            else
                Settings.OpenToCategory(BBF.category.ID)
            end
        end
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
            BBF.SymmetricPlayerFrame()
            BBF.HookCastbars()
            BBF.EnableQueueTimer()
            ScaleClassResource()
            BBF.SurrenderNotLeaveArena()
            BBF.DruidBlueComboPoints()
            --BBF.AbsorbCaller()
            BBF.HookStatusBarText()
            BBF.ActionBarMods()
            BBF.UnitFrameBackgroundTexture()

            BBF.ClassColorReputationCaller()

            BBF.MoveableFPSCounter(false, BetterBlizzFramesDB.fpsCounterFontOutline)

            C_Timer.After(1, function()
                BBF.AbsorbCaller()
                BBF.SetCustomFonts()
                BBF.PlayerReputationColor()
                BBF.UpdateCustomTextures()
            end)
            --TurnOnEnabledFeaturesOnLogin()

            if BetterBlizzFramesDB.hideLossOfControlFrameLines == nil then
                if BetterBlizzFramesDB.hideLossOfControlFrameBg then
                    BetterBlizzFramesDB.hideLossOfControlFrameLines = true
                end
            end

            if not BetterBlizzFramesDB.optimizedAuraLists then
                if BetterBlizzFramesDB.hasSaved then
                    -- BetterBlizzFramesDB.auraBackups = {}
                    -- BetterBlizzFramesDB.auraBackups.whitelist = BetterBlizzFramesDB.auraWhitelist
                    -- BetterBlizzFramesDB.auraBackups.blacklist = BetterBlizzFramesDB.auraBlacklist

                    local optimizedWhitelist = {}
                    for _, aura in ipairs(BetterBlizzFramesDB["auraWhitelist"]) do
                        local key = aura["id"] or string.lower(aura["name"])
                        local flags = aura["flags"] or {}
                        local entryColors = aura["entryColors"] or {}
                        local textColors = entryColors["text"] or {}

                        optimizedWhitelist[key] = {
                            name = aura["name"] or nil,
                            id = aura["id"] or nil,
                            important = flags["important"] or nil,
                            pandemic = flags["pandemic"] or nil,
                            enlarged = flags["enlarged"] or nil,
                            compacted = flags["compacted"] or nil,
                            color = {textColors["r"] or 0, textColors["g"] or 1, textColors["b"] or 0, textColors["a"] or 1}
                        }
                    end
                    BetterBlizzFramesDB.auraWhitelist = optimizedWhitelist

                    local optimizedBlacklist = {}
                    for _, aura in ipairs(BetterBlizzFramesDB["auraBlacklist"]) do
                        local key = aura["id"] or string.lower(aura["name"])

                        optimizedBlacklist[key] = {
                            name = aura["name"] or nil,
                            id = aura["id"] or nil,
                            showMine = aura["showMine"] or nil,
                        }
                    end
                    BetterBlizzFramesDB.auraBlacklist = optimizedBlacklist


                    BetterBlizzFramesDB.optimizedAuraLists = true
                else
                    BetterBlizzFramesDB.optimizedAuraLists = true
                end
            else
                --BetterBlizzFramesDB.auraBackups = nil
            end

            if not BetterBlizzFramesDB.cleanedAuraBlacklist then
                local auraBlacklistFaulty = {
                    173183,  -- Elemental Blast: Haste
                    173184,  -- Elemental Blast: Mastery
                    117828,  -- Backdraft
                    59052,   -- Rime
                    202425,  -- Warrior of Elune
                    443454,  -- Ancestral Swiftness
                    260734,  -- Master of the Elements
                    266030,  -- Reverse Entropy
                    118522,  -- Elemental Blast: Critical Strike
                    156322,  -- Eternal Flame
                    236502,  -- Tidebringer
                    53390,   -- Tidal Waves
                    377253,  -- Frostwhelp's Aid
                    205146,  -- Demonic Calling
                    390105,  -- Save Them All
                    209746,  -- Moonkin Aura
                    116768,  -- Blackout Kick!
                    376850,  -- Power Swell
                    383997,  -- Arcane Tempo
                }

                -- Remove accidentally purgeable auras added to blacklist preset
                local removedAura = false
                for _, faultyId in ipairs(auraBlacklistFaulty) do
                    if BetterBlizzFramesDB.auraBlacklist[faultyId] then
                        print("BBF: Removed dispellable aura in blacklist: " .. (BetterBlizzFramesDB.auraBlacklist[faultyId].name or "Unknown") .. " (" .. faultyId .. ")")
                        BetterBlizzFramesDB.auraBlacklist[faultyId] = nil
                        removedAura = true
                    end
                end
                BetterBlizzFramesDB.cleanedAuraBlacklist = true
                if removedAura then
                    C_Timer.After(3, function()
                        DEFAULT_CHAT_FRAME:AddMessage("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rFrames: Removed roughly 20 auras from from the PvP blacklist preset (and your imported blacklist) due to them accidentally being added. They are purgeable and can be useful info and should not be blacklisted due to that.")
                    end)
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
end)
PlayerEnteringWorld:RegisterEvent("PLAYER_ENTERING_WORLD")







-- -- Clear combat log on entering arena and log all spell casts
-- C_Timer.After(1, function()
-- -- Clear combat log on entering arena and log all spell casts only while in arena
--     local frame = CreateFrame("Frame")
--     frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
--     frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    
--     BetterBlizzFramesDB.combatLog = BetterBlizzFramesDB.combatLog or {}
    
--     local inArena = false
    
--     frame:SetScript("OnEvent", function(self, event)
--         if event == "ZONE_CHANGED_NEW_AREA" then
--             local zoneType = select(2, IsInInstance())
--             inArena = (zoneType == "arena")
--             if inArena then
--                 BetterBlizzFramesDB.combatLog = {}
--             end
--         elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
--             local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
--                   destGUID, destName, destFlags, destRaidFlags, spellID, spellName = CombatLogGetCurrentEventInfo()
    
--             -- Track player's casts
--             if subEvent == "SPELL_CAST_SUCCESS" and spellID and spellName then
--                 if sourceGUID == UnitGUID("player") then
--                     print("Cast spell:", spellID, spellName)
--                 end
--                 if inArena and sourceGUID ~= UnitGUID("player") then
--                     BetterBlizzFramesDB.combatLog[spellID] = spellName
--                 end
--             end

--             -- Track Adaptation or similar effects
--             if subEvent == "SPELL_AURA_APPLIED" and destGUID == UnitGUID("player") then
--                 print("Aura applied:", spellID, spellName)
--             end
--         end
--     end)
-- end)
