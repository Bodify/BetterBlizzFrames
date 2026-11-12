local ALPHABETS = { "korean", "roman", "russian", "simplifiedchinese", "traditionalchinese" }

local LOCALE_ALPHABET = {
    koKR = "korean",
    ruRU = "russian",
    zhCN = "simplifiedchinese",
    zhTW = "traditionalchinese",
}
local ownAlphabet = LOCALE_ALPHABET[GetLocale()] or "roman"

local stock = GameFontNormalSmall
local supported = type(CreateFontFamily) == "function" and stock and stock.GetFontObjectForAlphabet ~= nil

local stockFiles = {}
if supported then
    for _, alphabet in ipairs(ALPHABETS) do
        local member = stock:GetFontObjectForAlphabet(alphabet)
        stockFiles[alphabet] = member and member:GetFont()
    end
end

local families = {}
local familyCount = 0

local function FindFamily(file, flags, size, shadow)
    local byFlags = families[file]
    local bySize = byFlags and byFlags[flags]
    local byShadow = bySize and bySize[size]
    return byShadow and byShadow[shadow]
end

local function CreateFamily(file, flags, size, shadow, sx, sy, sr, sg, sb, sa)
    local members = {}
    for i, alphabet in ipairs(ALPHABETS) do
        members[i] = {
            alphabet = alphabet,
            file = alphabet ~= ownAlphabet and stockFiles[alphabet] or file,
            height = size,
            flags = flags,
        }
    end
    familyCount = familyCount + 1
    local family = CreateFontFamily("BBFNameFont" .. familyCount, members)
    for _, alphabet in ipairs(ALPHABETS) do
        local member = family:GetFontObjectForAlphabet(alphabet)
        member:SetShadowOffset(sx, sy)
        member:SetShadowColor(sr, sg, sb, sa)
    end
    local byFlags = families[file]
    if not byFlags then
        byFlags = {}
        families[file] = byFlags
    end
    local bySize = byFlags[flags]
    if not bySize then
        bySize = {}
        byFlags[flags] = bySize
    end
    local byShadow = bySize[size]
    if not byShadow then
        byShadow = {}
        bySize[size] = byShadow
    end
    byShadow[shadow] = family
    return family
end

function BBF.SetNameFont(fontString, file, size, flags)
    if not fontString then return false end
    flags = flags or ""
    if not supported or not file or not size then
        return fontString:SetFont(file, size, flags)
    end
    size = math.floor(size * 100 + 0.5) / 100
    local sr, sg, sb, sa = fontString:GetShadowColor()
    local sx, sy = fontString:GetShadowOffset()
    local shadow = sx .. "," .. sy .. "," .. sr .. "," .. sg .. "," .. sb .. "," .. sa
    local family = FindFamily(file, flags, size, shadow)
    if not family then
        if not fontString:SetFont(file, size, flags) then return false end
        family = CreateFamily(file, flags, size, shadow, sx, sy, sr, sg, sb, sa)
    end
    if fontString:GetFontObject() ~= family then
        local r, g, b, a = fontString:GetTextColor()
        local justifyH, justifyV = fontString:GetJustifyH(), fontString:GetJustifyV()
        fontString:SetFontObject(family)
        fontString:SetTextColor(r, g, b, a)
        fontString:SetShadowColor(sr, sg, sb, sa)
        fontString:SetShadowOffset(sx, sy)
        fontString:SetJustifyH(justifyH)
        fontString:SetJustifyV(justifyV)
    end
    return true
end
