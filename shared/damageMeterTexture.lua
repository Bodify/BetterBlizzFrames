local LSM = LibStub("LibSharedMedia-3.0")

local DEFAULT_ATLAS = "UI-HUD-CoolDownManager-Bar"
local damageMeterTexture
local hooked, waiting

local function HideBorder()
    return BetterBlizzFramesDB.changeDamageMeterTexture and BetterBlizzFramesDB.damageMeterHideBorder
end

local function KeepEdgeHidden(edge)
    if edge.bbfChanging or not HideBorder() then return end
    edge.bbfChanging = true
    edge:SetAlpha(0)
    edge.bbfChanging = nil
end

local function ApplyBorder(statusBar)
    local edge = statusBar.BackgroundEdge
    if not edge then return end
    local hide = HideBorder() and true or false
    if edge.bbfHidden == hide then return end
    if not edge.bbfHooked then
        edge.bbfHooked = true
        hooksecurefunc(edge, "SetAlpha", KeepEdgeHidden)
    end
    edge.bbfHidden = hide
    edge.bbfChanging = true
    edge:SetAlpha(hide and 0 or 1)
    edge.bbfChanging = nil
end

local function ApplyTexture(entry)
    local statusBar = entry.StatusBar
    if not statusBar then return end
    ApplyBorder(statusBar)
    local want = BetterBlizzFramesDB.changeDamageMeterTexture and damageMeterTexture or nil
    if statusBar.bbfTexture == want then return end
    local fill = statusBar:GetStatusBarTexture()
    local r, g, b, a = fill:GetVertexColor()
    if want then
        statusBar:SetStatusBarTexture(want)
    else
        statusBar:SetStatusBarTexture(DEFAULT_ATLAS)
    end
    statusBar:GetStatusBarTexture():SetVertexColor(r, g, b, a)
    statusBar.bbfTexture = want
end

local function ForEachEntry(func)
    if not DamageMeter or not DamageMeter.ForEachSessionWindow then return end
    DamageMeter:ForEachSessionWindow(function(window)
        window:ForEachEntryFrame(func)
        local localPlayer = window:GetLocalPlayerEntry()
        if localPlayer then func(localPlayer) end
        local sourceWindow = window:GetSourceWindow()
        if sourceWindow then sourceWindow:ForEachEntryFrame(func) end
    end)
end

local function Setup()
    if not hooked then
        hooked = true
        hooksecurefunc(DamageMeterEntryMixin, "Init", ApplyTexture)
    end
    ForEachEntry(ApplyTexture)
end

function BBF.DamageMeterTexture()
    if not BetterBlizzFramesDB.changeDamageMeterTexture and not hooked and not waiting then return end
    damageMeterTexture = LSM:Fetch(LSM.MediaType.STATUSBAR, BetterBlizzFramesDB.damageMeterTexture)
    if DamageMeterEntryMixin then
        Setup()
    elseif not waiting and EventUtil and EventUtil.ContinueOnAddOnLoaded then
        waiting = true
        EventUtil.ContinueOnAddOnLoaded("Blizzard_DamageMeter", Setup)
    end
end
