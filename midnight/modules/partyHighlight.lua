BBF.highlightAtlasOptions = {
    { atlas = "RaidFrame-TargetFrame",                             name = "Default" },
    { atlas = "RaidFrame-AgroFrame",                               name = "Aggro" },
    { atlas = "communities-create-avatar-border-selected",         name = "Thick" },
    { atlas = "CosmeticIconFrame",                                 name = "2xCorners" },
    { atlas = "ConduitIconFrame-Corners",                          name = "4xCorners" },
    { atlas = "Azerite-PointingArrow",                             name = "Big Arrow" },
    { atlas = "ShipMission_FollowerListButton-Select",             name = "Thin Glow" },
    { atlas = "characterupdate_green-glow-and-filigree",           name = "Glow Mark" },
    { atlas = "LevelUp-Glow-Gold",                                 name = "Glow" },
    { atlas = "talents-search-notonactionbar",                     name = "Cursor" },
    { atlas = "talents-search-exactmatch",                         name = "Zoom" },
}

local currentAtlas = "RaidFrame-AgroFrame"
local currentColor = {0, 1, 0, 1}

local function ApplyHighlight(frame)
    if not frame or frame:IsForbidden() then return end
    if not frame.selectionHighlight then return end
    if frame.unit:find("nameplate") then return end

    frame.selectionHighlight:SetAtlas(currentAtlas)
    frame.selectionHighlight:SetDesaturated(BetterBlizzFramesDB.betterTargetHighlightDesaturate ~= false)
    frame.selectionHighlight:SetVertexColor(unpack(currentColor))
    if not frame.bbfBetterTargetHighlight then
        frame.selectionHighlight:SetAtlas(currentAtlas)
        if frame.powerBar then
            frame.powerBar:SetFrameLevel(3)
        end
        frame.bbfBetterTargetHighlight = true
    end
end

function BBF.UpdateTargetHighlightSettings()
    local db = BetterBlizzFramesDB
    currentAtlas = db.betterTargetHighlightAtlas or "RaidFrame-AgroFrame"
    currentColor = db.betterTargetHighlightColor or {0, 1, 0, 1}

    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember"..i]
        ApplyHighlight(frame)
    end
end

function BBF.PreviewTargetHighlightAtlas(atlas)
    local saved = currentAtlas
    currentAtlas = atlas
    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember"..i]
        ApplyHighlight(frame)
    end
    currentAtlas = saved
end

function BBF.RevertTargetHighlightPreview()
    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember"..i]
        ApplyHighlight(frame)
    end
end

function BBF.BetterTargetHighlight()
    local db = BetterBlizzFramesDB
    if not db.betterTargetHighlight then return end

    currentAtlas = db.betterTargetHighlightAtlas or "RaidFrame-TargetFrame"
    currentColor = db.betterTargetHighlightColor or {0, 1, 0, 1}

    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember"..i]
        if frame then
            ApplyHighlight(frame)
        end
    end

    if not BBF.BetterTargetHighlightHooked then
        hooksecurefunc("CompactUnitFrame_UpdateSelectionHighlight", function(frame)
            if not db.betterTargetHighlight then return end
            ApplyHighlight(frame)
        end)
        BBF.BetterTargetHighlightHooked = true
    end
end
