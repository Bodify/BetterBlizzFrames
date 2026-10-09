local FRAME_FADE_IN = 0.3
local HIGHLIGHT_FADE_IN = 0.4
local SHINE_FADE_IN = 0.3
local SHINE_FADE_OUT = 0.4
local COMBO_TEXTURE = 130973

local POINT_OFFSETS = {
    { -39, 7 },
    { -26.5, 8 },
    { -14, 7 },
    { -2.5, 1.5 },
    { 6.5, -7 },
    { 12, -18.5 },
    { 14, -30 },
    { 12, -41 },
    { 24, -33 },
}

BBF.LEGACY_COMBO_HIGHLIGHT_FADE_IN = HIGHLIGHT_FADE_IN

local updateHooks = {}
local lastComboPoints = 0

local function ShineFadeOut(shine)
    BBF.UIFrameFadeOut(shine, SHINE_FADE_OUT)
end

function BBF.LegacyComboShineFadeIn(shine)
    BBF.UIFrameFade(shine, {
        mode = "IN",
        timeToFade = SHINE_FADE_IN,
        finishedFunc = ShineFadeOut,
        finishedArg1 = shine,
    })
end

function BBF.LegacyCombosOn()
    local db = BetterBlizzFramesDB
    local class = UnitClassBase("player")
    if class == "ROGUE" or class == "DRUID" then
        return db.enableLegacyComboPoints and not db.foreverComboPoints and true or false
    end
    return db.enableLegacyComboPointsMulticlass and true or false
end

local frame = CreateFrame("Frame", "BBFLegacyComboFrame", TargetFrame)
frame:SetFrameStrata("MEDIUM")
frame:SetToplevel(true)
frame:SetSize(256, 32)
frame:SetPoint("TOPRIGHT", TargetFrame, "TOPRIGHT", -26, -13)
frame:SetAlpha(0)
frame:Hide()
frame.ComboPoints = {}
BBF.LegacyComboFrame = frame

for i, offset in ipairs(POINT_OFFSETS) do
    local point = CreateFrame("Frame", nil, frame)
    point:SetSize(12, 12)
    point:SetPoint("TOPRIGHT", frame, "TOPRIGHT", offset[1], offset[2])
    if i >= 7 then
        point:SetAlpha(0.6)
    end

    local bg = point:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture(COMBO_TEXTURE)
    bg:SetSize(12, 16)
    bg:SetPoint("TOPLEFT")
    bg:SetTexCoord(0, 0.375, 0, 1)

    local highlight = point:CreateTexture(nil, "ARTWORK")
    highlight:SetTexture(COMBO_TEXTURE)
    highlight:SetSize(8, 16)
    highlight:SetPoint("TOPLEFT", 2, 0)
    highlight:SetTexCoord(0.375, 0.5625, 0, 1)
    point.Highlight = highlight

    local shine = point:CreateTexture(nil, "OVERLAY")
    shine:SetTexture(COMBO_TEXTURE)
    shine:SetBlendMode("ADD")
    shine:SetSize(14, 16)
    shine:SetPoint("TOPLEFT", 0, 4)
    shine:SetTexCoord(0.5625, 1, 0, 1)
    shine:SetAlpha(0)
    point.Shine = shine

    frame.ComboPoints[i] = point
end
frame.ComboPoints[1].Highlight:SetAlpha(0)

local function UpdateMax(self)
    self.maxComboPoints = UnitPowerMax(PlayerFrame.unit, Enum.PowerType.ComboPoints)

    if self.maxComboPoints == 6 or self.maxComboPoints == 9 then
        self.startComboPointIndex = 1
        self.extraComboPoints = 7
    else
        self.startComboPointIndex = 2
        self.extraComboPoints = 6
    end

    for i = 1, #self.ComboPoints do
        self.ComboPoints[i]:Hide()
    end
end

local function Update(self)
    if not self.maxComboPoints then return end

    local comboPoints = GetComboPoints(PlayerFrame.unit, "target")

    if comboPoints > 0 then
        if not self:IsShown() then
            self:Show()
            BBF.UIFrameFadeIn(self, FRAME_FADE_IN)
        end

        local colorblind = C_CVar.GetCVarBool("colorblindMode")
        local comboIndex = self.startComboPointIndex
        for i = 1, self.maxComboPoints do
            local point = self.ComboPoints[comboIndex]
            if not point then break end
            if i <= comboPoints then
                if i > lastComboPoints then
                    BBF.UIFrameFade(point.Highlight, {
                        mode = "IN",
                        timeToFade = HIGHLIGHT_FADE_IN,
                        finishedFunc = BBF.LegacyComboShineFadeIn,
                        finishedArg1 = point.Shine,
                    })
                end
            else
                if colorblind then
                    point:Hide()
                end
                point.Highlight:SetAlpha(0)
                point.Shine:SetAlpha(0)
            end
            if i >= self.extraComboPoints then
                point:SetShown(comboPoints >= i)
            else
                point:Show()
            end
            comboIndex = comboIndex + 1
        end
    else
        self.ComboPoints[1].Highlight:SetAlpha(0)
        self.ComboPoints[1].Shine:SetAlpha(0)
        self:Hide()
    end
    lastComboPoints = comboPoints

    for _, hook in ipairs(updateHooks) do
        hook(self)
    end
end

frame:SetScript("OnEvent", function(self, event, unit)
    if event == "UNIT_POWER_FREQUENT" then
        if unit == PlayerFrame.unit then
            Update(self)
        end
    elseif event == "UNIT_MAXPOWER" or event == "PLAYER_ENTERING_WORLD" then
        UpdateMax(self)
        Update(self)
    else
        Update(self)
    end
end)

function BBF.HookLegacyComboUpdate(func)
    table.insert(updateHooks, func)
end

function BBF.UpdateLegacyComboFrame()
    Update(frame)
end

local ringParking = CreateFrame("Frame")
ringParking:Hide()

function BBF.UpdateBlizzardComboRing()
    local ring = ComboFrame
    if not ring or ring == frame or not ring.ComboPoints then return end
    local park = frame.bbfEnabled or (BBF.ComboPointBarWanted and BBF.ComboPointBarWanted())
    if park then
        if ring:GetParent() ~= ringParking then
            ring:SetParent(ringParking)
        end
    elseif ring:GetParent() == ringParking then
        BBF.ReleaseTargetArtLayer(ring)
        ring:SetParent(TargetFrame)
        ring:SetFrameStrata("MEDIUM")
        ring:SetFrameLevel(500)
        BBF.RaiseBlizzardComboRing()
    end
end

function BBF.RaiseBlizzardComboRing()
    local ring = ComboFrame
    if not ring or ring == frame or not ring.ComboPoints or ring:GetParent() ~= TargetFrame then return end
    if not TargetFrame.ClassicFrame and not TargetFrame.noPortraitMode then return end
    BBF.RaiseAboveTargetArt(ring, "MEDIUM")
end

function BBF.EnableLegacyComboFrame()
    if not frame.bbfEnabled then
        frame.bbfEnabled = true
        frame:RegisterEvent("PLAYER_TARGET_CHANGED")
        frame:RegisterEvent("UNIT_POWER_FREQUENT")
        frame:RegisterEvent("UNIT_MAXPOWER")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        if C_EventUtils.IsEventValid("COMBO_TARGET_CHANGED") then
            frame:RegisterEvent("COMBO_TARGET_CHANGED")
        end
        UpdateMax(frame)
        Update(frame)
    end
    BBF.UpdateBlizzardComboRing()
end

function BBF.DisableLegacyComboFrame()
    if frame.bbfEnabled then
        frame.bbfEnabled = nil
        frame:UnregisterAllEvents()
        frame.maxComboPoints = nil
        frame:Hide()
    end
    BBF.UpdateBlizzardComboRing()
end
