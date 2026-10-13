local hooked
local active, combat, arena
local eventFrame

local function ShouldHide()
    if combat and InCombatLockdown() then return true end
    if arena then
        local _, instanceType = IsInInstance()
        if instanceType == "arena" then return true end
    end
    return false
end

function BBF.HideTooltip()
    local db = BetterBlizzFramesDB
    active = db.hideTooltip and (db.hideTooltipCombat or db.hideTooltipArena) and true or false
    combat = active and db.hideTooltipCombat and true or false
    arena = active and db.hideTooltipArena and true or false

    if active and not hooked then
        hooked = true
        GameTooltip:HookScript("OnShow", function(self)
            if active and ShouldHide() then
                self:Hide()
            end
        end)
    end

    if combat then
        if not eventFrame then
            eventFrame = CreateFrame("Frame")
            eventFrame:SetScript("OnEvent", function()
                GameTooltip:Hide()
            end)
        end
        eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    elseif eventFrame then
        eventFrame:UnregisterAllEvents()
    end
end
