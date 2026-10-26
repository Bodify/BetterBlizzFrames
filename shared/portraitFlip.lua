local enabled, hooked, flipping

local function GetPortraits()
    local portraits = {}
    for _, name in ipairs({ "TargetFrame", "FocusFrame" }) do
        local frame = _G[name]
        if frame then
            local tot = frame.totFrame or _G[name .. "ToT"]
            for _, f in ipairs({ frame, tot }) do
                local portrait = f and (f.portrait or f.Portrait)
                if portrait then
                    portraits[#portraits + 1] = portrait
                end
            end
        end
    end
    return portraits
end

local function Apply(tex)
    local ulx, uly, llx, lly, urx, ury, lrx, lry = tex:GetTexCoord()
    if (ulx > urx) == (enabled and true or false) then return end
    flipping = true
    tex:SetTexCoord(urx, ury, lrx, lry, ulx, uly, llx, lly)
    flipping = false
end

local function OnChange(tex)
    if enabled and not flipping then
        Apply(tex)
    end
end

function BBF.FlipPortraits()
    enabled = BetterBlizzFramesDB.flipPortraits
    if not enabled and not hooked then return end
    for _, portrait in ipairs(GetPortraits()) do
        if not hooked then
            hooksecurefunc(portrait, "SetTexCoord", OnChange)
            hooksecurefunc(portrait, "SetTexture", OnChange)
            hooksecurefunc(portrait, "SetAtlas", OnChange)
        end
        Apply(portrait)
    end
    hooked = true
end
