local UnitIsFriend = UnitIsFriend
local UnitIsEnemy = UnitIsEnemy
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass

local healthbarsHooked = nil
local classColorsOn
local colorPetAfterOwner

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
            return {r = color.r, g = color.g, b = color.b}
        end
    elseif colorPetAfterOwner and UnitIsUnit(unit, "pet") then
        -- Check if the unit is the player's pet and the setting is enabled
        local _, playerClass = UnitClass("player")
        local color = RAID_CLASS_COLORS[playerClass]
        if color then
            return {r = color.r, g = color.g, b = color.b}
        end
    else
        local reaction = getUnitReaction(unit)

        if reaction == "HOSTILE" then
            return {r = 1, g = 0, b = 0}
        elseif reaction == "NEUTRAL" then
            return {r = 1, g = 1, b = 0}
        else -- if reaction is "FRIENDLY"
            return {r = 0, g = 1, b = 0}
        end
    end
end

local function updateFrameColorToggleVer(frame, unit)
    if classColorsOn then
        --local color = UnitIsPlayer(unit) and RAID_CLASS_COLORS[select(2, UnitClass(unit))] or getUnitColor(unit) --bad
        local color = getUnitColor(unit)
        if color then
            frame:SetStatusBarDesaturated(true)
            frame:SetStatusBarColor(color.r, color.g, color.b)
        end
    end
end

local function resetFrameColor(frame, unit)
    frame:SetStatusBarDesaturated(false)
    frame:SetStatusBarColor(0,1,0)
end

local function UpdateHealthColor(frame, unit)
    --local color = UnitIsPlayer(unit) and RAID_CLASS_COLORS[select(2, UnitClass(unit))] or getUnitColor(unit)
    local color = getUnitColor(unit)
    if color then
        frame:SetStatusBarDesaturated(true)
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
        if UnitExists("target") then updateFrameColorToggleVer(TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBar, "target") end
        if UnitExists("focus") then updateFrameColorToggleVer(FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBar, "focus") end
        if UnitExists("targettarget") then updateFrameColorToggleVer(TargetFrameToT.HealthBar, "targettarget") end
        if UnitExists("focustarget") then updateFrameColorToggleVer(FocusFrameToT.HealthBar, "focustarget") end
        if UnitExists("party1") then updateFrameColorToggleVer(PartyFrame.MemberFrame1.HealthBar, "party1") end
        if UnitExists("party2") then updateFrameColorToggleVer(PartyFrame.MemberFrame2.HealthBar, "party2") end
        if UnitExists("party3") then updateFrameColorToggleVer(PartyFrame.MemberFrame3.HealthBar, "party3") end
        if UnitExists("party4") then updateFrameColorToggleVer(PartyFrame.MemberFrame4.HealthBar, "party4") end
    else
        if UnitExists("player") then resetFrameColor(PlayerFrame.healthbar, "player") end
        if UnitExists("target") then resetFrameColor(TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBar, "target") end
        if UnitExists("focus") then resetFrameColor(FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBar, "focus") end
        if UnitExists("targettarget") then resetFrameColor(TargetFrameToT.HealthBar, "targettarget") end
        if UnitExists("focustarget") then resetFrameColor(FocusFrameToT.HealthBar, "focustarget") end
        if UnitExists("party1") then resetFrameColor(PartyFrame.MemberFrame1.HealthBar, "party1") end
        if UnitExists("party2") then resetFrameColor(PartyFrame.MemberFrame2.HealthBar, "party2") end
        if UnitExists("party3") then resetFrameColor(PartyFrame.MemberFrame3.HealthBar, "party3") end
        if UnitExists("party4") then resetFrameColor(PartyFrame.MemberFrame4.HealthBar, "party4") end
    end
    if BetterBlizzFramesDB.colorPetAfterOwner then
        if UnitExists("pet") then updateFrameColorToggleVer(PetFrame.healthbar, "pet") end
    end
end

function BBF.UpdateFrameColor(frame, unit)
    local color = getUnitColor(unit)
    if color then
        frame:SetStatusBarDesaturated(true)
        frame:SetStatusBarColor(color.r, color.g, color.b)
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


        hooksecurefunc("UnitFrameHealthBar_Update", function(self, unit)
            if unit then
                UpdateHealthColor(self, unit)
                UpdateHealthColor(TargetFrameToT.HealthBar, "targettarget")
                UpdateHealthColor(FocusFrameToT.HealthBar, "focustarget")
            end
        end)

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

            frame.ReputationColor:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Type")
            frame.ReputationColor:SetSize(136, 20)
            frame.ReputationColor:SetTexCoord(1, 0, 0, 1)
            frame.ReputationColor:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -21, -25)
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