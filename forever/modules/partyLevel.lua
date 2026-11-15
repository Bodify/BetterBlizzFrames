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

function BBF.PartyLevelHidden(frame)
    local unit = frame.unit
    if not unit or not UnitExists(unit) then return false end
    return LevelHidden(UnitEffectiveLevel(unit))
end

local function ColorRing(frame)
    local ring = frame.bbfLevelRing
    local art = frame.Texture
    if not ring or not art then return end
    local r, g, b = art:GetVertexColor()
    if ring.bbfHD or issecretvalue(r) then
        ring:SetDesaturated(art:IsDesaturated())
        ring:SetVertexColor(r, g, b)
        return
    end
    if r == g and g == b then
        if r < 1 then
            r = math.min(r + math.min(0.2, r * 0.5), 1)
            g, b = r, r
        end
    elseif art:IsDesaturated() or not BetterBlizzFramesDB.darkerBronzeUnitFrames then
        r, g, b = math.min(r + 0.15, 1), math.min(g + 0.15, 1), math.min(b + 0.15, 1)
    end
    ring:SetDesaturated(art:IsDesaturated())
    ring:SetVertexColor(r, g, b)
end

local function ClassicHDRing()
    return BetterBlizzFramesDB.classicFrames and BBF.ClassicHDTexturesActive and BBF.ClassicHDTexturesActive() or false
end

local function PlaceElements(frame)
    local ring, text = frame.bbfLevelRing, frame.bbfLevelText
    text:ClearAllPoints()
    local font = frame.bbfLevelFont
    ring.bbfHD = nil
    if BetterBlizzFramesDB.classicFrames then
        text:SetFont(font[1], font[2], font[3])
        local bigParty = BBF.BigHealthbarsOn() and BetterBlizzFramesDB.bigHealthbarParty
        local dx, dy = BBF.LevelTweakOffset("party")
        local size = CLASSIC_PARTY_SCALE * BBF.LevelTweakRingScale("party")
        text:SetPoint("CENTER", frame, "TOPLEFT", (bigParty and 12.5 or 13) + dx, -37.5 + dy)
        if ClassicHDRing() then
            ring.bbfHD = true
            ring:SetTexture(HD_RING)
            ring:SetTexCoord(0, 1, 0, 1)
            ring:SetScale(1)
            ring:SetSize(33.5 * size, 31 * size)
            ring:ClearAllPoints()
            ring:SetPoint("CENTER", frame, "TOPLEFT", 14 + dx, -37.5 + dy)
            text:ClearAllPoints()
            text:SetPoint("CENTER", ring, "CENTER", 0, 0)
            ColorRing(frame)
        elseif BBF.LevelTweakRingActive("party") then
            ring.bbfHD = true
            ring:SetAtlas("hud-PlayerFrame-levelring")
            ring:SetScale(1)
            ring:SetSize(32 * size, 32 * size)
            ring:ClearAllPoints()
            local sx, sy = BBF.LevelTextShift("party")
            ring:SetPoint("CENTER", text, "CENTER", -0.5 - sx, -1 - sy)
            ColorRing(frame)
        else
            ring:Hide()
        end
        BBF.TweakLevelText(text, "party")
        return
    end
    local small = BetterBlizzFramesDB.smallerLevelCircle
    text:SetFont(font[1], 9, font[3])
    local source = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.LevelBackgroundCircle
    local atlas = source and source:GetAtlas()
    if atlas then
        ring:SetAtlas(atlas, true)
    elseif source then
        ring:SetTexture(source:GetTexture())
    end
    local scale = small and 0.55 or RING_SCALE
    local spotScale = small and 0.5 or RING_SCALE
    BBF.PlaceLevelRing(ring, "BOTTOMLEFT", frame.Portrait, "BOTTOMLEFT", (-11 * spotScale - 1) / scale, (-14 * spotScale + 1) / scale, scale, "party")
    text:SetPoint("CENTER", ring, "CENTER", 0, 0)
    ColorRing(frame)
    BBF.TweakLevelText(text, "party")
end

local function UpdateLevel(frame, index)
    if not frame.bbfLevelText then return end
    if frame.bbfPlaceRoleIcon then frame.bbfPlaceRoleIcon() end
    local unit = PartyUnit(frame, index)
    local showRing = (not BetterBlizzFramesDB.classicFrames or ClassicHDRing() or BBF.LevelTweakRingActive("party")) and not BBF.LevelTweakRingHidden("party")
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
    local db = BetterBlizzFramesDB
    if db.changePartyFrameFont and db.partyFrameFontColor and db.partyFrameFontColorLvl then
        local color = db.partyFrameFontColorRGB
        frame.bbfLevelText:SetVertexColor(color[1], color[2], color[3])
    else
        frame.bbfLevelText:SetVertexColor(1, 0.82, 0)
    end
    frame.bbfLevelText:Show()
    frame.bbfLevelRing:SetShown(showRing)
end

local function LevelParent(frame)
    local overlay = frame.PartyMemberOverlay or frame
    if not BetterBlizzFramesDB.classicFrames then return overlay end
    local holder = CreateFrame("Frame", nil, frame)
    holder:SetAllPoints(frame)
    holder:SetFrameLevel((frame.HealthBarContainer or overlay):GetFrameLevel() + 5)
    return holder
end

local function Build(frame, index)
    if built[frame] then return end
    built[frame] = index
    local parent = LevelParent(frame)
    local ring = parent:CreateTexture(nil, "OVERLAY", nil, 1)
    local text = parent:CreateFontString(nil, "OVERLAY", nil)
    text:SetDrawLayer("OVERLAY", 2)
    local font, size, flags = PlayerLevelText:GetFont()
    frame.bbfLevelFont = { font, math.max(8, math.floor((size or 14) * RING_SCALE + 0.5)), flags }
    text:SetWidth(25)
    text:SetJustifyH("CENTER")
    text:SetShadowOffset(1, -1)
    text.bbfLevelTweakOwn = true
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

function BBF.RefreshPartyLevelRings()
    if NoPortraitParty() then return end
    for frame, index in pairs(built) do
        PlaceElements(frame)
        UpdateLevel(frame, index)
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
