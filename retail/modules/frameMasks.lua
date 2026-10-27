local MASK_PATH = "Interface\\AddOns\\BetterBlizzFrames\\media\\retailTextures\\"
local extents = {
    ["Player-BigHealthbar-NoMana"] = { health = 7.5 },
    ["Player-BigHealthbar-Reduced-NoMana"] = { health = 4.5 },
    ["Player-BigHealthbar-Reduced"] = { health = 4.5, mana = 0 },
    ["Player-BigHealthbar"] = { health = 7.5, mana = 0 },
    ["Player-ClassResource-BigHealthbar-NoMana"] = { health = 8 },
    ["Player-ClassResource-BigHealthbar-Reduced-NoMana"] = { health = 4.5 },
    ["Player-ClassResource-BigHealthbar-Reduced"] = { health = 4.5, mana = 0 },
    ["Player-ClassResource-BigHealthbar"] = { health = 8, mana = 0 },
    ["Player-ClassResource-NoMana"] = { health = 1 },
    ["Player-NoMana"] = { health = 1 },
    ["Target-BigHealthbar-NoMana"] = { health = 9 },
    ["Target-BigHealthbar-Reduced-NoMana"] = { health = 7.5 },
    ["Target-BigHealthbar-Reduced"] = { health = 1.5, mana = 0 },
    ["Target-BigHealthbar"] = { health = 4.5, mana = 0 },
    ["Target-NoMana"] = { health = 9 },
    ["ToT-BigHealthbar-NoMana"] = { health = 12 },
    ["ToT-BigHealthbar-Reduced-NoMana"] = { health = 7.5 },
    ["ToT-BigHealthbar-Reduced"] = { health = 1.5, mana = 3.5 },
    ["ToT-BigHealthbar"] = { health = 12, mana = 3.5 },
    ["ToT-NameBelow-NoMana"] = { health = 2 },
    ["ToT-NameBelow"] = { health = 2, mana = 0 },
    ["ToT-NoMana"] = { health = 3.5 },
}

local function MaskArt(art)
    return art and (art:gsub("%-NoShadow", ""))
end

function BBF.FrameMaskGrow(art, slot)
    local e = art and extents[MaskArt(art)]
    return e and e[slot] or 0
end

function BBF.HasFrameMask(art, slot)
    local e = art and extents[MaskArt(art)]
    return e and e[slot] ~= nil or false
end

local sharedMasks = {
    ["ToT-BigHealthbar-Reduced-MM"] = "ToT-BigHealthbar-MM",
}

function BBF.ApplyFrameMask(mask, art, slot, artTexture, flipped)
    if not mask or not BBF.HasFrameMask(art, slot) then return false end
    local file = MaskArt(art) .. (slot == "health" and "-HM" or "-MM") .. (flipped and "F" or "")
    mask:SetTexture(MASK_PATH .. (sharedMasks[file] or file) .. ".png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:ClearAllPoints()
    mask:SetAllPoints(artTexture)
    return true
end

function BBF.FrameArtName(path)
    return path and path:match("retailTextures\\(.+)%.png$")
end
