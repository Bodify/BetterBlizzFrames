local minimapTweaksHooked
local minimapTweaksApplied

local function MinimapTweaksActive()
    local db = BetterBlizzFramesDB
    return db.foreverMinimapTweaks and not db.classicFrames and not db.classicMinimap
end

local function ApplyMinimapNudge(container)
    local base = container.bbfBasePoint
    if not base or type(base[5]) ~= "number" then return end
    local x, y = base[4], base[5]
    if MinimapTweaksActive() then
        local db = BetterBlizzFramesDB
        local scale = container:GetScale()
        x = x + (db.foreverMinimapXPos or 0) / scale
        y = y + (db.foreverMinimapYPos or 12) / scale
    end
    container.bbfNudging = true
    container:SetPoint(base[1], base[2], base[3], x, y)
    container.bbfNudging = false
end

local function ApplyMinimapCompass()
    if not BBF.isForever or not MinimapCompassTexture or GetCVarBool("rotateMinimap") then return end
    local atlas = MinimapTweaksActive() and "UI-HUD-Minimap-Frame-Circle" or "UI-HUD-Minimap-Frame"
    if MinimapCompassTexture:GetAtlas() == atlas then return end
    MinimapCompassTexture.bbfChanging = true
    MinimapCompassTexture:SetAtlas(atlas)
    MinimapCompassTexture.bbfChanging = false
end

local function HookMinimapTweaks()
    if minimapTweaksHooked then return end
    minimapTweaksHooked = true

    local container = MinimapCluster and MinimapCluster.MinimapContainer
    if container then
        container.bbfBasePoint = { container:GetPoint(1) }
        hooksecurefunc(container, "SetPoint", function(self, ...)
            if self.bbfNudging then return end
            self.bbfBasePoint = { ... }
            ApplyMinimapNudge(self)
        end)
    end

    if BBF.isForever and MinimapCompassTexture then
        hooksecurefunc(MinimapCompassTexture, "SetAtlas", function(self)
            if self.bbfChanging then return end
            ApplyMinimapCompass()
        end)
    end

    local dielFrame = MinimapCluster and MinimapCluster.DielFrame
    if dielFrame then
        dielFrame:HookScript("OnShow", function(self)
            if MinimapTweaksActive() then
                self:Hide()
            end
        end)
    end
end

function BBF.UpdateMinimapTweaks()
    local db = BetterBlizzFramesDB
    if db.classicFrames or db.classicMinimap then return end
    local active = MinimapTweaksActive()
    if not active and not minimapTweaksApplied then return end
    minimapTweaksApplied = active

    HookMinimapTweaks()

    local container = MinimapCluster and MinimapCluster.MinimapContainer
    if container then
        ApplyMinimapNudge(container)
    end
    ApplyMinimapCompass()

    if Minimap then
        Minimap:SetScale(active and (db.foreverMinimapScale or 1) or 1)
    end

    local dielFrame = MinimapCluster and MinimapCluster.DielFrame
    if dielFrame then
        dielFrame:SetShown(not active)
    end
end
