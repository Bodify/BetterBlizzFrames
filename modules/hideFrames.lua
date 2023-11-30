local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()

--------------------------------------
-- Hide UI Frame Elements
--------------------------------------
local hookedRaidFrameManager = false
local hookedChatButtons = false
function BBF.HideFrames()
    if BetterBlizzFramesDB.hasCheckedUi then
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
            if UnitLevel("player") == 70 then
                PlayerLevelText:SetParent(hiddenFrame)
            end
            if UnitLevel("target") == 70 then
                TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetParent(hiddenFrame)
            end
            if UnitLevel("focus") == 70 then
                FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetParent(hiddenFrame)
            end
        else
            PlayerLevelText:SetParent(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain)
            TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetParent(TargetFrame.TargetFrameContent.TargetFrameContentMain)
            FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelText:SetParent(FocusFrame.TargetFrameContent.TargetFrameContentMain)
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
            if WarlockPowerFrame then
                WarlockPowerFrame:SetParent(hiddenFrame)
            elseif RogueComboPointBarFrame then
                RogueComboPointBarFrame:SetParent(hiddenFrame)
            elseif DruidComboPointBarFrame then
                DruidComboPointBarFrame:SetParent(hiddenFrame)
            elseif PaladinPowerBarFrame then
                PaladinPowerBar:SetParent(hiddenFrame)
            elseif RuneFrame then
                RuneFrame:SetParent(hiddenFrame)
            elseif EssencePlayerFrame then
                EssencePlayerFrame:SetParent(hiddenFrame)
            end
        end

        if BetterBlizzFramesDB.hideChatButtons then
            QuickJoinToastButton:SetAlpha(0)
            ChatFrameChannelButton:SetAlpha(0)
            ChatFrameMenuButton:SetAlpha(0)
            hideChatFrameTextures()

            if not hookedChatButtons then
                QuickJoinToastButton:HookScript("OnEnter", function()
                    QuickJoinToastButton:SetAlpha(1)
                    ChatFrameChannelButton:SetAlpha(1)
                    ChatFrameMenuButton:SetAlpha(1)
                end)
                QuickJoinToastButton:HookScript("OnLeave", function()
                    C_Timer.After(1, function()
                        QuickJoinToastButton:SetAlpha(0)
                        ChatFrameChannelButton:SetAlpha(0)
                        ChatFrameMenuButton:SetAlpha(0)
                    end)
                end)
                ChatFrameChannelButton:HookScript("OnEnter", function()
                    QuickJoinToastButton:SetAlpha(1)
                    ChatFrameChannelButton:SetAlpha(1)
                    ChatFrameMenuButton:SetAlpha(1)
                end)
                ChatFrameChannelButton:HookScript("OnLeave", function()
                    C_Timer.After(1, function()
                        QuickJoinToastButton:SetAlpha(0)
                        ChatFrameChannelButton:SetAlpha(0)
                        ChatFrameMenuButton:SetAlpha(0)
                    end)
                end)
                ChatFrameMenuButton:HookScript("OnEnter", function()
                    QuickJoinToastButton:SetAlpha(1)
                    ChatFrameChannelButton:SetAlpha(1)
                    ChatFrameMenuButton:SetAlpha(1)
                end)
                ChatFrameMenuButton:HookScript("OnLeave", function()
                    C_Timer.After(1, function()
                        QuickJoinToastButton:SetAlpha(0)
                        ChatFrameChannelButton:SetAlpha(0)
                        ChatFrameMenuButton:SetAlpha(0)
                    end)
                end)
                hookedChatButtons = true
            end
        else
            QuickJoinToastButton:SetAlpha(1)
            ChatFrameChannelButton:SetAlpha(1)
            ChatFrameMenuButton:SetAlpha(1)
            hideChatFrameTextures()
        end
        BBF.HidePartyInArena()
    end
end

local function UpdateLevelTextVisibility(unitFrame, unit)
    if BetterBlizzFramesDB.hideLevelText and UnitLevel(unit) == 70 then
        unitFrame.LevelText:SetParent(hiddenFrame)
    else
        unitFrame.LevelText:SetParent(unitFrame)
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