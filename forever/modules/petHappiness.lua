local hooked
local applied
local pendingFrame
local minimalHooked
local minimalApplied

local minimalColors = {
    [1] = { 1, 0.1, 0.1 },
    [2] = { 1, 0.85, 0 },
    [3] = { 0.1, 1, 0.1 },
}

local function ApplyMinimalTexture(frame)
    local texture = frame.Texture
    if not texture then return end
    local happiness = C_PetInfo and C_PetInfo.GetPetHappiness and C_PetInfo.GetPetHappiness()
    local color = minimalColors[happiness] or minimalColors[3]
    texture:SetAtlas("WildBattlePetCapturable")
    texture:SetDesaturated(true)
    texture:ClearAllPoints()
    texture:SetPoint("CENTER", frame, "CENTER")
    texture:SetSize(18, 18)
    texture:SetVertexColor(color[1], color[2], color[3])
end

local function UpdateMinimal(frame)
    local db = BetterBlizzFramesDB
    local minimal = db.tweakPetHappiness and db.minimalPetHappiness
    if minimal then
        minimalApplied = true
        if not minimalHooked and frame.UpdateHappiness then
            minimalHooked = true
            hooksecurefunc(frame, "UpdateHappiness", function(self)
                if minimalApplied then
                    ApplyMinimalTexture(self)
                end
            end)
        end
        ApplyMinimalTexture(frame)
    elseif minimalApplied then
        minimalApplied = nil
        local texture = frame.Texture
        if texture then
            texture:ClearAllPoints()
            texture:SetAllPoints(frame)
            texture:SetVertexColor(1, 1, 1)
            texture:SetDesaturated(false)
        end
        if frame.UpdateHappiness then
            frame:UpdateHappiness()
        end
    end
end

local function MaxFrameLevel(frame, level)
    if not frame then return level end
    level = math.max(level, frame:GetFrameLevel())
    for _, child in ipairs({ frame:GetChildren() }) do
        level = MaxFrameLevel(child, level)
    end
    return level
end

local function ApplyFrameLevel(frame, active)
    if active then
        if not frame.bbfBaseLevel then
            frame.bbfBaseLevel = frame:GetFrameLevel()
        end
        local level = MaxFrameLevel(PetFrameHealthBar, 0)
        level = MaxFrameLevel(PetFrameManaBar, level)
        frame:SetFrameLevel(math.max(frame.bbfBaseLevel, level + 1))
    elseif frame.bbfBaseLevel then
        frame:SetFrameLevel(frame.bbfBaseLevel)
        frame.bbfBaseLevel = nil
    end
end

local function BasePoint()
    local db = BetterBlizzFramesDB
    if BBF.HasNoPortrait and BBF.HasNoPortrait("pet") then
        if db.noPortraitPixelBorder then
            return "RIGHT", "LEFT", 35, 5
        end
        return "RIGHT", "LEFT", 34, 2
    end
    return "LEFT", "RIGHT", 0, -4
end

local function ApplyPetHappiness()
    local frame = PetFrameHappiness
    if not frame then return end
    if InCombatLockdown() then
        if not pendingFrame then
            pendingFrame = CreateFrame("Frame")
            pendingFrame:SetScript("OnEvent", function(self)
                self:UnregisterEvent("PLAYER_REGEN_ENABLED")
                ApplyPetHappiness()
            end)
        end
        pendingFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    local db = BetterBlizzFramesDB
    local active = db.tweakPetHappiness
    local hide = active and db.hidePetHappiness
    local scale = active and (db.petHappinessScale or 1) or 1
    local retail = BBF.RetailTexturesOn and BBF.RetailTexturesOn("pet")
    local x = (db.classicFrames and -8 or retail and -1 or 0) + (active and (db.petHappinessXPos or 0) or 0)
    local y = (db.classicFrames and 2 or retail and -1.5 or 0) + (active and (db.petHappinessYPos or 0) or 0)

    frame:SetAlpha(hide and 0 or 1)
    frame:EnableMouse(not hide)
    frame:SetScale(scale)
    ApplyFrameLevel(frame, active)

    if retail then
        if not frame.bbfBaseSize then
            frame.bbfBaseSize = { frame:GetSize() }
        end
        frame:SetSize(22, 21)
    elseif frame.bbfBaseSize then
        frame:SetSize(frame.bbfBaseSize[1], frame.bbfBaseSize[2])
        frame.bbfBaseSize = nil
    end

    local point, relPoint, baseX, baseY = BasePoint()
    frame.bbfNudging = true
    frame:ClearAllPoints()
    frame:SetPoint(point, PetFrame, relPoint, (baseX + x) / scale, (baseY + y) / scale)
    frame.bbfNudging = nil
end

function BBF.UpdatePetHappiness()
    local frame = PetFrameHappiness
    if not frame then return end
    local db = BetterBlizzFramesDB
    local active = (db.tweakPetHappiness or db.classicFrames or (BBF.RetailTexturesOn and BBF.RetailTexturesOn("pet"))) and true or false
    if not active and not applied then return end
    applied = active

    if not hooked then
        hooked = true
        hooksecurefunc(frame, "SetPoint", function(self)
            if self.bbfNudging then return end
            if applied then
                ApplyPetHappiness()
            end
        end)
    end

    UpdateMinimal(frame)
    ApplyPetHappiness()
end
