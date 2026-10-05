function BBF.DruidAlwaysShowCombos()
    if not BetterBlizzFramesDB.druidAlwaysShowCombos then return end
    if UnitClassBase("player") ~= "DRUID" then return end
    if BBF.DruidAlwaysShowCombosActive then return end
    local frame = DruidComboPointBarFrame
    if not frame then
        if BBF.ComboPointBar and BBF.UpdateComboPointBars then
            BBF.UpdateComboPointBars()
        end
        return
    end

    local function TagCombos(comboPointFrame)
        if not comboPointFrame then return end
        if comboPointFrame.taggedCombos then return end

        local comboPoints = {}
        local visibleComboPoints = 0

        -- Loop through the combo point children and gather visible ones
        for i = 1, comboPointFrame:GetNumChildren() do
            local child = select(i, comboPointFrame:GetChildren())

            -- Only consider shown combo points
            if child:IsShown() then
                visibleComboPoints = visibleComboPoints + 1
                table.insert(comboPoints, child)
            end
        end

        -- Sort the combo points by their layoutIndex
        table.sort(comboPoints, function(a, b)
            return (a.layoutIndex or 0) < (b.layoutIndex or 0)
        end)

        -- Apply textures to the first three combo points
        for i = 1, 5 do
            if comboPoints[i] then
                local comboPoint = comboPoints[i]
                comboPointFrame["ComboPoint" .. i] = comboPoint
            end
        end

        -- Mark as overcharge points if all points are visible
        if visibleComboPoints == 5 then
            comboPointFrame.taggedCombos = true
        end
    end

    TagCombos(frame)

    local function UpdateDruidComboPoints(self)
        if not self then return end
        TagCombos(frame)
        if not self.ComboPoint1 then return end
        local form = GetShapeshiftFormID()
        if form == 1 then return end

        local comboPoints = UnitPower("player", self.powerType)

        if comboPoints > 0 then
            self:Show()
        else
            self:Hide()
        end

        for i, point in ipairs(self.classResourceButtonTable) do
            local isFull = i <= comboPoints

            point.Point_Icon:SetAlpha(isFull and 1 or 0)
            point.BG_Active:SetAlpha(isFull and 1 or 0)
            point.BG_Inactive:SetAlpha(isFull and 0 or 1)
            point.Point_Deplete:SetAlpha(0)
        end
    end

    frame:HookScript("OnHide", function(self)
        TagCombos(frame)
        if not self.ComboPoint1 then return end
        local comboPoints = UnitPower("player", frame.powerType)
        if comboPoints > 0 then
            self:Show()
        end
    end)

    local listener = CreateFrame("Frame")
    listener:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    listener:SetScript("OnEvent", function(_, _, _, powerType)
        if powerType == "COMBO_POINTS" then
            UpdateDruidComboPoints(frame)
        end
    end)
    BBF.DruidAlwaysShowCombosActive = true
end

local moveComboInForm = {
    [1] = true,
    [5] = true,
    -- [31] = true,
    -- [32] = true,
    -- [33] = true,
    -- [34] = true,
    -- [35] = true,
}

local comboNudgeHooked
local comboBlizzPoint

local function ComboPointsMovedElsewhere()
    local db = BetterBlizzFramesDB
    return (db.moveResourceDRUID and db.moveResourceStackPos and db.moveResourceStackPos["DRUID"]) or (db.moveResourceToTarget and db.moveResourceToTargetDruid)
end

local function ApplyComboNudge()
    local frame = DruidComboPointBarFrame
    if not frame and BBF.ComboPointBar and BBF.ReanchorComboPointBar then
        if not ComboPointsMovedElsewhere() then
            BBF.ReanchorComboPointBar()
        end
        return
    end
    if not frame or frame:IsProtected() or ComboPointsMovedElsewhere() then return end
    if BBF.HasNoPortrait("player") and BBF.PinClassFrameNoPortrait then
        BBF.PinClassFrameNoPortrait()
        return
    end
    if not comboBlizzPoint or frame:GetParent() ~= PlayerBottomManagedFrameContainer then return end

    frame.bbfNudging = true
    frame:ClearAllPoints()
    frame:SetPoint("TOP", PlayerBottomManagedFrameContainer, "TOP", comboBlizzPoint[1], comboBlizzPoint[2] + (BBF.classResourceNudgeY or 0) / frame:GetScale())
    frame.bbfNudging = false
end
BBF.ApplyClassResourceNudge = ApplyComboNudge

local function HookComboNudge()
    local frame = DruidComboPointBarFrame
    if comboNudgeHooked or not frame then return end
    comboNudgeHooked = true

    local point, relativeTo, _, x, y = frame:GetPoint(1)
    if point == "TOP" and relativeTo == PlayerBottomManagedFrameContainer then
        comboBlizzPoint = { x or 0, y or 0 }
    end

    hooksecurefunc(frame, "SetPoint", function(self, point, relativeTo, relativePoint, x, y)
        if self.bbfNudging or self.bbfPinning or self.bbfMoveResourceChanging or point ~= "TOP" then return end
        if type(relativeTo) == "number" then
            comboBlizzPoint = { relativeTo, relativePoint or 0 }
        elseif relativeTo == nil or relativeTo == PlayerBottomManagedFrameContainer then
            comboBlizzPoint = { x or 0, y or 0 }
        else
            return
        end
        if (BBF.classResourceNudgeY or 0) ~= 0 then
            ApplyComboNudge()
        end
    end)
end

local function SetComboNudge(y)
    if BBF.classResourceNudgeY == y then return end
    BBF.classResourceNudgeY = y
    HookComboNudge()
    ApplyComboNudge()
end

local function UpdateAltManaBar(cf)
    local bar = PlayerFrame.AltManaBarBBF
    if not bar then return end

    local form = GetShapeshiftFormID()
    local inNoManaForm = moveComboInForm[form]
    if inNoManaForm then
        local percent = UnitPowerPercent("player", Enum.PowerType.Mana, false, CurveConstants.ScaleTo100) or 0
        local percentMana = string.format("%.0f%%", percent)

        bar:SetMinMaxValues(0, UnitPowerMax("player", Enum.PowerType.Mana))
        bar:SetValue(UnitPower("player", Enum.PowerType.Mana))

        local display = GetCVar("statusTextDisplay")

        if display == "NONE" then
            bar.TextString:SetText("")
        elseif display == "NUMERIC" then
            bar.TextString:SetText(AbbreviateNumbers(UnitPower("player", Enum.PowerType.Mana)))
        elseif display == "PERCENT" then
            bar.TextString:SetText(percentMana)
        elseif display == "BOTH" and bar.LeftText and bar.RightText then
            bar.TextString:SetText("")
            bar.LeftText:SetText(percentMana)
            bar.RightText:SetText(AbbreviateNumbers(UnitPower("player", Enum.PowerType.Mana)))
        end

        bar:Show()
        if not cf then
            PlayerFrame.PlayerFrameContainer.FrameTexture:Hide()
            PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:Show()
        end
        if BBF.HasNoPortrait("player") and PlayerFrame.noPortraitMode then
            if BetterBlizzFramesDB.bigPlayerHealthbar then
                PlayerFrame.noPortraitMode.Texture:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-PortraitOff-Large-Alt-Unified.tga")
            else
                PlayerFrame.noPortraitMode.Texture:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-PortraitOff-Large-Alt.tga")
            end
        end
        SetComboNudge(-9)
    elseif bar:IsShown() then
        C_Timer.After(0.2, function()
            SetComboNudge(0)
            if not cf and not AlternatePowerBar:IsShown() then
                PlayerFrame.PlayerFrameContainer.FrameTexture:Show()
                PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:Hide()
            end
            if BBF.HasNoPortrait("player") and PlayerFrame.noPortraitMode then
                if PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:IsShown() then
                    if BetterBlizzFramesDB.bigPlayerHealthbar then
                        PlayerFrame.noPortraitMode.Texture:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-PortraitOff-Large-Alt-Unified.tga")
                    else
                        PlayerFrame.noPortraitMode.Texture:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-PortraitOff-Large-Alt.tga")
                    end
                else
                    if BetterBlizzFramesDB.bigPlayerHealthbar then
                        PlayerFrame.noPortraitMode.Texture:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-PortraitOff-Large-Unified.tga")
                    else
                        PlayerFrame.noPortraitMode.Texture:SetTexture("Interface\\AddOns\\BetterBlizzFrames\\media\\blizzTex\\UI-HUD-UnitFrame-Player-PortraitOff-Large.tga")
                    end
                end
            end
            bar:Hide()
        end)
    end
end



local manaOnlyTextKeys = { "ManaBarText", "LeftText", "RightText" }
local manaOnlyCopyKeys = { "cvar", "textLockable", "forceShow", "forceHideText", "capNumericDisplay", "numericDisplayTransformFunc", "disableMaxValue", "disablePercentages", "showNumeric", "showPercentage", "zeroText", "alwaysPrefix" }

local function CreateManaOnlyBar(isActive, extraEvent)
    local stock = PlayerFrame.manabar
    if not stock or PlayerFrame.ManaOnlyBarBBF then return end
    local db = BetterBlizzFramesDB
    local manaType = Enum.PowerType.Mana
    local active = false
    local guard = false

    local hider = CreateFrame("Frame")
    hider:Hide()

    local bar = CreateFrame("StatusBar", nil, stock)
    bar:SetAllPoints(stock)
    bar:SetFrameLevel(stock:GetFrameLevel())
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    bar:SetMinMaxValues(0, 1)
    bar:Hide()
    bar.fill = bar:GetStatusBarTexture()
    bar.masks = {}
    bar.UpdateTextStringWithValues = TextStatusBarMixin.UpdateTextStringWithValues
    bar.GetNumericDisplay = TextStatusBarMixin.GetNumericDisplay
    bar.texts = {}
    for _, key in ipairs(manaOnlyTextKeys) do
        bar.texts[key] = bar:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
    end
    bar.TextString = bar.texts.ManaBarText
    bar.LeftText = bar.texts.LeftText
    bar.RightText = bar.texts.RightText

    hooksecurefunc(stock, "SetFrameLevel", function(_, level)
        bar:SetFrameLevel(level)
    end)

    local function AddMasks(src)
        for i = 1, src:GetNumMaskTextures() do
            local mask = src:GetMaskTexture(i)
            if mask and not bar.masks[mask] then
                bar.fill:AddMaskTexture(mask)
                bar.masks[mask] = true
            end
        end
    end

    local function CopyLook()
        local src = stock:GetStatusBarTexture()
        if not src then return end
        local atlas = src:GetAtlas()
        if atlas then
            bar.fill:SetAtlas(atlas, false)
        else
            bar.fill:SetTexture(src:GetTexture())
        end
        bar.fill:SetTexCoord(src:GetTexCoord())
        bar.fill:SetDrawLayer(src:GetDrawLayer())
        bar.fill:SetDesaturated(src:IsDesaturated())
        local r, g, b = stock:GetStatusBarColor()
        bar:SetStatusBarColor(r, g, b, 1)
        AddMasks(src)
    end

    local function DefaultLook()
        if db.changeUnitFrameManabarTexture and BBF.manaTexture then
            bar.fill:SetTexture(BBF.manaTexture)
            local r, g, b = BBF.GetCustomPowerColor and BBF.GetCustomPowerColor("MANA")
            if not r and BBF.GetDefaultPowerColor then
                r, g, b = BBF.GetDefaultPowerColor("MANA", stock)
            end
            bar:SetStatusBarColor(r or 0, g or 0, b or 1, 1)
        else
            bar.fill:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana", false)
            bar:SetStatusBarColor(1, 1, 1, 1)
        end
        local src = stock:GetStatusBarTexture()
        if src then
            bar.fill:SetDrawLayer(src:GetDrawLayer())
            AddMasks(src)
        end
    end

    local function ShowingMana()
        return UnitPowerType("player") == manaType
    end

    local function HideFill()
        local src = stock:GetStatusBarTexture()
        if not src then return end
        if not src.bbfManaOnlyHooked then
            src.bbfManaOnlyHooked = true
            hooksecurefunc(src, "SetAlpha", function(self)
                if guard or not active then return end
                guard = true
                self:SetAlpha(0)
                guard = false
            end)
        end
        guard = true
        src:SetAlpha(active and 0 or 1)
        guard = false
    end

    local function OnStockLook()
        if ShowingMana() then
            CopyLook()
        end
        if active then
            HideFill()
        end
    end
    hooksecurefunc(stock, "SetStatusBarTexture", OnStockLook)
    hooksecurefunc(stock, "SetStatusBarColor", OnStockLook)

    local regions = { stock.Spark }
    for _, key in ipairs(manaOnlyTextKeys) do
        regions[#regions + 1] = stock[key]
    end

    local function HideRegion(region)
        if region:GetParent() == hider then return end
        region.bbfManaOnlyParent = region:GetParent()
        guard = true
        region:SetParent(hider)
        guard = false
    end

    local function RestoreRegion(region)
        if region:GetParent() ~= hider then return end
        guard = true
        region:SetParent(region.bbfManaOnlyParent)
        guard = false
    end

    for _, region in ipairs(regions) do
        hooksecurefunc(region, "SetParent", function(self)
            if guard or not active then return end
            HideRegion(self)
        end)
    end

    local function TextLayout(key)
        local x, y, anchor = 0, 0, bar
        local npTex = BBF.HasNoPortrait("player") and PlayerFrame.noPortraitMode and PlayerFrame.noPortraitMode.Texture
        local cfTex = db.classicFrames and PlayerFrame.ClassicFrame and PlayerFrame.ClassicFrame.Texture
        if npTex then
            local leftX, manaY = BBF.NoPortraitManaTextOffsets()
            anchor, y = npTex, manaY
            x = key == "LeftText" and leftX or key == "RightText" and -67 or 2
        elseif cfTex then
            anchor, y = cfTex, -8.5
            x = key == "LeftText" and 107.5 or key == "RightText" and -7 or 52
        elseif db.symmetricPlayerFrame then
            x = key == "LeftText" and 10.5 or key == "RightText" and -5 or 4.5
        else
            x = key == "LeftText" and 1.5 or key == "RightText" and -2 or 0
        end
        local point = key == "LeftText" and "LEFT" or key == "RightText" and "RIGHT" or "CENTER"
        return point, anchor, x, y
    end

    local function SyncText(key)
        local own, src = bar.texts[key], stock[key]
        local parent = src.bbfManaOnlyParent
        if not parent or parent == BBF.hiddenFrame then
            own:SetParent(hider)
            return
        end
        own:SetParent(parent == stock and bar or parent)
        own:SetDrawLayer(src:GetDrawLayer())
        own:SetFontObject(src:GetFontObject())
        local font, size, flags = src:GetFont()
        if font then
            own:SetFont(font, size, flags)
        end
        own:SetTextColor(src:GetTextColor())
        own:SetShadowColor(src:GetShadowColor())
        own:SetShadowOffset(src:GetShadowOffset())
        own:SetScale(src:GetScale())
        own:ClearAllPoints()
        if key == "RightText" and db.centerCurrentValueOnBars then
            own:SetPoint("CENTER", bar.texts.ManaBarText, "CENTER", 0, 0)
            own:SetJustifyH("CENTER")
            return
        end
        local point, anchor, x, y = TextLayout(key)
        own:SetPoint(point, anchor, point, x, y)
        own:SetJustifyH(point)
    end

    local function GetMana()
        return UnitPower("player", manaType), UnitPowerMax("player", manaType)
    end

    local function UpdateTexts()
        if not active then return end
        local mana, maxMana = GetMana()
        if issecretvalue and (issecretvalue(mana) or issecretvalue(maxMana)) then
            bar.LeftText:Hide()
            bar.RightText:Hide()
            bar.TextString:Hide()
            local shown = (stock.cvar and GetCVar(stock.cvar) == "1" and stock.textLockable) or stock.forceShow or ((stock.lockShow or 0) > 0 and not stock.forceHideText)
            if shown then
                local mode = GetCVar("statusTextDisplay")
                if stock.showNumeric and stock.showPercentage then
                    mode = "BOTH"
                elseif stock.showNumeric then
                    mode = "NUMERIC"
                elseif stock.showPercentage then
                    mode = "PERCENT"
                end
                if stock.disablePercentages and mode == "PERCENT" then
                    mode = "NUMERIC"
                end
                local formatNumber = stock.capNumericDisplay and AbbreviateLargeNumbers or BreakUpLargeNumbers
                local value = formatNumber(mana)
                if mode == "BOTH" then
                    if not stock.disablePercentages then
                        bar.LeftText:SetText(string.format("%.0f%%", UnitPowerPercent("player", manaType, false, CurveConstants.ScaleTo100)))
                        bar.LeftText:Show()
                    end
                    bar.RightText:SetText(value)
                    bar.RightText:Show()
                elseif mode == "PERCENT" then
                    bar.TextString:SetText(string.format("%.0f%%", UnitPowerPercent("player", manaType, false, CurveConstants.ScaleTo100)))
                    bar.TextString:Show()
                else
                    bar.TextString:SetText(stock.disableMaxValue and value or string.format("%s / %s", value, formatNumber(maxMana)))
                    bar.TextString:Show()
                end
            end
        else
            for _, key in ipairs(manaOnlyCopyKeys) do
                bar[key] = stock[key]
            end
            bar.lockShow = stock.lockShow or 0
            bar.prefix = stock.prefix and MANA
            bar:UpdateTextStringWithValues(bar.TextString, mana, 0, maxMana)
        end

        if BBF.statusBarTextHookBBF then
            local setting = BBF.statusBarTextFormatMode
            local value = AbbreviateNumbers(mana)
            if setting == "BOTH" then
                bar.RightText:SetText(value)
            elseif setting == "NUMERIC" and BBF.statusBarTextFormatSingle then
                bar.TextString:SetText(value)
            elseif setting == "NUMERIC" or setting == "NONE" then
                bar.TextString:SetText(string.format("%s / %s", value, AbbreviateNumbers(maxMana)))
            end
        end
        if db.centerCurrentValueOnBars then
            bar.LeftText:Hide()
        end
    end
    hooksecurefunc(stock, "UpdateTextString", UpdateTexts)

    local function UpdateValue(snap)
        local mana, maxMana = GetMana()
        bar:SetMinMaxValues(0, maxMana)
        local interp = not snap and db.smoothBars and db.smoothManabars and BBF.hasBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut
        if interp then
            bar:SetValue(mana, interp)
        else
            bar:SetValue(mana)
        end
        UpdateTexts()
    end

    local function SetStockAlpha(alpha)
        local ov = stock.bbfSmoothOverlay
        if ov then ov:SetAlpha(alpha) end
        if stock.FeedbackFrame then stock.FeedbackFrame:SetAlpha(alpha) end
        if stock.FullPowerFrame then stock.FullPowerFrame:SetAlpha(alpha) end
        if stock.ManaCostPredictionBar then stock.ManaCostPredictionBar:SetAlpha(alpha) end
    end

    local function Refresh()
        local state = isActive() and not (UnitHasVehicleUI and UnitHasVehicleUI("player")) or false
        if state == active then
            if state then
                SetStockAlpha(0)
                UpdateValue()
            end
            return
        end
        active = state
        HideFill()
        SetStockAlpha(state and 0 or 1)
        for _, region in ipairs(regions) do
            if state then
                HideRegion(region)
            else
                RestoreRegion(region)
            end
        end
        bar:SetShown(state)
        if state then
            for _, key in ipairs(manaOnlyTextKeys) do
                SyncText(key)
            end
            UpdateValue(true)
        else
            for _, key in ipairs(manaOnlyTextKeys) do
                bar.texts[key]:SetParent(hider)
            end
        end
    end

    local f = CreateFrame("Frame")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
    f:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
    f:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
    f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    if extraEvent then
        f:RegisterEvent(extraEvent)
    end
    f:SetScript("OnEvent", function(_, evt, _, ptype)
        if (evt == "UNIT_POWER_FREQUENT" or evt == "UNIT_MAXPOWER") and ptype ~= "MANA" then return end
        Refresh()
    end)

    DefaultLook()
    if ShowingMana() then
        CopyLook()
    end
    PlayerFrame.ManaOnlyBarBBF = bar
    Refresh()
end

function BBF.CreateAltManaBar()
    if PlayerFrame.AltManaBarBBF or PlayerFrame.ManaOnlyBarBBF then return end -- already created
    if not (BetterBlizzFramesDB.createAltManaBarDruid or BetterBlizzFramesDB.createAltManaBarDruidManaOnly) then return end
    if UnitClassBase("player") ~= "DRUID" then return end
    if BetterBlizzFramesDB.createAltManaBarDruidManaOnly then
        CreateManaOnlyBar(function()
            return UnitPowerType("player") ~= Enum.PowerType.Mana
        end)
        return
    end
    if BBF.HasNoPortrait("player") and (BetterBlizzFramesDB.hideUnitFramePlayerMana or BetterBlizzFramesDB.hideUnitFramePlayerSecondResource) then return end
    local db = BetterBlizzFramesDB
    if db.useMiniPlayerFrame then return end
    local cf = db.classicFrames
    local noPortrait = BBF.HasNoPortrait("player")

    local bar = CreateFrame("StatusBar", "AltManaBarBBF", PlayerFrame)
    if cf then
        bar:SetSize(104, 12)
        bar:SetPoint("BOTTOMLEFT", PlayerFrame, "BOTTOMLEFT", 95, 17)
    elseif db.noPortrait then
        bar:SetSize(124, 10)
        bar:SetPoint("BOTTOMLEFT", PlayerFrame, "BOTTOMLEFT", 85, 17.5)
    else
        bar:SetSize(124, 10)
        bar:SetPoint("BOTTOMLEFT", PlayerFrame, "BOTTOMLEFT", 85, 18)
    end
    if db.changeUnitFrameManabarTexture then
        bar:SetStatusBarTexture(BBF.manaTexture)
        bar:SetStatusBarColor(0, 0, 1)
    else
        bar:SetStatusBarTexture("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana")
        bar:SetStatusBarColor(1, 1, 1)
    end
    bar:SetMinMaxValues(0, 100)
    bar:Hide()

    bar.overlay = CreateFrame("Frame", nil, bar)
    bar.overlay:SetFrameStrata("DIALOG")

    if cf then
        bar.Background = bar:CreateTexture(nil, "BACKGROUND")
        bar.Background:SetAllPoints()
        bar.Background:SetColorTexture(0, 0, 0, 0.5)

        bar.Border = bar:CreateTexture(nil, "OVERLAY")
        bar.Border:SetSize(0, 16)
        bar.Border:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
        bar.Border:SetTexCoord(0.125, 0.250, 1, 0)
        bar.Border:SetPoint("TOPLEFT", 4, 0)
        bar.Border:SetPoint("TOPRIGHT", -4, 0)

        bar.LeftBorder = bar:CreateTexture(nil, "OVERLAY")
        bar.LeftBorder:SetSize(16, 16)
        bar.LeftBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
        bar.LeftBorder:SetTexCoord(0, 0.125, 1, 0)
        bar.LeftBorder:SetPoint("RIGHT", bar.Border, "LEFT")

        bar.RightBorder = bar:CreateTexture(nil, "OVERLAY")
        bar.RightBorder:SetSize(16, 16)
        bar.RightBorder:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
        bar.RightBorder:SetTexCoord(0.125, 0, 1, 0)
        bar.RightBorder:SetPoint("LEFT", bar.Border, "RIGHT")
    elseif noPortrait then
        bar.Background = bar:CreateTexture(nil, "BACKGROUND")
        bar.Background:SetAllPoints()
        bar.Background:SetColorTexture(0, 0, 0, 0.5)
    end

    local display = GetCVar("statusTextDisplay")

    -- Center text like ManaBarText
    local xtraOffset = noPortrait and 0 or cf and -1 or -0.5
    local extraXOffset = noPortrait and 0.5 or 0
    bar.TextString = bar.overlay:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
    local f,s,o = AlternatePowerBar.TextString:GetFont()
    bar.TextString:SetFont(f,s,o)
    bar.TextString:ClearAllPoints()
    bar.TextString:SetPoint("CENTER",bar,"CENTER",2+extraXOffset,xtraOffset)

    C_Timer.After(0.5, function()
        local f,s,o = AlternatePowerBar.TextString:GetFont()
        bar.TextString:SetFont(f,s,o)
    end)

    -- Left and Right (only created if BOTH is set)
    if display == "BOTH" then
        bar.LeftText = bar.overlay:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
        local f,s,o = AlternatePowerBar.LeftText:GetFont()
        bar.LeftText:SetFont(f,s,o)
        bar.LeftText:SetPoint("LEFT",bar,"LEFT",noPortrait and 2 or cf and 0 or 2,xtraOffset)

        bar.RightText = bar.overlay:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
        local f,s,o = AlternatePowerBar.RightText:GetFont()
        bar.RightText:SetFont(f,s,o)
        bar.RightText:SetPoint("RIGHT",bar,"RIGHT",0,xtraOffset)

        C_Timer.After(0.5, function()
            local f, s, o = AlternatePowerBar.LeftText:GetFont()
            bar.LeftText:SetFont(f, s, o)
            local f, s, o = AlternatePowerBar.RightText:GetFont()
            bar.RightText:SetFont(f, s, o)
        end)
    end

    local f = CreateFrame("Frame")
    f:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    f:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
    f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function(_, evt, unit, ptype)
        if evt == "UNIT_POWER_UPDATE" and ptype ~= "MANA" then return end
        UpdateAltManaBar(cf)
    end)

    if display == "NONE" then
        bar:EnableMouse(true)
        bar:SetScript("OnEnter", function(self)
            local mana = UnitPower("player", Enum.PowerType.Mana)
            local maxMana = UnitPowerMax("player", Enum.PowerType.Mana)
            self.TextString:SetText(BreakUpLargeNumbers(mana) .. " / " .. BreakUpLargeNumbers(maxMana))
        end)

        bar:SetScript("OnLeave", function(self)
            self.TextString:SetText("")
        end)
    end
    PlayerFrame.AltManaBarBBF = bar
    UpdateAltManaBar(cf)
    if cf and BBF.UpdateBronzeTint then
        BBF.UpdateBronzeTint()
    end
end