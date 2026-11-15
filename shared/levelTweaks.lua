local KEYS = {}
for group, name in pairs({ player = "Player", target = "Target", party = "Party" }) do
    local prefix = "levelTweak" .. name
    KEYS[group] = {
        textScale = prefix .. "TextScale",
        ringScale = prefix .. "RingScale",
        hideRing = prefix .. "HideRing",
        x = prefix .. "X",
        y = prefix .. "Y",
        textX = prefix .. "TextX",
        textY = prefix .. "TextY",
    }
end

local ANCHORS = {
    CENTER = { 0, 0 },
    LEFT = { -0.5, 0 },
    RIGHT = { 0.5, 0 },
    TOP = { 0, 0.5 },
    BOTTOM = { 0, -0.5 },
    TOPLEFT = { -0.5, 0.5 },
    TOPRIGHT = { 0.5, 0.5 },
    BOTTOMLEFT = { -0.5, -0.5 },
    BOTTOMRIGHT = { 0.5, -0.5 },
}

function BBF.LevelTweakTextScale(group)
    local db = BetterBlizzFramesDB
    return db.unitFrameIconTweaks and db[KEYS[group].textScale] or 1
end

function BBF.LevelTweakRingScale(group)
    local db = BetterBlizzFramesDB
    return db.unitFrameIconTweaks and db[KEYS[group].ringScale] or 1
end

function BBF.LevelTweakRingHidden(group)
    local db = BetterBlizzFramesDB
    return db.unitFrameIconTweaks and db[KEYS[group].hideRing] or false
end

function BBF.LevelTweakOffset(group)
    local db = BetterBlizzFramesDB
    if not db.unitFrameIconTweaks then return 0, 0 end
    local keys = KEYS[group]
    return db[keys.x], db[keys.y]
end

function BBF.LevelTextShift(group)
    local db = BetterBlizzFramesDB
    if not db.unitFrameIconTweaks then return 0, 0 end
    local keys = KEYS[group]
    return db[keys.textX], db[keys.textY]
end

function BBF.LevelTweakRingActive(group)
    if not BetterBlizzFramesDB.unitFrameIconTweaks then return false end
    local x, y = BBF.LevelTweakOffset(group)
    return BBF.LevelTweakRingScale(group) ~= 1 or BBF.LevelTweakRingHidden(group) or x ~= 0 or y ~= 0
end

function BBF.PlaceLevelRing(ring, point, relativeTo, relativePoint, x, y, scale, group)
    local k = BBF.LevelTweakRingScale(group)
    local dx, dy = BBF.LevelTweakOffset(group)
    local s = scale * k
    local w, h = ring:GetSize()
    local f = ANCHORS[point]
    ring:SetScale(s)
    ring:ClearAllPoints()
    ring:SetPoint(point, relativeTo, relativePoint,
        (x * scale - f[1] * w * scale + dx) / s + f[1] * w,
        (y * scale - f[2] * h * scale + dy) / s + f[2] * h)
end

local function OverrideFont()
    local db = BetterBlizzFramesDB
    if not db.unitFrameIconTweaks then return end
    local file
    if db.levelTweakFont then
        local LSM = LibStub("LibSharedMedia-3.0")
        file = LSM:Fetch(LSM.MediaType.FONT, db.levelTweakFont, true)
    end
    return file, db.levelTweakFontOutline
end

local function ApplyFont(fs)
    local file, size, flags = fs:GetFont()
    if not size then return end
    local base = fs.bbfLevelBaseFont
    local wantFile, wantFlags = OverrideFont()
    wantFile = wantFile or base[1]
    if wantFlags == nil then wantFlags = base[2] end
    if not wantFile then return end
    if wantFile == file and (wantFlags or "") == (flags or "") then return end
    fs.bbfLevelFontBusy = true
    fs:SetFont(wantFile, size, wantFlags or "")
    fs.bbfLevelFontBusy = nil
end

local function StoreBase(fs, point, relativeTo, relativePoint, x, y)
    if type(relativeTo) == "number" then
        relativeTo, relativePoint, x, y = nil, point, relativeTo, relativePoint
    end
    x, y = x or 0, y or 0
    if not point or issecretvalue(x) or issecretvalue(y) then
        fs.bbfLevelBase = nil
        return false
    end
    fs.bbfLevelBase = { point, relativeTo or fs:GetParent(), relativePoint or point, x, y }
    return true
end

local function OwnsPlacement(fs)
    if fs.bbfLevelTweakOwn or fs.bbfClassicLevel then return true end
    local relativeTo = fs.bbfLevelBase[2]
    return relativeTo and relativeTo.bbfLevelTweakRing or false
end

local function MoveText(fs)
    local base = fs.bbfLevelBase
    if not base then return end
    local dx, dy = BBF.LevelTextShift(fs.bbfLevelGroup)
    if not OwnsPlacement(fs) then
        local x, y = BBF.LevelTweakOffset(fs.bbfLevelGroup)
        dx, dy = dx + x, dy + y
    end
    if dx == (fs.bbfLevelDX or 0) and dy == (fs.bbfLevelDY or 0) then return end
    fs.bbfShifting = true
    fs.bbfLevelMoving = true
    fs:SetPoint(base[1], base[2], base[3], base[4] + dx, base[5] + dy)
    fs.bbfShifting = nil
    fs.bbfLevelMoving = nil
    fs.bbfLevelDX, fs.bbfLevelDY = dx, dy
end

local function OnSetFont(fs, file, _, flags)
    if fs.bbfLevelFontBusy then return end
    fs.bbfLevelBaseFont = { file, flags }
    ApplyFont(fs)
end

local function OnSetFontObject(fs)
    if fs.bbfLevelFontBusy then return end
    local file, _, flags = fs:GetFont()
    fs.bbfLevelBaseFont = { file, flags }
    ApplyFont(fs)
end

local function OnSetPoint(fs, point, relativeTo, relativePoint, x, y)
    if fs.bbfLevelMoving then return end
    local oldX, oldY = fs.bbfLevelDX or 0, fs.bbfLevelDY or 0
    if fs.bbfShifting then
        if StoreBase(fs, point, relativeTo, relativePoint, x, y) then
            fs.bbfLevelBase[4], fs.bbfLevelBase[5] = fs.bbfLevelBase[4] - oldX, fs.bbfLevelBase[5] - oldY
        else
            fs.bbfLevelDX, fs.bbfLevelDY = 0, 0
        end
        return
    end
    fs.bbfLevelDX, fs.bbfLevelDY = 0, 0
    if StoreBase(fs, point, relativeTo, relativePoint, x, y) then
        MoveText(fs)
    end
end

function BBF.TweakLevelText(fs, group)
    if not fs.bbfLevelGroup then
        if not BetterBlizzFramesDB.unitFrameIconTweaks then return end
        fs.bbfLevelGroup = group
        local file, _, flags = fs:GetFont()
        fs.bbfLevelBaseFont = { file, flags }
        hooksecurefunc(fs, "SetFont", OnSetFont)
        hooksecurefunc(fs, "SetFontObject", OnSetFontObject)
        hooksecurefunc(fs, "SetPoint", OnSetPoint)
        StoreBase(fs, fs:GetPoint(1))
    end
    ApplyFont(fs)
    local scale = BBF.LevelTweakTextScale(group)
    if fs:GetTextScale() ~= scale then
        fs:SetTextScale(scale)
    end
    MoveText(fs)
end

function BBF.UpdateLevelTweaks()
    BBF.TweakLevelText(PlayerLevelText, "player")
    for _, frame in ipairs({ TargetFrame, FocusFrame }) do
        BBF.TweakLevelText(frame.TargetFrameContent.TargetFrameContentMain.LevelText, "target")
    end
    if BBF.isForever then
        BBF.UpdateSmallerLevelCircle()
    end
    if BetterBlizzFramesDB.classicFrames and not BBF.ClassicStyleAddon() then
        BBF.UpdateClassicPlayerArt()
        for _, frame in ipairs({ TargetFrame, FocusFrame }) do
            if frame.ClassicFrame and UnitExists(frame.unit) then
                frame.ClassicFrame.OnCheckClassification(frame)
            end
        end
        BBF.RefreshClassicPartyMana()
    end
    BBF.RefreshPartyLevelRings()
end
