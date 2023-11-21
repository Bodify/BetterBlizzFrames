-- Setting up the database
BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}

--[[
local unitFrame = CreateFrame("FRAME")
unitFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
unitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
unitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
unitFrame:RegisterEvent("ADDON_LOADED")
unitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
]]


--[[
unitFrame:SetScript("OnEvent", function(self, event, addonName, ...)
    if (event == "ADDON_LOADED" and addonName == "BetterBlizzFrames") or event == "PLAYER_ENTERING_WORLD" then
        updateFrames()
    else
        updateFrames()
    end
end)
]]

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
    elseif BetterBlizzFramesDB.colorPetAfterOwner and UnitIsUnit(unit, "pet") then
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
    if BetterBlizzFramesDB.classColorFrames then
        local color = UnitIsPlayer(unit) and RAID_CLASS_COLORS[select(2, UnitClass(unit))] or getUnitColor(unit)
        frame:SetStatusBarDesaturated(true)
        frame:SetStatusBarColor(color.r, color.g, color.b)
    else
        frame:SetStatusBarDesaturated(false)
        frame:SetStatusBarColor(0,1,0)
    end
end

function BBF.UpdateFrames()
    if BetterBlizzFramesDB.classColorFrames then
        if UnitExists("player") then updateFrameColorToggleVer(PlayerFrame.healthbar, "player") end
        if UnitExists("target") then updateFrameColorToggleVer(TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBar, "target") end
        if UnitExists("focus") then updateFrameColorToggleVer(FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBar, "focus") end
        if UnitExists("targettarget") then updateFrameColorToggleVer(TargetFrameToT.HealthBar, "targettarget") end
        if UnitExists("focustarget") then updateFrameColorToggleVer(FocusFrameToT.HealthBar, "focustarget") end
        if UnitExists("party1") then updateFrameColorToggleVer(PartyFrame.MemberFrame1.HealthBar, "party1") end
        if UnitExists("party2") then updateFrameColorToggleVer(PartyFrame.MemberFrame2.HealthBar, "party2") end
        if UnitExists("party3") then updateFrameColorToggleVer(PartyFrame.MemberFrame3.HealthBar, "party3") end
        if UnitExists("party4") then updateFrameColorToggleVer(PartyFrame.MemberFrame4.HealthBar, "party4") end
    end
    if BetterBlizzFramesDB.colorPetAfterOwner then
        if UnitExists("pet") then updateFrameColorToggleVer(PetFrame.healthbar, "pet") end
    end
end

local function updateFrameColor(frame, unit)
    if BetterBlizzFramesDB.classColorFrames then
        local color = getUnitColor(unit)
        if color then
            frame:SetStatusBarDesaturated(true)
            frame:SetStatusBarColor(color.r, color.g, color.b)
        end
    --else
        --frame:SetStatusBarDesaturated(false)
        --frame:SetStatusBarColor(0, 1, 0)
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

hooksecurefunc("UnitFrameHealthBar_RefreshUpdateEvent", function(self)
    if self.unit then
        updateFrameColor(self, self.unit)
    end
end)

hooksecurefunc("UnitFrameHealthBar_Update", function(self, unit)
    if unit then
        updateFrameColor(self, unit)
    end
end)

hooksecurefunc("HealthBar_OnValueChanged", function(self)
    if self.unit then
        updateFrameColor(self, self.unit)
    end
end)

local function updateToTFrame()
    if UnitExists("targettarget") then
        updateFrameColorToggleVer(TargetFrameToT.HealthBar, "targettarget")
    end
end

hooksecurefunc(TargetFrameToT, "HealthCheck", updateToTFrame)




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