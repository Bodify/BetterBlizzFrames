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

local function ForEachUnitFrame(fn)
    fn(PlayerFrame)
    fn(TargetFrame)
    fn(FocusFrame)
    fn(PetFrame)
    for i = 1, 5 do
        fn(_G["Boss" .. i .. "TargetFrame"])
    end
    if PartyFrame and PartyFrame.PartyMemberFramePool then
        for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
            fn(frame)
        end
    else
        for i = 1, 4 do
            fn(_G["PartyMemberFrame" .. i])
        end
    end
end

local function RaidActive()
    local db = BetterBlizzFramesDB
    return db.changeHealPredictionColor and db.healPredictionColorRaidFrames
end

local function IsRaidFrame(frame)
    if not frame or frame:IsForbidden() then return end
    local name = frame:GetName()
    return name and name:find("^Compact")
end

local function ColorRaidFrame(frame)
    if not color or not RaidActive() then return end
    if not IsRaidFrame(frame) then return end
    local r, g, b, a = color:GetRGBA()
    for i = 1, #RAID_TEXTURES do
        local tex = frame[RAID_TEXTURES[i]]
        if tex and tex.SetColorTexture then
            tex:SetColorTexture(r, g, b, a)
        end
    end
end

local function ForEachRaidFrame(fn)
    for i = 1, 5 do
        fn(_G["CompactPartyFrameMember" .. i])
    end
    for i = 1, 40 do
        fn(_G["CompactRaidFrame" .. i])
    end
    for group = 1, 8 do
        for i = 1, 5 do
            fn(_G["CompactRaidGroup" .. group .. "Member" .. i])
        end
    end
end

local hidden

local function HideRaidFrame(frame)
    if not hidden or not IsRaidFrame(frame) then return end
    local alpha = BetterBlizzFramesDB.hideHealPrediction and 0 or 1
    for i = 1, #RAID_TEXTURES do
        local tex = frame[RAID_TEXTURES[i]]
        if tex then
            tex:SetAlpha(alpha)
        end
    end
end

local function OnRaidSetup(frame)
    ColorRaidFrame(frame)
    HideRaidFrame(frame)
end

local function HookRaidFrames()
    if raidHooked then return end
    raidHooked = true
    if DefaultCompactUnitFrameSetup then
        hooksecurefunc("DefaultCompactUnitFrameSetup", OnRaidSetup)
    end
    if DefaultCompactMiniFrameSetup then
        hooksecurefunc("DefaultCompactMiniFrameSetup", OnRaidSetup)
    end
    if CompactUnitFrameUtil and CompactUnitFrameUtil.ApplyConfig then
        hooksecurefunc(CompactUnitFrameUtil, "ApplyConfig", OnRaidSetup)
    end
end

function BBF.HealPredictionColor()
    local db = BetterBlizzFramesDB
    if not db.changeHealPredictionColor then return end
    GetColor()
    if db.healPredictionColorUnitFrames then
        ForEachUnitFrame(ColorUnitFrame)
    end
    if db.healPredictionColorRaidFrames then
        HookRaidFrames()
        ForEachRaidFrame(OnRaidSetup)
    end
end

local function HideUnitFrame(frame)
    if not frame then return end
    local alpha = BetterBlizzFramesDB.hideHealPrediction and 0 or 1
    for i = 1, #SEGMENTS do
        local seg = frame[SEGMENTS[i]]
        if seg then
            seg:SetAlpha(alpha)
        end
    end
end

function BBF.HideHealPrediction()
    local on = BetterBlizzFramesDB.hideHealPrediction
    if not on and not hidden then return end
    hidden = true
    ForEachUnitFrame(HideUnitFrame)
    if BBF.HealthbarMirrorHealPredictionAlpha then
        BBF.HealthbarMirrorHealPredictionAlpha(on and 0 or 1)
    end
    HookRaidFrames()
    ForEachRaidFrame(HideRaidFrame)
end
