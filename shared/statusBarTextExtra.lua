local entries
local totHooked, partyHooked
local cvarFrame

local function IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

local function FormatNumber(bar, value)
    if BetterBlizzFramesDB.formatStatusBarText then
        return (AbbreviateNumbers or AbbreviateLargeNumbers)(value)
    elseif bar.capNumericDisplay then
        return AbbreviateLargeNumbers(value)
    end
    return BreakUpLargeNumbers(value)
end

local function NumericText(bar, value, maxValue)
    local db = BetterBlizzFramesDB
    local valueText = FormatNumber(bar, value)
    if bar.disableMaxValue or (db.formatStatusBarText and db.singleValueStatusBarText) then
        return valueText
    end
    return string.format("%s / %s", valueText, FormatNumber(bar, maxValue))
end

local function PercentText(entry, value, maxValue)
    if not IsSecret(value) and not IsSecret(maxValue) then
        return math.ceil((value / maxValue) * 100) .. "%"
    end
    local bar = entry.bar
    local percent
    if entry.isMana then
        percent = UnitPowerPercent(bar.unit, bar.powerType, false, CurveConstants.ScaleTo100)
    else
        percent = UnitHealthPercent(bar.unit, false, CurveConstants.ScaleTo100)
    end
    return string.format("%.0f%%", percent)
end

local function ClearTexts(entry)
    entry.center:SetText("")
    entry.center:Hide()
    if entry.left then
        entry.left:SetText("")
        entry.left:Hide()
    end
    if entry.right then
        entry.right:SetText("")
        entry.right:Hide()
    end
end

local function ShowText(entry, fontString, text, alpha)
    fontString:SetText(text)
    if entry.owned or fontString == entry.center then
        fontString:SetAlpha(alpha)
    end
    fontString:Show()
end

local function IsEntryEnabled(entry)
    local db = BetterBlizzFramesDB
    if not db.statusTextExtra or not db[entry.groupKey] then return false end
    if entry.isMana then
        return db.statusTextExtraMana and true or false
    end
    return db.statusTextExtraHealth and true or false
end

local function EntryUnit(entry)
    return entry.bar.unit or (entry.member and entry.member.unit)
end

local function NativeShown(entry)
    return entry.center:IsShown() or (entry.left and entry.left:IsShown()) or (entry.right and entry.right:IsShown())
end

local function HideNative(entry)
    entry.center:Hide()
    if entry.left then entry.left:Hide() end
    if entry.right then entry.right:Hide() end
end

local function SaveNativeString(saved, key, fontString)
    if not fontString then return end
    saved[key] = { text = fontString:GetText(), shown = fontString:IsShown() }
end

local function RestoreNativeString(saved, key, fontString)
    local state = fontString and saved[key]
    if not state then return end
    fontString:SetText(state.text or "")
    fontString:SetShown(state.shown)
end

local function SaveNative(entry)
    local saved = entry.saved or {}
    SaveNativeString(saved, "center", entry.center)
    SaveNativeString(saved, "left", entry.left)
    SaveNativeString(saved, "right", entry.right)
    entry.saved = saved
end

local function RestoreNative(entry)
    local saved = entry.saved
    if not saved then return end
    RestoreNativeString(saved, "center", entry.center)
    RestoreNativeString(saved, "left", entry.left)
    RestoreNativeString(saved, "right", entry.right)
end

local function OverrideNative(entry, fromBlizzard)
    if fromBlizzard or not entry.overridden then
        SaveNative(entry)
    else
        RestoreNative(entry)
    end
    entry.overridden = nil
    if entry.alphaTouched then
        entry.center:SetAlpha(1)
        entry.alphaTouched = nil
    end

    local db = BetterBlizzFramesDB
    if not db.statusTextExtra or not db[entry.groupKey] then return end

    if not IsEntryEnabled(entry) then
        HideNative(entry)
        entry.overridden = true
        return
    end
    if not db.statusTextExtraPercent or not NativeShown(entry) then return end

    local bar = entry.bar
    local unit = EntryUnit(entry)
    if not unit or not UnitExists(unit) or UnitIsDeadOrGhost(unit) then return end

    local value = bar:GetValue()
    local _, maxValue = bar:GetMinMaxValues()
    local alpha = 1
    if IsSecret(maxValue) then
        alpha = maxValue
    elseif maxValue <= 0 then
        return
    end

    if entry.left then entry.left:Hide() end
    if entry.right then entry.right:Hide() end
    entry.center:SetText(PercentText(entry, value, maxValue))
    if IsSecret(maxValue) then
        entry.center:SetAlpha(alpha)
        entry.alphaTouched = true
    end
    entry.center:Show()
    entry.overridden = true
end

local function Render(entry)
    if entry.native then
        OverrideNative(entry)
        return
    end
    if not IsEntryEnabled(entry) then
        if entry.active then
            ClearTexts(entry)
            entry.active = nil
        end
        return
    end
    entry.active = true
    ClearTexts(entry)

    local bar = entry.bar
    local unit = EntryUnit(entry)
    if not unit or not bar:IsShown() or not UnitExists(unit) then return end

    if UnitIsDeadOrGhost(unit) then
        if entry.zeroText then
            ShowText(entry, entry.center, DEAD, 1)
        end
        return
    end

    local value = bar:GetValue()
    local _, maxValue = bar:GetMinMaxValues()
    local alpha = 1
    if IsSecret(maxValue) then
        alpha = maxValue
    elseif maxValue <= 0 then
        return
    end

    local mode = BetterBlizzFramesDB.statusTextExtraPercent and "PERCENT" or C_CVar.GetCVar("statusTextDisplay")

    if mode == "BOTH" then
        if entry.left and entry.right then
            if not entry.isMana or not bar.powerToken or bar.powerToken == "MANA" then
                ShowText(entry, entry.left, PercentText(entry, value, maxValue), alpha)
            end
            ShowText(entry, entry.right, FormatNumber(bar, value), alpha)
        else
            ShowText(entry, entry.center, string.format("(%s) %s", PercentText(entry, value, maxValue), NumericText(bar, value, maxValue)), alpha)
        end
    elseif mode == "PERCENT" then
        ShowText(entry, entry.center, PercentText(entry, value, maxValue), alpha)
    else
        ShowText(entry, entry.center, NumericText(bar, value, maxValue), alpha)
    end
end

local function CreateBarText(bar, point, x, parent, y, size)
    local text = (parent or bar):CreateFontString(nil, "OVERLAY", "TextStatusBarText")
    if size then
        local font, _, flags = text:GetFont()
        text:SetFont(font, size, flags)
    end
    text:SetPoint(point, bar, point, x, y or 0)
    text:Hide()
    return text
end

local function GetPartyMember(i)
    return (PartyFrame and PartyFrame["MemberFrame" .. i]) or _G["PartyMemberFrame" .. i]
end

local function GetTextHolder(member, overlay)
    if member.bbfStatusTextHolder then return member.bbfStatusTextHolder end
    local parent = overlay or member
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetAllPoints(member)
    holder:SetFrameLevel(parent:GetFrameLevel() + 25)
    member.bbfStatusTextHolder = holder
    return holder
end

local function AddPartyBar(list, member, bar, isMana, center, left, right)
    if not bar then return end
    local entry = {
        bar = bar,
        member = member,
        isMana = isMana,
        groupKey = "statusTextExtraParty",
        zeroText = not isMana,
    }
    if center then
        entry.native = true
        entry.center, entry.left, entry.right = center, left, right
    else
        local holder = GetTextHolder(member, member.PartyMemberOverlay)
        entry.owned = true
        entry.center = CreateBarText(bar, "CENTER", 0, holder, 0.5, 10)
        entry.left = CreateBarText(bar, "LEFT", 2, holder, 0.5, 10)
        entry.right = CreateBarText(bar, "RIGHT", -2, holder, 0.5, 10)
    end
    table.insert(list, entry)
end

local function GetEntries()
    if entries then return entries end
    entries = { tot = {}, party = {} }

    for _, owner in ipairs({ TargetFrameToT or false, FocusFrameToT or false }) do
        if owner then
            local bars
            if owner.HealthBar then
                bars = { { owner.HealthBar, false, 0, 0, 0 }, { owner.ManaBar, true, 4, 2, 0 } }
            else
                bars = { { owner.healthbar, false, 2, 0, -2 }, { owner.manabar, true, 2, 0, -2 } }
            end
            local textureFrame = not owner.HealthBar and owner.GetName and owner:GetName() and _G[owner:GetName() .. "TextureFrame"]
            local holder = textureFrame and GetTextHolder(owner, textureFrame)
            local size = holder and 10
            for _, info in ipairs(bars) do
                local bar, isMana, leftX, centerX, rightX = info[1], info[2], info[3], info[4], info[5]
                if bar then
                    table.insert(entries.tot, {
                        bar = bar,
                        owner = owner,
                        isMana = isMana,
                        groupKey = "statusTextExtraToT",
                        owned = true,
                        center = CreateBarText(bar, "CENTER", centerX, holder, nil, size),
                        left = CreateBarText(bar, "LEFT", leftX, holder, nil, size),
                        right = CreateBarText(bar, "RIGHT", rightX, holder, nil, size),
                    })
                end
            end
        end
    end

    for i = 1, 4 do
        local member = GetPartyMember(i)
        if member then
            local container = member.HealthBarContainer
            if container and container.HealthBar then
                AddPartyBar(entries.party, member, container.HealthBar, false, container.CenterText, container.LeftText, container.RightText)
            else
                local hpBar = member.HealthBar or member.healthbar
                AddPartyBar(entries.party, member, hpBar, false, hpBar and hpBar.TextString, hpBar and hpBar.LeftText, hpBar and hpBar.RightText)
            end
            local manaBar = member.ManaBar or member.manabar
            if manaBar then
                AddPartyBar(entries.party, member, manaBar, true, manaBar.CenterText or manaBar.TextString, manaBar.LeftText, manaBar.RightText)
            end
        end
    end

    return entries
end

local function RenderGroup(list)
    for _, entry in ipairs(list) do
        Render(entry)
    end
end

local function HookToT(list)
    if totHooked then return end
    totHooked = true
    for _, entry in ipairs(list) do
        entry.bar:HookScript("OnValueChanged", function() Render(entry) end)
        entry.bar:HookScript("OnMinMaxChanged", function() Render(entry) end)
        entry.owner:HookScript("OnShow", function() Render(entry) end)
    end
end

local function HookParty(list)
    if partyHooked then return end
    partyHooked = true
    local nativeBars
    for _, entry in ipairs(list) do
        if entry.native then
            if entry.bar.UpdateTextStringWithValues then
                hooksecurefunc(entry.bar, "UpdateTextStringWithValues", function() OverrideNative(entry, true) end)
            else
                nativeBars = nativeBars or {}
                nativeBars[entry.bar] = entry
            end
        else
            entry.bar:HookScript("OnValueChanged", function() Render(entry) end)
            entry.bar:HookScript("OnMinMaxChanged", function() Render(entry) end)
            entry.member:HookScript("OnShow", function() Render(entry) end)
        end
    end
    if nativeBars and TextStatusBar_UpdateTextStringWithValues then
        hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", function(bar)
            local entry = nativeBars[bar]
            if entry then OverrideNative(entry, true) end
        end)
    end
end

local function UpdateCVarWatcher(list, enabled)
    if enabled then
        if not cvarFrame then
            cvarFrame = CreateFrame("Frame")
            cvarFrame:SetScript("OnEvent", function(_, _, cvar)
                if cvar == "statusTextDisplay" then
                    RenderGroup(list.tot)
                    RenderGroup(list.party)
                end
            end)
        end
        cvarFrame:RegisterEvent("CVAR_UPDATE")
    elseif cvarFrame then
        cvarFrame:UnregisterEvent("CVAR_UPDATE")
    end
end

function BBF.StatusBarTextExtra()
    local db = BetterBlizzFramesDB
    local tot = db.statusTextExtra and db.statusTextExtraToT
    local party = db.statusTextExtra and db.statusTextExtraParty
    if not tot and not party and not entries then return end

    local list = GetEntries()
    if tot then
        HookToT(list.tot)
    end
    if party then
        HookParty(list.party)
    end
    UpdateCVarWatcher(list, tot or party)

    RenderGroup(list.tot)
    RenderGroup(list.party)
end
