local bordered = {}
local pendingRound = {}
local eventFrame

local function RoundToPixel(region)
    if region.bbfPixelRounded or not region.SetRoundLayoutToNearestPixel then return end
    if InCombatLockdown() then
        pendingRound[region] = true
        return
    end
    region.bbfPixelRounded = true
    region:SetRoundLayoutToNearestPixel(true)
end

local function NewEdge(holder)
    local tex = holder:CreateTexture(nil, "ARTWORK", nil, 1)
    tex:SetColorTexture(0, 0, 0, 1)
    RoundToPixel(tex)
    return tex
end

local function Thickness(scale)
    return PixelUtil.GetNearestPixelSize(BetterBlizzFramesDB.raidFramePixelBorderSize or 1, scale, 1)
end

local function LayoutBorder(frame)
    local holder = frame.pixelBorder
    local scale = holder:GetEffectiveScale()
    local px = PixelUtil.GetPixelToUIUnitFactor() / scale
    local size = Thickness(scale)
    local bottomBar = holder.separator and frame.powerBar or frame.healthBar

    holder:ClearAllPoints()
    holder:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", -px, px)
    holder:SetPoint("BOTTOMRIGHT", bottomBar, "BOTTOMRIGHT", px, -px)

    local top, right, bottom, left = holder.top, holder.right, holder.bottom, holder.left
    top:ClearAllPoints()
    top:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    top:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, 0)
    top:SetHeight(size)

    bottom:ClearAllPoints()
    bottom:SetPoint("BOTTOMLEFT", holder, "BOTTOMLEFT", 0, 0)
    bottom:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 0, 0)
    bottom:SetHeight(size)

    left:ClearAllPoints()
    left:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, -size)
    left:SetPoint("BOTTOMLEFT", holder, "BOTTOMLEFT", 0, size)
    left:SetWidth(size)

    right:ClearAllPoints()
    right:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, -size)
    right:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 0, size)
    right:SetWidth(size)

    local separator = holder.separator
    if separator then
        separator:ClearAllPoints()
        separator:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, size / 2)
        separator:SetPoint("BOTTOMRIGHT", frame.powerBar, "TOPRIGHT", 0, -size / 2)
        separator:SetShown(frame.powerBar:IsShown())
    end
end

local function AddBorder(frame, mini)
    if not frame or frame:IsForbidden() or not frame.healthBar then return end
    local holder = frame.pixelBorder
    if not holder then
        holder = CreateFrame("Frame", nil, frame)
        if mini or (frame:GetName() or ""):find("^CompactPartyFrame") then
            holder:SetFrameLevel(3)
        end
        holder.top, holder.right, holder.bottom, holder.left = NewEdge(holder), NewEdge(holder), NewEdge(holder), NewEdge(holder)
        RoundToPixel(holder)
        if not mini and frame.powerBar then
            holder.separator = NewEdge(holder)
        end
        frame.pixelBorder = holder
        bordered[frame] = true
    end
    if mini and frame.horizTopBorder then
        frame.horizTopBorder:Hide()
        frame.horizBottomBorder:Hide()
        frame.vertLeftBorder:Hide()
        frame.vertRightBorder:Hide()
    end
    LayoutBorder(frame)
end

function BBF.UpdateRaidFramePixelBorder()
    for frame in pairs(bordered) do
        LayoutBorder(frame)
    end
end

local function OnEvent(_, event)
    if event == "PLAYER_REGEN_ENABLED" then
        for region in pairs(pendingRound) do
            pendingRound[region] = nil
            RoundToPixel(region)
        end
        return
    end
    BBF.UpdateRaidFramePixelBorder()
end

function BBF.RaidFramePixelBorder()
    if not BetterBlizzFramesDB.raidFramePixelBorder then return end
    if BBF.RaidFramePixelBorderApplied then return end
    BBF.RaidFramePixelBorderApplied = true

    for i = 1, 5 do
        AddBorder(_G["CompactPartyFrameMember" .. i])
    end
    for i = 1, 40 do
        AddBorder(_G["CompactRaidFrame" .. i])
    end
    for group = 1, 8 do
        for i = 1, 5 do
            AddBorder(_G["CompactRaidGroup" .. group .. "Member" .. i])
        end
    end

    hooksecurefunc("DefaultCompactUnitFrameSetup", function(frame)
        AddBorder(frame)
    end)
    hooksecurefunc("DefaultCompactMiniFrameSetup", function(frame)
        AddBorder(frame, true)
    end)

    eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("UI_SCALE_CHANGED")
    eventFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:SetScript("OnEvent", OnEvent)
end
