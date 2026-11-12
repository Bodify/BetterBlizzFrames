local durationFontOn

function BBF.BuffDurationFontOverride(font, size, flags)
    local db = BetterBlizzFramesDB
    if not db.changeBuffDurationFont then return font, size, flags end
    if db.buffDurationFont then
        local LSM = LibStub("LibSharedMedia-3.0")
        font = LSM:Fetch(LSM.MediaType.FONT, db.buffDurationFont) or font
    end
    size = tonumber(db.buffDurationFontSize) or size
    if db.buffDurationFontOutline ~= nil then
        flags = db.buffDurationFontOutline
    end
    return font, size, flags
end

local function ApplyBlizzardDurationFont(text)
    if not text or text:GetObjectType() ~= "FontString" then return end
    local orig = text.bbfOrigDurationFont
    if not orig then
        if not durationFontOn then return end
        local font, size, flags = text:GetFont()
        if not font then return end
        orig = { font, size, flags }
        text.bbfOrigDurationFont = orig
    end
    text:SetFont(BBF.BuffDurationFontOverride(orig[1], orig[2], orig[3]))
end

function BBF.BuffDurationFont()
    local enabled = BetterBlizzFramesDB.changeBuffDurationFont and true or false
    if not enabled and not durationFontOn then return end
    durationFontOn = enabled
    for _, auraFrame in ipairs({ BuffFrame, DebuffFrame }) do
        if auraFrame and auraFrame.auraFrames then
            for _, button in ipairs(auraFrame.auraFrames) do
                ApplyBlizzardDurationFont(button.Duration)
            end
        end
    end
    if BBF.RefreshAllAuraFrames then
        BBF.RefreshAllAuraFrames()
    end
end
