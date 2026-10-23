local RING_SCALE = 37 / 60
local HD_RING = "Interface\\AddOns\\BetterBlizzFrames\\media\\classicTextures\\MoTextures\\lvlring.png"
local CLASSIC_PARTY_SCALE = 136 / 232
local built = {}
local eventFrame

local function NoPortraitParty()
    local db = BetterBlizzFramesDB
    return not db.classicFrames and BBF.HasNoPortrait("party") and true or false
end

local function PartyUnit(frame, index)
    return frame.unit or ("party" .. index)
end

local function LevelHidden(level)
    local db = BetterBlizzFramesDB
    if not db.hideLevelText then return false end
    if db.hideLevelTextAlways then return true end
    return not issecretvalue(level) and level == GetMaxLevelForPlayerExpansion()
end

local function ColorRing(frame)
    local ring = frame.bbfLevelRing
    local art = frame.Texture
    if not ring or not art then return end
    local r, g, b = art:GetVertexColor()
    if ring.bbfHD then
        ring:SetDesaturated(art:IsDesaturated())
        ring:SetVertexColor(r, g, b)
        return
    end
    if r == g and g == b then
        if r < 1 then
            r = math.min(r + math.min(0.2, r * 0.5), 1)
            g, b = r, r
        end
    else
        r, g, b = math.min(r + 0.15, 1), math.min(g + 0.15, 1), math.min(b + 0.15, 1)
    end
    ring:SetDesaturated(art:IsDesaturated())
    ring:SetVertexColor(r, g, b)
end

local function ClassicHDRing()
    return BetterBlizzFramesDB.classicFrames and BBF.ClassicHDTexturesActive and BBF.ClassicHDTexturesActive() or false
end

local function PlaceHDRing(frame)
    local ring, text = frame.bbfLevelRing, frame.bbfLevelText
    local level = text:GetText()
    local x = 0
    if level and not issecretvalue(level) and tostring(level):sub(1, 1) == "1" then
        x = 0.5 * CLASSIC_PARTY_SCALE
    end
    ring:ClearAllPoints()
    ring:SetPoint("CENTER", text, "CENTER", x, 0)
end

local function PlaceElements(frame)
    local ring, text = frame.bbfLevelRing, frame.bbfLevelText
    text:ClearAllPoints()
    local font = frame.bbfLevelFont
    ring.bbfHD = nil
    if BetterBlizzFramesDB.classicFrames then
        text:SetFont(font[1], font[2], font[3])
        text:SetPoint("CENTER", frame, "TOPLEFT", 14, -37.5)
        if ClassicHDRing() then
            ring.bbfHD = true
            ring:SetTexture(HD_RING)
            ring:SetTexCoord(0, 1, 0, 1)
            ring:SetScale(1)
            ring:SetSize(33.5 * CLASSIC_PARTY_SCALE, 31 * CLASSIC_PARTY_SCALE)
            PlaceHDRing(frame)
            ColorRing(frame)
        else
            ring:Hide()
        end
        return
    end
    local small = BetterBlizzFramesDB.smallerLevelCircle
    text:SetFont(font[1], small and 11 or 12, font[3])
    local source = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.LevelBackgroundCircle
    local atlas = source and source:GetAtlas()
    if atlas then
        ring:SetAtlas(atlas, true)
    elseif source then
        ring:SetTexture(source:GetTexture())
    end
    local scale = small and 0.55 or RING_SCALE
    local spotScale = small and 0.5 or RING_SCALE
    ring:SetScale(scale)
    ring:ClearAllPoints()
    ring:SetPoint("BOTTOMLEFT", frame.Portrait, "BOTTOMLEFT", (-11 * spotScale - 1) / scale, (-14 * spotScale + 1) / scale)
    text:SetPoint("CENTER", ring, "CENTER", 0, -0.5)
    ColorRing(frame)
end

local function UpdateLevel(frame, index)
    if not frame.bbfLevelText then return end
    local unit = PartyUnit(frame, index)
    local showRing = not BetterBlizzFramesDB.classicFrames or ClassicHDRing()
    if not UnitExists(unit) then
        frame.bbfLevelText:Hide()
        frame.bbfLevelRing:Hide()
        return
    end
    local level = UnitEffectiveLevel(unit)
    if LevelHidden(level) then
        frame.bbfLevelText:Hide()
        frame.bbfLevelRing:Hide()
        return
    end
    frame.bbfLevelText:SetText((issecretvalue(level) or level > 0) and level or "??")
    frame.bbfLevelText:SetVertexColor(1, 0.82, 0)
    frame.bbfLevelText:Show()
    if frame.bbfLevelRing.bbfHD then
        PlaceHDRing(frame)
    end
    frame.bbfLevelRing:SetShown(showRing)
end

local function Build(frame, index)
    if built[frame] then return end
    built[frame] = true
    local overlay = frame.PartyMemberOverlay or frame
    local ring = overlay:CreateTexture(nil, "OVERLAY", nil, 1)
    local text = overlay:CreateFontString(nil, "OVERLAY", nil)
    text:SetDrawLayer("OVERLAY", 2)
    local font, size, flags = PlayerLevelText:GetFont()
    frame.bbfLevelFont = { font, math.max(8, math.floor((size or 14) * RING_SCALE + 0.5)), flags }
    text:SetJustifyH("CENTER")
    text:SetShadowOffset(1, -1)
    frame.bbfLevelRing, frame.bbfLevelText = ring, text
    PlaceElements(frame)
    if frame.Texture then
        hooksecurefunc(frame.Texture, "SetVertexColor", function() ColorRing(frame) end)
        hooksecurefunc(frame.Texture, "SetDesaturated", function() ColorRing(frame) end)
    end
    if frame.ToPlayerArt then
        hooksecurefunc(frame, "ToPlayerArt", function()
            PlaceElements(frame)
            UpdateLevel(frame, index)
        end)
    end
end

local function UpdateAll()
    if NoPortraitParty() then return end
    if EditModeManagerFrame and EditModeManagerFrame.UseRaidStylePartyFrames and EditModeManagerFrame:UseRaidStylePartyFrames() then return end
    for i = 1, 4 do
        local frame = PartyFrame and PartyFrame["MemberFrame" .. i]
        if frame and frame:IsShown() and frame.Portrait then
            Build(frame, i)
            UpdateLevel(frame, i)
        end
    end
end

function BBF.UpdatePartyLevelRings()
    if NoPortraitParty() then
        if eventFrame then eventFrame:UnregisterAllEvents() end
        for frame in pairs(built) do
            frame.bbfLevelText:Hide()
            frame.bbfLevelRing:Hide()
        end
        return
    end
    if not eventFrame then
        eventFrame = CreateFrame("Frame")
        eventFrame:SetScript("OnEvent", UpdateAll)
    end
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("UNIT_LEVEL")
    for i = 1, 4 do
        local frame = PartyFrame and PartyFrame["MemberFrame" .. i]
        if frame and not frame.bbfLevelShowHooked then
            frame.bbfLevelShowHooked = true
            frame:HookScript("OnShow", UpdateAll)
        end
    end
    UpdateAll()
end

if BBF.UpdateSmallerLevelCircle then
    hooksecurefunc(BBF, "UpdateSmallerLevelCircle", function()
        for frame in pairs(built) do
            PlaceElements(frame)
        end
    end)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    BBF.UpdatePartyLevelRings()
end)
