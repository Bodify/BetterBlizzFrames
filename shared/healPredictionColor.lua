local SEGMENTS = { "myHealPredictionBar", "otherHealPredictionBar" }
local RAID_TEXTURES = { "myHealPrediction", "otherHealPrediction" }

local color
local raidHooked

local function GetColor()
    local c = BetterBlizzFramesDB.healPredictionColor or BBF.defaultSettings.healPredictionColor
    color = CreateColor(c[1], c[2], c[3], c[4] or 1)
    return color
end

local function ColorUnitFrame(frame)
    if not frame then return end
    for i = 1, #SEGMENTS do
        local seg = frame[SEGMENTS[i]]
        if seg and seg.SetFillColor then
            seg:SetFillColor(color)
        end
    end
end

local function ColorUnitFrames()
    ColorUnitFrame(PlayerFrame)
    ColorUnitFrame(TargetFrame)
    ColorUnitFrame(FocusFrame)
    ColorUnitFrame(PetFrame)
    for i = 1, 5 do
        ColorUnitFrame(_G["Boss" .. i .. "TargetFrame"])
    end
    if PartyFrame and PartyFrame.PartyMemberFramePool then
        for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
            ColorUnitFrame(frame)
        end
    else
        for i = 1, 4 do
            ColorUnitFrame(_G["PartyMemberFrame" .. i])
        end
    end
end

local function RaidActive()
    local db = BetterBlizzFramesDB
    return db.changeHealPredictionColor and db.healPredictionColorRaidFrames
end

local function ColorRaidFrame(frame)
    if not color or not RaidActive() then return end
    if not frame or frame:IsForbidden() then return end
    local name = frame:GetName()
    if not name or not name:find("^Compact") then return end
    local r, g, b, a = color:GetRGBA()
    for i = 1, #RAID_TEXTURES do
        local tex = frame[RAID_TEXTURES[i]]
        if tex and tex.SetColorTexture then
            tex:SetColorTexture(r, g, b, a)
        end
    end
end

local function ColorRaidFrames()
    for i = 1, 5 do
        ColorRaidFrame(_G["CompactPartyFrameMember" .. i])
    end
    for i = 1, 40 do
        ColorRaidFrame(_G["CompactRaidFrame" .. i])
    end
    for group = 1, 8 do
        for i = 1, 5 do
            ColorRaidFrame(_G["CompactRaidGroup" .. group .. "Member" .. i])
        end
    end
end

local function HookRaidFrames()
    if raidHooked then return end
    raidHooked = true
    if DefaultCompactUnitFrameSetup then
        hooksecurefunc("DefaultCompactUnitFrameSetup", ColorRaidFrame)
    end
    if DefaultCompactMiniFrameSetup then
        hooksecurefunc("DefaultCompactMiniFrameSetup", ColorRaidFrame)
    end
    if CompactUnitFrameUtil and CompactUnitFrameUtil.ApplyConfig then
        hooksecurefunc(CompactUnitFrameUtil, "ApplyConfig", ColorRaidFrame)
    end
end

function BBF.HealPredictionColor()
    local db = BetterBlizzFramesDB
    if not db.changeHealPredictionColor then return end
    GetColor()
    if db.healPredictionColorUnitFrames then
        ColorUnitFrames()
    end
    if db.healPredictionColorRaidFrames then
        HookRaidFrames()
        ColorRaidFrames()
    end
end
