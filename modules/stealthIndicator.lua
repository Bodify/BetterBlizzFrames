local stealthBuffs = {
    [1784] = false, -- Stealth
    [115191] = false, -- Stealth (With Subterfuge Talent)
    [11327] = false, -- Vanish 
    [5215] = false, -- Prowl
    [58984] = false, -- Shadowmeld
    [110960] = false, -- Greater Invisibility
    [32612] = false, -- Invisibility
    [199483] = false, -- Camoflague
    [414664] = false, -- Mass Invisibility
}

local stealthIndicator
local stealthEvent

local function createStealthIndicator()
    if not stealthIndicator then
        stealthIndicator = PlayerFrame:CreateTexture(nil, "OVERLAY")
        stealthIndicator:SetAtlas("ui-hud-unitframe-player-portraiton-vehicle-status")
        stealthIndicator:SetSize(201, 83.5)
        stealthIndicator:SetVertexColor(0.212, 0.486, 1)
        stealthIndicator:SetPoint("CENTER", PlayerFrame, "CENTER", -4, 0)
    end
    stealthIndicator:Show()
end

local function hideStealthIndicator()
    if stealthIndicator then
        stealthIndicator:Hide()
    end
end

local function isAnyStealthBuffActive()
    for _, isActive in pairs(stealthBuffs) do
        if isActive then
            return true
        end
    end
    return false
end

local function onBuffAdded(spellId)
    createStealthIndicator()
end

local function onBuffRemoved(spellId)
    if not isAnyStealthBuffActive() then
        hideStealthIndicator()
    end
end

local function checkForStealth(self, event, ...)
    local unit = ...
    if unit ~= "player" then return end

    for spellId, wasActive in pairs(stealthBuffs) do
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellId)
        if aura then
            if not wasActive then
                stealthBuffs[spellId] = true
                onBuffAdded(spellId)
            end
        else
            if wasActive then
                stealthBuffs[spellId] = false
                onBuffRemoved(spellId)
            end
        end
    end
end

function BBF.StealthIndicator()
    if BetterBlizzFramesDB.stealthIndicatorPlayer and not stealthEvent then
        stealthEvent = CreateFrame("Frame")
        stealthEvent:RegisterEvent("UNIT_AURA")
        stealthEvent:SetScript("OnEvent", checkForStealth)
        checkForStealth(self, event, "player")
    end
end
