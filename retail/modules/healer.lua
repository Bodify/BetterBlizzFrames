local function CreateHealerIndicator(frame)
    if frame.bbfHealerIndicator then return end

    frame.bbfHealerIndicator = frame.bbfOverlayFrame:CreateTexture(nil, "OVERLAY")
    frame.bbfHealerIndicator:SetAtlas("bags-icon-addslots")
    frame.bbfHealerIndicator:SetSize(13, 13)
    frame.bbfHealerIndicator:Hide()
end

local secretBackdrop = "Interface\\Buttons\\WHITE8X8"
local secretIndicatorMap = { HEALER = "bags-icon-addslots", TANK = "", DAMAGER = "" }
local secretPortraitHealerMap = { HEALER = "UI-LFG-RoleIcon-Healer", TANK = "", DAMAGER = "" }
local secretPortraitBackdropMap = { HEALER = secretBackdrop, TANK = "", DAMAGER = "" }

local function UpdateHealerIndicator(frame, unit)
    local isHealer, secretIndex
    if UnitExists(unit) then
        isHealer, secretIndex = BBF.IsSpecHealer(unit)
    end

    if secretIndex then
        frame.bbfHealerIndicator:Hide()
        if not frame.bbfHealerIndicatorSecret then
            frame.bbfHealerIndicatorSecret = frame.bbfOverlayFrame:CreateTexture(nil, "OVERLAY")
            frame.bbfHealerIndicatorSecret:SetAllPoints(frame.bbfHealerIndicator)
        end
        BBF.SetSecretArenaRoleTexture(frame.bbfHealerIndicatorSecret, secretIndex, secretIndicatorMap)
        frame.bbfHealerIndicatorSecret:Show()
        return
    end

    if frame.bbfHealerIndicatorSecret then
        frame.bbfHealerIndicatorSecret:Hide()
    end
    if isHealer then
        frame.bbfHealerIndicator:Show()
    else
        frame.bbfHealerIndicator:Hide()
    end
end

local SECRET_FRAME_TEXTURE_SUBLEVEL = 5

local function CreateSecretPortraitTexture(portrait, mask, subLevel)
    local texture = portrait:GetParent():CreateTexture(nil, "BACKGROUND", nil, subLevel)
    texture:SetAllPoints(portrait)
    if mask then
        texture:AddMaskTexture(mask)
    end
    texture:Hide()
    return texture
end

local function HideSecretPortrait(frame)
    local overlay = frame.bbfSecretPortrait
    if overlay then
        overlay.spec:Hide()
        overlay.backdrop:Hide()
        overlay.healer:Hide()
    end
end

function BBF.UpdateSecretPortrait(frame)
    local unit = frame.unit
    local secretIndex
    if frame.portrait and (unit == "target" or unit == "focus") and UnitIsPlayer(unit) then
        local _
        _, secretIndex = BBF.GetSpecID(unit)
    end
    if not secretIndex then
        HideSecretPortrait(frame)
        return false
    end

    local db = BetterBlizzFramesDB
    local showSpec = db.classPortraitsUseSpecIcons and BBF.ArenaOpponentHasSpec(secretIndex)
    local showHealer = db.healerIndicator and db.healerIndicatorPortrait
    if not showSpec and not showHealer then
        HideSecretPortrait(frame)
        return false
    end

    local portrait = frame.portrait
    local portraitParent = portrait:GetParent()
    local container = frame.TargetFrameContainer
    local overlay = frame.bbfSecretPortrait
    if not overlay then
        local mask = (container and container.PortraitMask) or portraitParent.PortraitMask
        overlay = {
            spec = CreateSecretPortraitTexture(portrait, mask, 2),
            backdrop = CreateSecretPortraitTexture(portrait, mask, 3),
            healer = CreateSecretPortraitTexture(portrait, mask, 4),
        }
        local crop = 0.04
        overlay.spec:SetTexCoord(crop, 1 - crop, crop, 1 - crop)
        overlay.backdrop:SetVertexColor(0.1, 0.1, 0.1)
        overlay.parent = portraitParent
        frame.bbfSecretPortrait = overlay
    elseif overlay.parent ~= portraitParent then
        overlay.spec:SetParent(portraitParent)
        overlay.backdrop:SetParent(portraitParent)
        overlay.healer:SetParent(portraitParent)
        overlay.parent = portraitParent
    end
    if container and portraitParent == container and container.FrameTexture and not overlay.frameTextureRaised then
        container.FrameTexture:SetDrawLayer("BACKGROUND", SECRET_FRAME_TEXTURE_SUBLEVEL)
        overlay.frameTextureRaised = true
    end

    if showSpec then
        BBF.SetSecretArenaSpecIcon(overlay.spec, secretIndex)
        overlay.spec:Show()
    else
        overlay.spec:Hide()
    end

    if showHealer then
        BBF.SetSecretArenaRoleTexture(overlay.backdrop, secretIndex, secretPortraitBackdropMap)
        BBF.SetSecretArenaRoleTexture(overlay.healer, secretIndex, secretPortraitHealerMap)
        overlay.healer:SetTexCoord(0.13, 0.85, 0.13, 0.83)
        overlay.backdrop:Show()
        overlay.healer:Show()
    else
        overlay.backdrop:Hide()
        overlay.healer:Hide()
    end

    if frame.bbfHealerPortraitActive or frame.bbfSpecPortraitCropped then
        frame.portrait:SetTexCoord(0, 1, 0, 1)
        frame.bbfHealerPortraitActive = nil
        frame.bbfSpecPortraitCropped = nil
    end
    return true
end

local function UpdateHealerIndicatorOptions(frame)
    frame.bbfHealerIndicator:ClearAllPoints()
    frame.bbfHealerIndicator:SetPoint("CENTER", frame.TargetFrameContainer.Portrait, BetterBlizzFramesDB.healerIndicatorAnchor or "CENTER", (BetterBlizzFramesDB.healerIndicatorXPos or 0) + -35, (BetterBlizzFramesDB.healerIndicatorYPos or 0) + 15.7)
    frame.bbfHealerIndicator:SetScale(BetterBlizzFramesDB.healerIndicatorScale or 1)
end

function BBF.HealerIndicatorIcon()
    CreateHealerIndicator(TargetFrame)
    CreateHealerIndicator(FocusFrame)

    if not BBF.healerIndicatorEventFrame then
        BBF.healerIndicatorEventFrame = CreateFrame("Frame")
        BBF.healerIndicatorEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        BBF.healerIndicatorEventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        BBF.healerIndicatorEventFrame:SetScript("OnEvent", function(_, event)
            if event == "PLAYER_TARGET_CHANGED" then
                UpdateHealerIndicator(TargetFrame, "target")
            elseif event == "PLAYER_FOCUS_CHANGED" then
                UpdateHealerIndicator(FocusFrame, "focus")
            end
        end)
    end

    UpdateHealerIndicatorOptions(TargetFrame)
    UpdateHealerIndicatorOptions(FocusFrame)

    -- Initial update
    UpdateHealerIndicator(TargetFrame, "target")
    UpdateHealerIndicator(FocusFrame, "focus")
end

function BBF.HealerIndicatorPortrait()
    if BBF.healerPortrait then return end
    hooksecurefunc("UnitFramePortrait_Update", function(self)
        if BBF.UpdateSecretPortrait(self) then return end
        local unit = self.unit
        if (unit == "target" or unit == "focus" or unit == "player") and UnitIsPlayer(unit) then
            if BBF.IsSpecHealer(unit) and unit ~= "player" then
                self.portrait:SetAtlas("UI-LFG-RoleIcon-Healer")
                self.portrait:SetTexCoord(0.13,0.85,0.13,0.83)
                self.bbfHealerPortraitActive = true
            elseif BetterBlizzFramesDB.classPortraitsUseSpecIcons then
                if unit == "player" and BetterBlizzFramesDB.classPortraitsUseSpecIconsSkipSelf then
                    return
                end
                local specID = BBF.GetSpecID(self.unit)
                if specID then
                    local _, _, _, icon = GetSpecializationInfoByID(specID)
                    if icon then
                        local crop = 0.04
                        self.portrait:SetTexture(icon)
                        self.portrait:SetTexCoord(crop, 1 - crop, crop, 1 - crop)
                        self.bbfHealerPortraitActive = nil
                        return
                    end
                end
            elseif self.bbfHealerPortraitActive then
                self.portrait:SetTexCoord(0,1,0,1)
                self.bbfHealerPortraitActive = nil
            end
        elseif self.bbfHealerPortraitActive then
            self.portrait:SetTexCoord(0,1,0,1)
            self.bbfHealerPortraitActive = nil
        end
    end)
    BBF.healerPortrait = true
end

function BBF.HealerIndicatorCaller()
    if not BetterBlizzFramesDB.healerIndicator then return end
    if BetterBlizzFramesDB.healerIndicatorIcon then
        BBF.HealerIndicatorIcon()
    end
    if BetterBlizzFramesDB.healerIndicatorPortrait then
        BBF.HealerIndicatorPortrait()
    end
end