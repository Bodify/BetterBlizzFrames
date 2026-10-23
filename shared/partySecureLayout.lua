local POINTS = { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT" }
local KEYS = { "c", "h", "m" }

local SNIPPET = [[
    if name ~= "unit" or not value or strfind(value, "pet") then return end
    for key in gmatch("chm", ".") do
        local spec = self:GetAttribute("bbf-" .. key)
        local region = spec and self:GetFrameRef("bbf" .. key)
        if region then
            local cleared, w, h = strsplit(",", strmatch(spec, "^[^|]*"))
            if cleared == "1" then
                region:ClearAllPoints()
            end
            for p in gmatch(spec, "|([^|]+)") do
                local point, rel, relPoint, x, y = strsplit(",", p)
                local relFrame = rel == "f" and self or self:GetFrameRef("bbf" .. rel)
                if relFrame then
                    region:SetPoint(point, relFrame, relPoint, tonumber(x), tonumber(y))
                end
            end
            if w ~= "" then region:SetWidth(tonumber(w)) end
            if h ~= "" then region:SetHeight(tonumber(h)) end
        end
    end
]]

local recorders = {}
local pendingRefresh = false
local checkQueued = {}

local function RegionKey(frame, region)
    local container = frame.HealthBarContainer
    if region == container then return "c" end
    if container and region == container.HealthBar then return "h" end
    if region == frame.ManaBar then return "m" end
end

local function RelKey(frame, rel)
    if rel == frame then return "f" end
    return RegionKey(frame, rel)
end

local function Encode(record)
    if not record.cleared and not record.w and not record.h and not next(record.points) then return nil end
    local parts = { (record.cleared and "1" or "0") .. "," .. (record.w and tostring(record.w) or "") .. "," .. (record.h and tostring(record.h) or "") }
    for _, point in ipairs(POINTS) do
        local p = record.points[point]
        if p then
            parts[#parts + 1] = point .. "," .. p[1] .. "," .. p[2] .. "," .. tostring(p[3]) .. "," .. tostring(p[4])
        end
    end
    return table.concat(parts, "|")
end

local function NewRecord()
    return { points = {} }
end

local function ResetRecords(rec)
    for _, key in ipairs(KEYS) do
        rec.records[key] = NewRecord()
    end
end

function BBF.RefreshPartyLayouts()
    pendingRefresh = false
    if not PartyFrame then return end
    for i = 1, 4 do
        local frame = PartyFrame["MemberFrame" .. i]
        if frame and frame.bbfPartyArtFns then
            for _, fn in ipairs(frame.bbfPartyArtFns) do
                fn(frame)
            end
        end
    end
end

local function QueueRefresh()
    if pendingRefresh then return end
    pendingRefresh = true
    BBF.RunAfterCombat(BBF.RefreshPartyLayouts)
end

local function Install(rec)
    if rec.installed then return true end
    if InCombatLockdown() then return false end
    local frame = rec.frame
    SecureHandlerSetFrameRef(frame, "bbfc", frame.HealthBarContainer)
    SecureHandlerSetFrameRef(frame, "bbfh", frame.HealthBarContainer.HealthBar)
    SecureHandlerSetFrameRef(frame, "bbfm", frame.ManaBar)
    SecureHandlerWrapScript(frame, "OnAttributeChanged", frame, SNIPPET)
    rec.installed = true
    return true
end

local function CheckRecords(frame)
    checkQueued[frame] = nil
    local rec = recorders[frame]
    if not rec then return end
    if not rec.installed then
        QueueRefresh()
        return
    end
    for _, key in ipairs(KEYS) do
        if Encode(rec.records[key]) ~= frame:GetAttribute("bbf-" .. key) then
            QueueRefresh()
            return
        end
    end
end

local function Commit(rec)
    local frame = rec.frame
    if InCombatLockdown() then
        if not checkQueued[frame] then
            checkQueued[frame] = true
            C_Timer.After(0, function() CheckRecords(frame) end)
        end
        return false
    end
    if not Install(rec) then return false end
    for _, key in ipairs(KEYS) do
        local spec = Encode(rec.records[key])
        if frame:GetAttribute("bbf-" .. key) ~= spec then
            frame:SetAttribute("bbf-" .. key, spec)
        end
    end
    return true
end

local Recorder = {}
Recorder.__index = Recorder

function Recorder:Record(region)
    local key = RegionKey(self.frame, region)
    if not key then
        error("BBF.PartyBars: not a party bar region")
    end
    return self.records[key]
end

function Recorder:ClearAllPoints(region)
    local record = self:Record(region)
    record.cleared = true
    wipe(record.points)
    if not InCombatLockdown() then
        region:ClearAllPoints()
    end
    Commit(self)
end

function Recorder:SetPoint(region, point, rel, relPoint, x, y)
    local record = self:Record(region)
    local relKey = RelKey(self.frame, rel)
    if not relKey then
        error("BBF.PartyBars: relative frame must be the party frame or one of its bars")
    end
    relPoint = relPoint or point
    x, y = x or 0, y or 0
    record.points[point] = { relKey, relPoint, x, y }
    if not InCombatLockdown() then
        region:SetPoint(point, rel, relPoint, x, y)
    end
    Commit(self)
end

function Recorder:SetAllPoints(region, rel)
    self:ClearAllPoints(region)
    self:SetPoint(region, "TOPLEFT", rel, "TOPLEFT", 0, 0)
    self:SetPoint(region, "BOTTOMRIGHT", rel, "BOTTOMRIGHT", 0, 0)
end

function Recorder:SetWidth(region, w)
    self:Record(region).w = w
    if not InCombatLockdown() then
        region:SetWidth(w)
    end
    Commit(self)
end

function Recorder:SetHeight(region, h)
    self:Record(region).h = h
    if not InCombatLockdown() then
        region:SetHeight(h)
    end
    Commit(self)
end

function Recorder:SetSize(region, w, h)
    local record = self:Record(region)
    record.w, record.h = w, h
    if not InCombatLockdown() then
        region:SetSize(w, h)
    end
    Commit(self)
end

function BBF.PartyBars(frame)
    local rec = recorders[frame]
    if not rec then
        rec = setmetatable({ frame = frame, records = {} }, Recorder)
        ResetRecords(rec)
        recorders[frame] = rec
    end
    return rec
end

local DEFAULT_BARS = {
    player = {
        c = { h = 10, points = { TOPLEFT = { "f", "TOPLEFT", 45, -19 } } },
        h = { h = 10, points = { TOPLEFT = { "c", "TOPLEFT", 0, 0 } } },
        m = { h = 7, points = { TOPLEFT = { "f", "TOPLEFT", 41, -30 } } },
    },
    vehicle = {
        c = { h = 10, points = { TOPLEFT = { "f", "TOPLEFT", 48, -18 } } },
        h = { h = 10, points = { TOPLEFT = { "c", "TOPLEFT", 0, 0 } } },
        m = { h = 7, points = { TOPLEFT = { "f", "TOPLEFT", 45, -29 } } },
    },
}

local function BarSpec(frame, key)
    local default = DEFAULT_BARS[frame.state == "vehicle" and "vehicle" or "player"][key]
    local rec = recorders[frame]
    local record = rec and rec.records[key]
    if not record then return default.points, default.h end
    local points = {}
    if not record.cleared then
        for point, p in pairs(default.points) do points[point] = p end
    end
    for point, p in pairs(record.points) do points[point] = p end
    return points, record.h or default.h
end

local function Edge(top, bottom, relPoint)
    if relPoint:find("TOP") then return top end
    if relPoint:find("BOTTOM") then return bottom end
    return top and bottom and (top + bottom) / 2
end

local function BarEdges(frame, key, depth)
    if key == "f" then return 0 end
    if depth > 3 then return end
    local points, h = BarSpec(frame, key)
    local top, bottom, middle
    for point, p in pairs(points) do
        local relTop, relBottom = BarEdges(frame, p[1], depth + 1)
        local y = Edge(relTop, relBottom, p[2])
        if y then
            y = y + p[4]
            if point:find("TOP") then
                top = y
            elseif point:find("BOTTOM") then
                bottom = y
            else
                middle = y
            end
        end
    end
    if h then
        if middle and not top and not bottom then top = middle + h / 2 end
        if top and not bottom then bottom = top - h end
        if bottom and not top then top = bottom + h end
    end
    return top, bottom
end

function BBF.PartyBarGeometry(frame)
    local healthTop, healthBottom = BarEdges(frame, "h", 0)
    local manaTop = BarEdges(frame, "m", 0)
    if not healthTop or not healthBottom or not manaTop then return end
    return healthTop - healthBottom, healthBottom - manaTop
end

function BBF.HookPartyArt(frame, fn)
    if not frame.bbfPartyArtFns then
        frame.bbfPartyArtFns = {}
    end
    table.insert(frame.bbfPartyArtFns, fn)
    hooksecurefunc(frame, "ToPlayerArt", fn)
end

if UnitFrame_SetUnit then hooksecurefunc("UnitFrame_SetUnit", function(frame, unit)
    local rec = recorders[frame]
    if rec and unit and not unit:find("pet") then
        ResetRecords(rec)
    end
end) end
