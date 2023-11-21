local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()

--------------------------------------
-- Hide UI Frame Elements
--------------------------------------
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
local function SetPartyFrameAlpha(alphaValue)
    local framesToAdjust = {
        "PartyFrame",
        "PartyMemberBuffTooltip",
        "CompactPartyFrameMember1Background",
        "CompactPartyFrameMember2Background",
        "CompactPartyFrameMember3Background",
        "CompactPartyFrameMember1SelectionHighlight",
        "CompactPartyFrameMember2SelectionHighlight",
        "CompactPartyFrameMember3SelectionHighlight"
    }

    for _, frameName in ipairs(framesToAdjust) do
        local frame = _G[frameName]
        if frame then
            frame:SetAlpha(alphaValue)
        end
    end
end

function BBF.HidePartyInArena()
    local partyFrameHider = CreateFrame("Frame")
    partyFrameHider:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    partyFrameHider:RegisterEvent("PLAYER_ENTERING_WORLD")

    partyFrameHider:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_BATTLEGROUND" or (event == "PLAYER_ENTERING_WORLD" and not C_PvP.IsArena()) then
            local alphaValue = event == "PLAYER_ENTERING_BATTLEGROUND" and 0 or 1
            SetPartyFrameAlpha(alphaValue)
        end
    end)

    if BetterBlizzFramesDB.hidePartyFramesInArena then
        SetPartyFrameAlpha(C_PvP.IsArena() and 0 or 1)
    else
        partyFrameHider:UnregisterEvent("PLAYER_ENTERING_BATTLEGROUND")
        partyFrameHider:UnregisterEvent("PLAYER_ENTERING_WORLD")
        SetPartyFrameAlpha(1)
    end
end