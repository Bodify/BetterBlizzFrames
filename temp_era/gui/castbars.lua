local L = BBF.L
local sliderSpacingY = -15
local checkboxSpacingY = 5
local checkboxIndentX = 10

local function GetCastbarTexture()
    return BetterBlizzFramesDB.changeUnitFrameCastbarTexture
        and BBF.LSM:Fetch(BBF.LSM.MediaType.STATUSBAR, BetterBlizzFramesDB.unitFrameCastbarTexture)
        or 137012
end

function BBF.SetupCastbarGUI()
    local frame = CreateFrame("Frame")
    frame.name = L["Castbars"] .. " (new)"
    frame.parent = BetterBlizzFrames.name
    local subCategory = Settings.RegisterCanvasLayoutSubcategory(BBF.category, frame, frame.name, frame.name)
    subCategory.ID = frame.name

    -- Background overlay (not visible — BACKGROUND layer behind settings panel)
    -- local bgImg = frame:CreateTexture(nil, "BACKGROUND")
    -- bgImg:SetAtlas("professions-recipe-background")
    -- bgImg:SetPoint("CENTER", frame, "CENTER", -8, 4)
    -- bgImg:SetSize(680, 610)
    -- bgImg:SetAlpha(0.4)
    -- bgImg:SetVertexColor(0, 0, 0)

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(700, 612)
    scrollFrame:SetPoint("CENTER", frame, "CENTER", -20, 3)

    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame.name = frame.name
    contentFrame:SetSize(680, 520)
    scrollFrame:SetScrollChild(contentFrame)

    -- Column layout: 4 x 160 wide, 8px gaps
    local colWidth = 157
    local colPadLeft = 20
    local colGap = 8
    local colTop = -10
    local borderHeight = 386
    local function ColLeft(n) return colPadLeft + colGap + (n - 1) * (colWidth + colGap) end

    -- Old layout (for reference):
    -- local mainGuiAnchor at (55, 20), firstLineX = 50, firstLineY = -65
    -- border at CENTER, mainGuiAnchor, CENTER, 50, -65+30-175 = (105, -210) from contentFrame TOPLEFT

    ---------------------------------------------------------------------------
    -- Player Castbar
    ---------------------------------------------------------------------------
    local playerCastbarBorder = BBF.BorderedFrame(contentFrame, colWidth, borderHeight)
    playerCastbarBorder:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", ColLeft(1), colTop)

    -- Decorative castbar (visual only, uses player's chosen texture)
    local playerCastBarBg = contentFrame:CreateTexture(nil, "ARTWORK")
    playerCastBarBg:SetTexture(GetCastbarTexture())
    playerCastBarBg:SetSize(110, 13)
    playerCastBarBg:SetPoint("TOP", playerCastbarBorder, "TOP", 0, -8)
    playerCastBarBg:SetVertexColor(1, 0.7, 0)
    hooksecurefunc(BBF, "UpdateCustomTextures", function()
        playerCastBarBg:SetTexture(GetCastbarTexture())
    end)
    local playerCastBarFrame = contentFrame:CreateTexture(nil, "OVERLAY")
    playerCastBarFrame:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small")
    playerCastBarFrame:SetSize(150, 49)
    playerCastBarFrame:SetPoint("CENTER", playerCastBarBg, "CENTER", 0, 0)

    -- Section header
    local anchorSubPlayerCastbar = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorSubPlayerCastbar:SetPoint("TOP", playerCastBarBg, "BOTTOM", 0, -5)
    anchorSubPlayerCastbar:SetText(L["Player_Castbar"])

    -- Sliders
    local playerCastBarScale = BBF.Slider(contentFrame, "playerCastBarScale", "Size", 0.1, 2, 0.01, BBF.ChangeCastbarSizes)
    playerCastBarScale:SetPoint("TOP", anchorSubPlayerCastbar, "BOTTOM", 0, sliderSpacingY)

    local playerCastBarXPos = BBF.Slider(contentFrame, "playerCastBarXPos", "x offset", -300, 300, 1, BBF.ChangeCastbarSizes)
    playerCastBarXPos:SetPoint("TOP", playerCastBarScale, "BOTTOM", 0, sliderSpacingY)

    local playerCastBarYPos = BBF.Slider(contentFrame, "playerCastBarYPos", "y offset", -300, 300, 1, BBF.ChangeCastbarSizes)
    playerCastBarYPos:SetPoint("TOP", playerCastBarXPos, "BOTTOM", 0, sliderSpacingY)

    local playerCastBarIconScale = BBF.Slider(contentFrame, "playerCastBarIconScale", "Icon Size", 0.1, 2, 0.01, BBF.ChangeCastbarSizes)
    playerCastBarIconScale:SetPoint("TOP", playerCastBarYPos, "BOTTOM", 0, sliderSpacingY)

    local playerCastBarWidth = BBF.Slider(contentFrame, "playerCastBarWidth", "Width", 50, 300, 1, BBF.ChangeCastbarSizes)
    playerCastBarWidth:SetPoint("TOP", playerCastBarIconScale, "BOTTOM", 0, sliderSpacingY)

    local playerCastBarHeight = BBF.Slider(contentFrame, "playerCastBarHeight", "Height", 5, 30, 1, BBF.ChangeCastbarSizes)
    playerCastBarHeight:SetPoint("TOP", playerCastBarWidth, "BOTTOM", 0, sliderSpacingY)

    -- Checkboxes: Icon, Timer / Text, Border / Center
    local playerCastBarShowIcon = BBF.Checkbox(contentFrame, "playerCastBarShowIcon", L["Icon"], BBF.ShowPlayerCastBarIcon)
    playerCastBarShowIcon:SetPoint("TOPLEFT", playerCastBarHeight, "BOTTOMLEFT", checkboxIndentX, -checkboxSpacingY)
    BBF.Tooltip(playerCastBarShowIcon, L["Tooltip_Player_Castbar_Icon"])

    local playerCastBarTimer = BBF.Checkbox(contentFrame, "playerCastBarTimer", L["Timer"], BBF.CastBarTimerCaller)
    playerCastBarTimer:SetPoint("LEFT", playerCastBarShowIcon.Text, "RIGHT", checkboxIndentX, 0)
    BBF.Tooltip(playerCastBarTimer, L["Tooltip_Castbar_Timer"])

    local playerCastBarShowText = BBF.Checkbox(contentFrame, "playerCastBarShowText", L["Text"], BBF.ChangeCastbarSizes)
    playerCastBarShowText:SetPoint("TOPLEFT", playerCastBarShowIcon, "BOTTOMLEFT", 0, checkboxSpacingY)
    BBF.Tooltip(playerCastBarShowText, L["Tooltip_Show_Castbar_Text_Desc"], L["Tooltip_Show_Castbar_Text_Desc"])

    local playerCastBarShowBorder = BBF.Checkbox(contentFrame, "playerCastBarShowBorder", L["Border"], BBF.ChangeCastbarSizes)
    playerCastBarShowBorder:SetPoint("LEFT", playerCastBarShowText.Text, "RIGHT", checkboxIndentX, 0)
    BBF.Tooltip(playerCastBarShowBorder, L["Tooltip_Show_Castbar_Border_Desc"], L["Tooltip_Show_Castbar_Border_Desc"])

    local playerCastBarTimerCentered = BBF.Checkbox(contentFrame, "playerCastBarTimerCentered", L["Center"], BBF.CastBarTimerCaller)
    playerCastBarTimerCentered:SetPoint("TOPLEFT", playerCastBarShowText, "BOTTOMLEFT", 0, checkboxSpacingY)
    BBF.Tooltip(playerCastBarTimerCentered, L["Tooltip_Player_Castbar_Timer_Center"])

    -- Reset button
    local widgets = {
        playerCastBarScale, playerCastBarXPos, playerCastBarYPos,
        playerCastBarIconScale, playerCastBarWidth, playerCastBarHeight,
        playerCastBarShowIcon, playerCastBarTimer, playerCastBarTimerCentered,
        playerCastBarShowText, playerCastBarShowBorder,
    }

    local resetPlayerCastbar = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
    resetPlayerCastbar:SetText(L["Reset"])
    resetPlayerCastbar:SetWidth(70)
    resetPlayerCastbar:SetPoint("TOP", playerCastbarBorder, "BOTTOM", 0, 0)
    resetPlayerCastbar:SetScript("OnClick", function()
        for _, w in ipairs(widgets) do
            local default = w.bbfDefault
            if w.bbfMinDefault then
                w:SetMinMaxValues(w.bbfMinDefault, w.bbfMaxDefault)
                w:SetValue(default)
            else
                w:SetChecked(default)
                BetterBlizzFramesDB[w.bbfKey] = default
            end
        end
        BBF.ChangeCastbarSizes()
    end)
end
