local UnitIsFriend = UnitIsFriend
local UnitIsEnemy = UnitIsEnemy
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass

local healthbarsHooked = nil
local classColorsOn
local colorPetAfterOwner

local OnSetVertexColorHookScript = function(r, g, b, a)
    return function(frame, red, green, blue, alpha, flag)
        if flag ~= "BBFHookSetVertexColor" then
            frame:SetVertexColor(r, g, b, a, "BBFHookSetVertexColor")
        end
    end
end

function BBF.SetVertexColor(frame, r, g, b, a)
    frame:SetVertexColor(r, g, b, a, "BBFHookSetVertexColor")

    if (not frame.BBFHookSetVertexColor) then
        hooksecurefunc(frame, "SetVertexColor", OnSetVertexColorHookScript(r, g, b, a))
        frame.BBFHookSetVertexColor = true
    end
end

local function getUnitReaction(unit)
    if UnitIsFriend("player", unit) then
        return "FRIENDLY"
    elseif UnitIsEnemy("player", unit) then
        return "HOSTILE"
    else
        return "NEUTRAL"
    end
end

local function getUnitColor(unit)
    if UnitIsPlayer(unit) then
        local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
        if color then
            return {r = color.r, g = color.g, b = color.b}, false
        end
    elseif colorPetAfterOwner and UnitIsUnit(unit, "pet") then
        -- Check if the unit is the player's pet and the setting is enabled
        local _, playerClass = UnitClass("player")
        local color = RAID_CLASS_COLORS[playerClass]
        if color then
            return {r = color.r, g = color.g, b = color.b}, false
        end
    else
        local reaction = getUnitReaction(unit)

        if reaction == "HOSTILE" then
            return {r = 1, g = 0, b = 0}, false
        elseif reaction == "NEUTRAL" then
            return {r = 1, g = 1, b = 0}, false
        elseif reaction == "FRIENDLY" then
            return {r = 0, g = 1, b = 0}, true
        end
    end
end

local function updateFrameColorToggleVer(frame, unit)
    if not frame then return end
    if not frame.SetStatusBarDesaturated then return end
    if unit == "player" and BetterBlizzFramesDB.classColorFramesSkipPlayer then return end
    if classColorsOn then
        local color, isFriendly = getUnitColor(unit)
        if color then
            if isFriendly then
                frame:SetStatusBarDesaturated(false)
                frame:SetStatusBarColor(1, 1, 1)
            else
                frame:SetStatusBarDesaturated(true)
                frame:SetStatusBarColor(color.r, color.g, color.b)
            end
        end
    end
end

BBF.updateFrameColorToggleVer = updateFrameColorToggleVer

local function resetFrameColor(frame, unit)
    frame:SetStatusBarDesaturated(false)
    frame:SetStatusBarColor(1,1,1)
end

local validUnits = {
    player = true,
    target = true,
    targettarget = true,
    focus = true,
    focustarget = true,
    pet = true,
    party1 = true,
    party2 = true,
    party3 = true,
    party4 = true,
}

local function UpdateHealthColor(frame, unit)
    if not validUnits[unit] then return end
    local skipPlayer = BetterBlizzFramesDB.classColorFramesSkipPlayer
    if unit == "player" and skipPlayer then return end
    local color, isFriendly = getUnitColor(unit)
    if color then
        if isFriendly then
            frame:SetStatusBarDesaturated(false)
            frame:SetStatusBarColor(1, 1, 1)
        else
            frame:SetStatusBarDesaturated(true)
            frame:SetStatusBarColor(color.r, color.g, color.b)
        end
    end
end

local function UpdateHealthColorCF(frame, unit)
    if unit == "player" and BetterBlizzFramesDB.classColorFramesSkipPlayer then return end
    local color, isFriendly = getUnitColor(unit)
    if color then
        --frame:SetStatusBarDesaturated(true)
        frame:SetStatusBarColor(color.r, color.g, color.b)
    end
end

function BBF.UpdateToTColor()
    updateFrameColorToggleVer(TargetFrameToT.HealthBar, "targettarget")
end

function BBF.UpdateFrames()
    classColorsOn = BetterBlizzFramesDB.classColorFrames
    colorPetAfterOwner = BetterBlizzFramesDB.colorPetAfterOwner
    if classColorsOn then
        BBF.HookHealthbarColors()
        if UnitExists("player") then updateFrameColorToggleVer(PlayerFrame.healthbar, "player") end
        if UnitExists("target") then updateFrameColorToggleVer(TargetFrame.healthbar, "target") end
        if UnitExists("focus") then updateFrameColorToggleVer(FocusFrame.healthbar, "target", "focus") end
        if UnitExists("targettarget") then updateFrameColorToggleVer(TargetFrameToT.HealthBar, "targettarget") end
        if UnitExists("focustarget") then updateFrameColorToggleVer(FocusFrameToT.HealthBar, "focustarget") end
        if UnitExists("party1") then updateFrameColorToggleVer(PartyFrame.MemberFrame1.HealthBarContainer.HealthBar, "party1") end
        if UnitExists("party2") then updateFrameColorToggleVer(PartyFrame.MemberFrame2.HealthBarContainer.HealthBar, "party2") end
        if UnitExists("party3") then updateFrameColorToggleVer(PartyFrame.MemberFrame3.HealthBarContainer.HealthBar, "party3") end
        if UnitExists("party4") then updateFrameColorToggleVer(PartyFrame.MemberFrame4.HealthBarContainer.HealthBar, "party4") end
    else
        if UnitExists("player") then resetFrameColor(PlayerFrame.healthbar, "player") end
        if UnitExists("target") then resetFrameColor(TargetFrame.healthbar, "target") end
        if UnitExists("focus") then resetFrameColor(FocusFrame.healthbar, "focus") end
        if UnitExists("targettarget") then resetFrameColor(TargetFrameToT.HealthBar, "targettarget") end
        if UnitExists("focustarget") then resetFrameColor(FocusFrameToT.HealthBar, "focustarget") end
        if UnitExists("party1") then resetFrameColor(PartyFrame.MemberFrame1.HealthBarContainer.HealthBar, "party1") end
        if UnitExists("party2") then resetFrameColor(PartyFrame.MemberFrame2.HealthBarContainer.HealthBar, "party2") end
        if UnitExists("party3") then resetFrameColor(PartyFrame.MemberFrame3.HealthBarContainer.HealthBar, "party3") end
        if UnitExists("party4") then resetFrameColor(PartyFrame.MemberFrame4.HealthBarContainer.HealthBar, "party4") end
    end
    if BetterBlizzFramesDB.colorPetAfterOwner then
        if UnitExists("pet") then updateFrameColorToggleVer(PetFrame.healthbar, "pet") end
    end
end

function BBF.UpdateFrameColor(frame, unit)
    local color = getUnitColor(unit)
    if color then
        if color == "FRIENDLY" then
            frame:SetStatusBarDesaturated(false)
            frame:SetStatusBarColor(1, 1, 1)
        else
            frame:SetStatusBarDesaturated(true)
            frame:SetStatusBarColor(color.r, color.g, color.b)
        end
    end
end

function BBF.ClassColorReputation(frame, unit)
    local color = getUnitColor(unit)
    if color then
        frame:SetDesaturated(true)
        frame:SetVertexColor(color.r, color.g, color.b)
    end
end

function BBF.ResetClassColorReputation(frame, unit)
    local color = getUnitColor(unit)
    if color then
        frame:SetDesaturated(false)
        frame:SetVertexColor(UnitSelectionColor(unit))
    end
end

function BBF.HookHealthbarColors()
    if not healthbarsHooked and classColorsOn then
--[[
        hooksecurefunc("UnitFrameHealthBar_RefreshUpdateEvent", function(self) --pet frames only?
            if self.unit then
                print(self:GetName())
                print(self.unit)
                --UpdateHealthColor(self, self.unit)
                --UpdateHealthColor(TargetFrameToT.HealthBar, "targettarget")
                --UpdateHealthColor(FocusFrameToT.HealthBar, "focustarget")
            end
        end)
]]
        local function HookCfSetStatusBarColor(frame, unit)
            if not frame.SetStatusBarColorHooked then
                hooksecurefunc(frame, "SetStatusBarColor", function(self, r, g, b, a)
                    if not frame.recoloring then
                        frame.recoloring = true
                        local color = getUnitColor(unit)
                        if color then
                            frame:SetStatusBarColor(color.r, color.g, color.b)
                        end
                        frame.recoloring = false
                    end
                end)
                local color = getUnitColor(unit)
                if color then
                    frame:SetStatusBarColor(color.r, color.g, color.b)
                end
                frame.SetStatusBarColorHooked = true
            end
        end

        if C_AddOns.IsAddOnLoaded("ClassicFrames") then
            hooksecurefunc("UnitFrameHealthBar_Update", function(self, unit)
                if unit then
                    UpdateHealthColorCF(TargetFrameToT.HealthBar, "targettarget")
                    UpdateHealthColorCF(FocusFrameToT.HealthBar, "focustarget")
                end
            end)
            if CfPlayerFrameHealthBar then
                if not BetterBlizzFramesDB.classColorFramesSkipPlayer then
                    HookCfSetStatusBarColor(CfPlayerFrameHealthBar, "player")
                end
                HookCfSetStatusBarColor(CfTargetFrameHealthBar, "target")
                HookCfSetStatusBarColor(CfFocusFrameHealthBar, "focus")
            else
                print("ClassicFrames healthbars not detected. Please report to dev @bodify")
            end
        else
            hooksecurefunc("UnitFrameHealthBar_Update", function(self, unit)
                if unit then
                    UpdateHealthColor(self, unit)
                    UpdateHealthColor(TargetFrameToT.HealthBar, "targettarget")
                    UpdateHealthColor(FocusFrameToT.HealthBar, "focustarget")
                end
            end)
        end

--[[
        hooksecurefunc("HealthBar_OnValueChanged", function(self)
            if self.unit then
                UpdateHealthColor(self, self.unit)
                print(self:GetName())
                print(self.unit)
                --UpdateHealthColor(TargetFrameToT.HealthBar, "targettarget")
                --UpdateHealthColor(FocusFrameToT.HealthBar, "focustarget")
            end
        end)

]]


        healthbarsHooked = true
    end
end

function BBF.PlayerReputationColor()
    local frame = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
    if BetterBlizzFramesDB.playerReputationColor then
        if not frame.ReputationColor then
            frame.ReputationColor = frame:CreateTexture(nil, "OVERLAY")
            if C_AddOns.IsAddOnLoaded("ClassicFrames") then
                frame.ReputationColor:SetTexture(137017)
                frame.ReputationColor:SetSize(117, 19)
                frame.ReputationColor:SetTexCoord(1, 0, 0, 1)
                frame.ReputationColor:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -26, -26)
            else
                frame.ReputationColor:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Type")
                frame.ReputationColor:SetSize(136, 20)
                frame.ReputationColor:SetTexCoord(1, 0, 0, 1)
                frame.ReputationColor:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -21, -25)
            end
        else
            frame.ReputationColor:Show()
        end
        if BetterBlizzFramesDB.playerReputationClassColor then
            local color = getUnitColor("player")
            if color then
                frame.ReputationColor:SetDesaturated(true)
                frame.ReputationColor:SetVertexColor(color.r, color.g, color.b)
            end
        else
            frame.ReputationColor:SetDesaturated(false)
            frame.ReputationColor:SetVertexColor(UnitSelectionColor("player"))
        end
    else
        if frame.ReputationColor then
            frame.ReputationColor:Hide()
        end
    end
end