local DISPEL_TYPES = {
    { name = "Magic", key = "playerDispelGlowMagic" },
    { name = "Curse", key = "playerDispelGlowCurse" },
    { name = "Disease", key = "playerDispelGlowDisease" },
    { name = "Poison", key = "playerDispelGlowPoison" },
    { name = "Bleed", key = "playerDispelGlowBleed" },
}
local MINE_FILTER = "HARMFUL|RAID"
local ANY_FILTER = "HARMFUL|DISPELLABLE"

local auraContainer
local glows = {}
local enabled

local function CopyArt(tex)
    local flash = PlayerFrame.PlayerFrameContainer.FrameFlash
    local atlas = flash:GetAtlas()
    if atlas then
        tex:SetAtlas(atlas)
    else
        tex:SetTexture(flash:GetTexture())
    end
    tex:SetTexCoord(flash:GetTexCoord())
    tex:SetBlendMode(flash:GetBlendMode())
    local layer, sub = flash:GetDrawLayer()
    tex:SetDrawLayer(layer, math.min(sub + 1, 7))
end

local function SyncArt()
    if not enabled then return end
    for _, tex in ipairs(glows) do
        CopyArt(tex)
    end
end

local function InitGlow(auraFrame, info)
    local container = PlayerFrame.PlayerFrameContainer
    auraFrame:SetSize(1, 1)
    auraFrame:SetPoint("CENTER", auraContainer, "CENTER")
    auraFrame:SetCancelAuraButtons(nil)
    auraFrame:SetHideTooltipInCombat(true)
    if not InCombatLockdown() then
        auraFrame:SetMouseMotionEnabled(false)
    end

    local host = CreateFrame("Frame", nil, auraFrame)
    host:SetFrameLevel(container:GetFrameLevel())
    host:SetAllPoints(container)

    local tex = host:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints(container.FrameFlash)
    tex:SetTexelSnappingBias(0)
    tex:SetSnapToPixelGrid(false)
    tex:SetVertexColor(AuraUtil.GetAuraBorderColor(info.name):GetRGBA())
    CopyArt(tex)
    glows[#glows + 1] = tex
end

local function CreateGlowContainer()
    local container = PlayerFrame.PlayerFrameContainer
    auraContainer = CreateFrame("AuraContainer", nil, container, "CustomAuraContainerTemplate")
    auraContainer:SetSize(1, 1)
    auraContainer:SetPoint("CENTER", container, "CENTER")
    auraContainer:SetEnabled(false)
    if auraContainer.SetEditModePreviewEnabled then
        auraContainer:SetEditModePreviewEnabled(false)
    end
    for _, info in ipairs(DISPEL_TYPES) do
        auraContainer:AddAuraSlot(info.name, MINE_FILTER, {
            candidateFilters = { includeDispelTypes = { [info.name] = true } },
            initializeFrame = function(auraFrame)
                InitGlow(auraFrame, info)
            end,
        })
    end
    for _, method in ipairs({ "SetAtlas", "SetTexture", "SetTexCoord", "SetBlendMode", "SetDrawLayer" }) do
        hooksecurefunc(container.FrameFlash, method, SyncArt)
    end
end

function BBF.PlayerDispelGlowCaller()
    local db = BetterBlizzFramesDB
    if not db.playerDispelGlow then
        if auraContainer then
            enabled = nil
            auraContainer:SetEnabled(false)
            auraContainer:Hide()
        end
        return
    end
    if not auraContainer then
        CreateGlowContainer()
    end
    for _, info in ipairs(DISPEL_TYPES) do
        local picked = db[info.key]
        auraContainer:SetAuraSlotEnabled(info.name, picked or db.playerDispelGlowMine or false)
        auraContainer:SetAuraSlotFilterString(info.name, picked and ANY_FILTER or MINE_FILTER)
    end
    enabled = true
    auraContainer:SetUnit("player")
    auraContainer:SetEnabled(true)
    auraContainer:Show()
    SyncArt()
end
