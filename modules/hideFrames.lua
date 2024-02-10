local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()

--------------------------------------
-- Hide UI Frame Elements
--------------------------------------
local hookedRaidFrameManager = false
local hookedChatButtons = false
local changedResource = false
local originalResourceParent
local originalBossFrameParent
local bossFrameHooked

function BBF.HideFrames()
    if BetterBlizzFramesDB.hasCheckedUi then
        local playerClass, englishClass = UnitClass("player")
        --Hide group indicator on player unitframe
        local groupIndicatorAlpha = BetterBlizzFramesDB.hideGroupIndicator and 0 or 1
        PlayerFrameGroupIndicatorMiddle:SetAlpha(groupIndicatorAlpha)
        PlayerFrameGroupIndicatorText:SetAlpha(groupIndicatorAlpha)
        PlayerFrameGroupIndicatorLeft:SetAlpha(groupIndicatorAlpha)
        PlayerFrameGroupIndicatorRight:SetAlpha(groupIndicatorAlpha)

        -- Hide target leader icon
        local targetLeaderIconAlpha = BetterBlizzFramesDB.hideTargetLeaderIcon and 0 or 1
        TargetFrame.TargetFrameContent.TargetFrameContentContextual.LeaderIcon:SetAlpha(targetLeaderIconAlpha)

        -- Hide focus leader icon
        local focusLeaderIconAlpha = BetterBlizzFramesDB.hideTargetLeaderIcon and 0 or 1
        FocusFrame.TargetFrameContent.TargetFrameContentContextual.LeaderIcon:SetAlpha(focusLeaderIconAlpha)

        -- Hide Player Leader Icon
        local playerLeaderIconAlpha = BetterBlizzFramesDB.hidePlayerLeaderIcon and 0 or 1
        PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.LeaderIcon:SetAlpha(playerLeaderIconAlpha)

        -- PvP Timer Text
        if BetterBlizzFramesDB.hidePvpTimerText then
            PlayerPVPTimerText:SetParent(hiddenFrame)
        else
            PlayerPVPTimerText:SetParent(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual)
        end

        if BetterBlizzFramesDB.hideBossFrames then
            if not originalBossFrameParent then
                originalBossFrameParent = BossTargetFrameContainer:GetParent()
            end
            BossTargetFrameContainer:SetParent(hiddenFrame)
            if not bossFrameHooked then
                hiddenFrame:RegisterEvent("ENCOUNTER_START")
                hiddenFrame:RegisterEvent("ENCOUNTER_END")
                hiddenFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
                hiddenFrame:SetScript("OnEvent", function()
                    local inInstance, instanceType = IsInInstance()

                    if BetterBlizzFramesDB.hideBossFramesParty and inInstance and instanceType == "party" then
                        BossTargetFrameContainer:SetParent(hiddenFrame)
                    elseif BetterBlizzFramesDB.hideBossFramesRaid and inInstance and instanceType == "raid" then
                        BossTargetFrameContainer:SetParent(hiddenFrame)
                    else
                        BossTargetFrameContainer:SetParent(originalBossFrameParent)
                    end
                end)

                bossFrameHooked = true
            end
        else
            if bossFrameHooked then
                BossTargetFrameContainer:SetParent(originalBossFrameParent)
            end
        end

        -- Player Combat Icon
        local playerCombatIconAlpha = BetterBlizzFramesDB.hideCombatIcon and 0 or 1
        PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.AttackIcon:SetAlpha(playerCombatIconAlpha)

        -- Hide prestige (honor) icon on player unitframe
        local prestigeBadgeAlpha = BetterBlizzFramesDB.hidePrestigeBadge and 0 or 1
        PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigeBadge:SetAlpha(prestigeBadgeAlpha)
        PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigePortrait:SetAlpha(prestigeBadgeAlpha)
        TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:SetAlpha(prestigeBadgeAlpha)
        TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait:SetAlpha(prestigeBadgeAlpha)
        FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:SetAlpha(prestigeBadgeAlpha)
        FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait:SetAlpha(prestigeBadgeAlpha)

        -- Hide reputation color on target frame (color tint behind name)
        if BetterBlizzFramesDB.hideTargetReputationColor then
            TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()
        else
            TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Show()
        end

        if BetterBlizzFramesDB.hideFocusReputationColor then
            FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()
        else
            FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Show()
        end

        -- Hide rest loop animation
        if BetterBlizzFramesDB.hidePlayerRestAnimation then
            PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop:SetParent(hiddenFrame)
        else
            PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop:SetParent(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual)
        end

        -- Hide rested glow on unit frame
        if BetterBlizzFramesDB.hidePlayerRestGlow then
            PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetParent(hiddenFrame)
        else
            PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetParent(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain)
        end

        -- Hide corner icon
        if BetterBlizzFramesDB.hidePlayerCornerIcon then
            PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:SetParent(hiddenFrame)
        else
            PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:SetParent(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual)
        end

        -- Hide combat glow on player frame
        if BetterBlizzFramesDB.hideCombatGlow then
            PlayerFrame.PlayerFrameContainer.FrameFlash:SetParent(hiddenFrame)
            TargetFrame.TargetFrameContainer.Flash:SetParent(hiddenFrame)
            FocusFrame.TargetFrameContainer.Flash:SetParent(hiddenFrame)
            PetFrameFlash:SetParent(hiddenFrame)
            PetAttackModeTexture:SetParent(hiddenFrame)
        else
            PlayerFrame.PlayerFrameContainer.FrameFlash:SetParent(PlayerFrame.PlayerFrameContainer)
            TargetFrame.TargetFrameContainer.Flash:SetParent(TargetFrame.TargetFrameContainer)
            FocusFrame.TargetFrameContainer.Flash:SetParent(FocusFrame.TargetFrameContainer)
            PetFrameFlash:SetParent(PetFrame)
            PetAttackModeTexture:SetParent(PetFrame)
        end

        -- Hide Player level text
        if BetterBlizzFramesDB.hideLevelText then
            if BetterBlizzFramesDB.hideLevelTextAlways then
                PlayerLevelText:SetParent(hiddenFrame)
                TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetAlpha(0)
                FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetAlpha(0)
            else
                if UnitLevel("player") == 70 then
                    PlayerLevelText:SetParent(hiddenFrame)
                end
                if UnitLevel("target") == 70 then
                    --TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetParent(hiddenFrame)
                    TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetAlpha(0)
                end
                if UnitLevel("focus") == 70 then
                    --FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetParent(hiddenFrame)
                    FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetAlpha(0)
                end
            end
        else
            PlayerLevelText:SetParent(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain)
            --TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetParent(TargetFrame.TargetFrameContent.TargetFrameContentMain)
            --FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetParent(FocusFrame.TargetFrameContent.TargetFrameContentMain)
            TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetAlpha(1)
            FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetAlpha(1)
        end

        -- Hide "Party" text above party raid frames
        if BetterBlizzFramesDB.hidePartyFrameTitle then
            CompactPartyFrameTitle:Hide()
        else
            CompactPartyFrameTitle:Show()
        end

        -- Hide PvP Icon
        if BetterBlizzFramesDB.hidePvpIcon then
            TargetFrame.TargetFrameContent.TargetFrameContentContextual.PvpIcon:SetParent(hiddenFrame)
            PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PVPIcon:SetParent(hiddenFrame)
            FocusFrame.TargetFrameContent.TargetFrameContentContextual.PvpIcon:SetParent(hiddenFrame)
        else
            TargetFrame.TargetFrameContent.TargetFrameContentContextual.PvpIcon:SetParent(TargetFrame.TargetFrameContent.TargetFrameContentContextual)
            PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PVPIcon:SetParent(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual)
            FocusFrame.TargetFrameContent.TargetFrameContentContextual.PvpIcon:SetParent(FocusFrame.TargetFrameContent.TargetFrameContentContextual)
        end

        -- Hide role icons
        if BetterBlizzFramesDB.hidePlayerRoleIcon then
            PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.RoleIcon:SetParent(hiddenFrame)
        else
            PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.RoleIcon:SetParent(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual)
        end

        if BetterBlizzFramesDB.hideRaidFrameManager then
            CompactRaidFrameManager:SetAlpha(0)
            if not hookedRaidFrameManager then
                CompactRaidFrameManager:HookScript("OnEnter", function()
                    CompactRaidFrameManager:SetAlpha(1)
                end)
                CompactRaidFrameManager:HookScript("OnLeave", function()
                    C_Timer.After(1, function()
                        if CompactRaidFrameManager.collapsed then
                            CompactRaidFrameManager:SetAlpha(0)
                        end
                    end)
                end)
                hookedRaidFrameManager = true
            end
        end

        local function hideChatFrameTextures()
            for i = 1, NUM_CHAT_WINDOWS do
                local buttonFrame = _G["ChatFrame"..i.."ButtonFrame"]
                local topTexture = _G["ChatFrame"..i.."ButtonFrameTopTexture"]
                local topLeftTexture = _G["ChatFrame"..i.."ButtonFrameTopLeftTexture"]
                local topRightTexture = _G["ChatFrame"..i.."ButtonFrameTopRightTexture"]
                local bottomTexture = _G["ChatFrame"..i.."ButtonFrameBottomTexture"]
                local bottomLeftTexture = _G["ChatFrame"..i.."ButtonFrameBottomLeftTexture"]
                local bottomRightTexture = _G["ChatFrame"..i.."ButtonFrameBottomRightTexture"]
                local rightTexture = _G["ChatFrame"..i.."ButtonFrameRightTexture"]

                if buttonFrame then
                    if BetterBlizzFramesDB.hideChatButtons then
                        buttonFrame.Background:Hide()
                        topTexture:Hide()
                        topLeftTexture:Hide()
                        topRightTexture:Hide()
                        bottomTexture:Hide()
                        bottomLeftTexture:Hide()
                        bottomRightTexture:Hide()
                        rightTexture:Hide()
                    else
                        buttonFrame.Background:Show()
                        topTexture:Show()
                        topLeftTexture:Show()
                        topRightTexture:Show()
                        bottomTexture:Show()
                        bottomLeftTexture:Show()
                        bottomRightTexture:Show()
                        rightTexture:Show()
                    end
                end
            end
        end

        if BetterBlizzFramesDB.hidePlayerPower then
            if WarlockPowerFrame and englishClass == "WARLOCK" then
                originalResourceParent = WarlockPowerFrame:GetParent()
                WarlockPowerFrame:SetParent(hiddenFrame)
            end
            if RogueComboPointBarFrame and englishClass == "ROGUE" then
                originalResourceParent = RogueComboPointBarFrame:GetParent()
                RogueComboPointBarFrame:SetParent(hiddenFrame)
            end
            if DruidComboPointBarFrame and englishClass == "DRUID" then
                DruidComboPointBarFrame:SetAlpha(0)
            end
            if PaladinPowerBarFrame and englishClass == "PALADIN" then
                originalResourceParent = PaladinPowerBarFrame:GetParent()
                PaladinPowerBarFrame:SetParent(hiddenFrame)
            end
            if RuneFrame and englishClass == "DEATHKNIGHT" then
                originalResourceParent = RuneFrame:GetParent()
                RuneFrame:SetParent(hiddenFrame)
            end
            if EssencePlayerFrame and englishClass == "EVOKER" then
                originalResourceParent = EssencePlayerFrame:GetParent()
                EssencePlayerFrame:SetParent(hiddenFrame)
            end
            if MonkHarmonyBarFrame and englishClass == "MONK" then
                originalResourceParent = MonkHarmonyBarFrame:GetParent()
                MonkHarmonyBarFrame:SetParent(hiddenFrame)
            end
            if MageArcaneChargesFrame and englishClass == "MAGE" then
                MageArcaneChargesFrame:SetAlpha(0)
            end
            changedResource = true
        else
            if changedResource then
                if WarlockPowerFrame and originalResourceParent and englishClass == "WARLOCK" then
                    WarlockPowerFrame:SetParent(originalResourceParent)
                end
                if RogueComboPointBarFrame and originalResourceParent and englishClass == "ROGUE" then
                    RogueComboPointBarFrame:SetParent(originalResourceParent)
                end
                if DruidComboPointBarFrame and englishClass == "DRUID" then
                    DruidComboPointBarFrame:SetAlpha(1)
                end
                if PaladinPowerBarFrame and originalResourceParent and englishClass == "PALADIN" then
                    PaladinPowerBarFrame:SetParent(originalResourceParent)
                end
                if RuneFrame and originalResourceParent and englishClass == "DEATHKNIGHT" then
                    RuneFrame:SetParent(originalResourceParent)
                end
                if EssencePlayerFrame and originalResourceParent and englishClass == "EVOKER" then
                    EssencePlayerFrame:SetParent(originalResourceParent)
                end
                if MonkHarmonyBarFrame and originalResourceParent and englishClass == "MONK" then
                    MonkHarmonyBarFrame:SetParent(originalResourceParent)
                end
                if MageArcaneChargesFrame and englishClass == "MAGE" then
                    MageArcaneChargesFrame:SetAlpha(1)
                end
            end
        end

        if BetterBlizzFramesDB.hideChatButtons then
            QuickJoinToastButton:SetAlpha(0)
            ChatFrameChannelButton:SetAlpha(0)
            ChatFrameMenuButton:SetAlpha(0)
            TextToSpeechButton:SetAlpha(0)
            hideChatFrameTextures()

            if not hookedChatButtons then
                QuickJoinToastButton:HookScript("OnEnter", function()
                    QuickJoinToastButton:SetAlpha(1)
                    ChatFrameChannelButton:SetAlpha(1)
                    ChatFrameMenuButton:SetAlpha(1)
                    TextToSpeechButton:SetAlpha(1)
                end)
                QuickJoinToastButton:HookScript("OnLeave", function()
                    C_Timer.After(1, function()
                        QuickJoinToastButton:SetAlpha(0)
                        ChatFrameChannelButton:SetAlpha(0)
                        ChatFrameMenuButton:SetAlpha(0)
                        TextToSpeechButton:SetAlpha(0)
                    end)
                end)
                ChatFrameChannelButton:HookScript("OnEnter", function()
                    QuickJoinToastButton:SetAlpha(1)
                    ChatFrameChannelButton:SetAlpha(1)
                    ChatFrameMenuButton:SetAlpha(1)
                    TextToSpeechButton:SetAlpha(1)
                end)
                ChatFrameChannelButton:HookScript("OnLeave", function()
                    C_Timer.After(1, function()
                        QuickJoinToastButton:SetAlpha(0)
                        ChatFrameChannelButton:SetAlpha(0)
                        ChatFrameMenuButton:SetAlpha(0)
                        TextToSpeechButton:SetAlpha(0)
                    end)
                end)
                ChatFrameMenuButton:HookScript("OnEnter", function()
                    QuickJoinToastButton:SetAlpha(1)
                    ChatFrameChannelButton:SetAlpha(1)
                    ChatFrameMenuButton:SetAlpha(1)
                    TextToSpeechButton:SetAlpha(1)
                end)
                ChatFrameMenuButton:HookScript("OnLeave", function()
                    C_Timer.After(1, function()
                        QuickJoinToastButton:SetAlpha(0)
                        ChatFrameChannelButton:SetAlpha(0)
                        ChatFrameMenuButton:SetAlpha(0)
                        TextToSpeechButton:SetAlpha(0)
                    end)
                end)
                TextToSpeechButton:HookScript("OnEnter", function()
                    QuickJoinToastButton:SetAlpha(1)
                    ChatFrameChannelButton:SetAlpha(1)
                    ChatFrameMenuButton:SetAlpha(1)
                    TextToSpeechButton:SetAlpha(1)
                end)
                TextToSpeechButton:HookScript("OnLeave", function()
                    C_Timer.After(1, function()
                        QuickJoinToastButton:SetAlpha(0)
                        ChatFrameChannelButton:SetAlpha(0)
                        ChatFrameMenuButton:SetAlpha(0)
                        TextToSpeechButton:SetAlpha(0)
                    end)
                end)
                hookedChatButtons = true
            end
        else
            QuickJoinToastButton:SetAlpha(1)
            ChatFrameChannelButton:SetAlpha(1)
            ChatFrameMenuButton:SetAlpha(1)
            TextToSpeechButton:SetAlpha(1)
            hideChatFrameTextures()
        end
        BBF.HidePartyInArena()
        if BetterBlizzFramesDB.hideTargetToTDebuffs then
            for i = 1, 4 do
                local targetToTDebuff = _G["TargetFrameToTDebuff" .. i]
                if targetToTDebuff then
                    targetToTDebuff:SetParent(hiddenFrame)
                end
            end
        end
        if BetterBlizzFramesDB.hideFocusToTDebuffs then
            for i = 1, 4 do
                local focusToTDebuff = _G["FocusFrameToTDebuff" .. i]
                if focusToTDebuff then
                    focusToTDebuff:SetParent(hiddenFrame)
                end
            end
        end

        local LossOfControlFrameAlpha = BetterBlizzFramesDB.hideLossOfControlFrameBg and 0 or 1
        LossOfControlFrame.blackBg:SetAlpha(LossOfControlFrameAlpha)
        LossOfControlFrame.RedLineTop:SetAlpha(LossOfControlFrameAlpha)
        LossOfControlFrame.RedLineBottom:SetAlpha(LossOfControlFrameAlpha)
    end
end

local function UpdateLevelTextVisibility(unitFrame, unit)
    if BetterBlizzFramesDB.hideLevelText then
        if BetterBlizzFramesDB.hideLevelTextAlways then
            unitFrame.LevelText:SetAlpha(0)
            return
        end
        if UnitLevel(unit) == 70 then
            unitFrame.LevelText:SetAlpha(0)
        else
            unitFrame.LevelText:SetAlpha(1)
        end
    end
end

local function OnTargetOrFocusChanged(event, ...)
    UpdateLevelTextVisibility(TargetFrame.TargetFrameContent.TargetFrameContentMain, "target")
    UpdateLevelTextVisibility(FocusFrame.TargetFrameContent.TargetFrameContentMain, "focus")
end

local TargetLevelHider = CreateFrame("Frame")
TargetLevelHider:SetScript("OnEvent", OnTargetOrFocusChanged)
TargetLevelHider:RegisterEvent("PLAYER_TARGET_CHANGED")
TargetLevelHider:RegisterEvent("PLAYER_FOCUS_CHANGED")

--------------------------------------
-- Hide Party Frames in Arena
--------------------------------------
local partyAlpha = 1
function BBF.HidePartyInArena()
    if BetterBlizzFramesDB.hidePartyFramesInArena and not partyFrameHider then
        local partyFrameHider = CreateFrame("Frame")

        partyFrameHider:SetScript("OnEvent", function(self, event)
            if event == "PLAYER_ENTERING_BATTLEGROUND" and BetterBlizzFramesDB.hidePartyFramesInArena then
                partyAlpha = 0
            elseif event == "PLAYER_ENTERING_WORLD" and C_PvP.IsArena() == false then
                partyAlpha = 1
            end

            PartyFrame:SetAlpha(partyAlpha)
            PartyMemberBuffTooltip:SetAlpha(partyAlpha)
            CompactPartyFrameMember1Background:SetAlpha(partyAlpha)
            CompactPartyFrameMember2Background:SetAlpha(partyAlpha)
            CompactPartyFrameMember3Background:SetAlpha(partyAlpha)
            CompactPartyFrameMember1SelectionHighlight:SetAlpha(partyAlpha)
            CompactPartyFrameMember2SelectionHighlight:SetAlpha(partyAlpha)
            CompactPartyFrameMember3SelectionHighlight:SetAlpha(partyAlpha)
        end)
        partyFrameHider:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
        partyFrameHider:RegisterEvent("PLAYER_ENTERING_WORLD")
        if not C_PvP.IsArena() == false then
            partyAlpha = 0
        end
    elseif BetterBlizzFramesDB.hidePartyFramesInArena and partyFrameHider then
        if not C_PvP.IsArena() == false then
            partyAlpha = 0
        else
            partyAlpha = 1
        end
    elseif not BetterBlizzFramesDB.hidePartyFramesInArena then
        if partyFrameHider then
            partyFrameHider:UnregisterEvent("PLAYER_ENTERING_BATTLEGROUND")
            partyFrameHider:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end
        partyAlpha = 1
    end
end

--------------------------------------
-- Minimap Hider
--------------------------------------
local minimapStatusChanged
function BBF.MinimapHider(instanceType)
    local MinimapGroup = Minimap and MinimapCluster
    local QueueStatusEye = QueueStatusButtonIcon
    local ObjectiveTracker = ObjectiveTrackerFrame

    local inArena = instanceType == "arena"

    local hideMinimap = BetterBlizzFramesDB.hideMinimap
    local hideMinimapAuto = BetterBlizzFramesDB.hideMinimapAuto
    local hideQueueEye = BetterBlizzFramesDB.hideMinimapAutoQueueEye
    local hideObjectives = BetterBlizzFramesDB.hideObjectiveTracker

    if hideMinimap then
        MinimapGroup:Hide()
        minimapStatusChanged = true
        return
    elseif minimapStatusChanged then
        MinimapGroup:Show()
    end

    if hideMinimapAuto and inArena then
        MinimapGroup:Hide()
        if hideQueueEye then
            QueueStatusEye:Hide()
        end
        if hideObjectives then
            ObjectiveTracker:Hide()
        end
    elseif hideMinimapAuto and not inArena then
        MinimapGroup:Show()
        if hideQueueEye then
            QueueStatusEye:Show()
        end
    end
end