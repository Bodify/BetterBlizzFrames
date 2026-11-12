local minimapTweaksHooked
local minimapTweaksApplied
local titleScaled
local titleHidden

local titleClusterKeys = { "BorderTop", "ZoneTextButton", "Tracking", "IndicatorFrame", "InstanceDifficulty" }
local titleGlobalNames = { "GameTimeFrame", "AddonCompartmentFrame", "TimeManagerClockButton" }

local function MinimapTweaksActive()
    local db = BetterBlizzFramesDB
    return db.foreverMinimapTweaks and not db.classicMinimap
end

local function StoreBasePoint(frame, ...)
    local base = frame.bbfBasePoint
    if not base then
        base = {}
        frame.bbfBasePoint = base
    end
    base[1], base[2], base[3], base[4], base[5] = ...
end

local function ApplyMinimapNudge(container)
    local base = container.bbfBasePoint
    if not base or type(base[5]) ~= "number" then return end
    local x, y = base[4], base[5]
    if MinimapTweaksActive() then
        local db = BetterBlizzFramesDB
        local scale = container:GetScale()
        x = x + (db.foreverMinimapXPos or 0) / scale
        y = y + (db.foreverMinimapYPos or 12) / scale
    end
    container.bbfNudging = true
    container:SetPoint(base[1], base[2], base[3], x, y)
    container.bbfNudging = false
end

local function ApplyMinimapCompass()
    if not BBF.isForever or not MinimapCompassTexture or GetCVarBool("rotateMinimap") then return end
    local atlas = MinimapTweaksActive() and "UI-HUD-Minimap-Frame-Circle" or "UI-HUD-Minimap-Frame"
    if MinimapCompassTexture:GetAtlas() == atlas then return end
    MinimapCompassTexture.bbfChanging = true
    MinimapCompassTexture:SetAtlas(atlas)
    MinimapCompassTexture.bbfChanging = false
end

local function ApplyTitleScale()
    local scale = MinimapTweaksActive() and (BetterBlizzFramesDB.foreverMinimapTitleScale or 1) or 1
    if scale == 1 and not titleScaled then return end
    titleScaled = scale ~= 1
    if not MinimapCluster then return end
    for _, key in ipairs(titleClusterKeys) do
        local frame = MinimapCluster[key]
        if frame then
            frame:SetScale(scale)
        end
    end
    for _, name in ipairs(titleGlobalNames) do
        local frame = _G[name]
        if frame and frame:GetParent() == MinimapCluster then
            frame:SetScale(scale)
        end
    end
end

local function TitleHideActive()
    local db = BetterBlizzFramesDB
    return db.foreverMinimapTweaks and db.foreverMinimapHideTitle
end

local function KeepTitleHidden(self)
    if TitleHideActive() then
        self.bbfTitleWasShown = true
        self:Hide()
    end
end

function BBF.UpdateMinimapTitle()
    local hide = TitleHideActive()
    if not hide and not titleHidden then return end
    titleHidden = hide
    if not MinimapCluster then return end
    local frames = { MinimapCluster.ZoneTextButton }
    if BetterBlizzFramesDB.classicMinimap then
        table.insert(frames, BBF.classicMinimapHeader)
    else
        table.insert(frames, MinimapCluster.BorderTop)
        table.insert(frames, MinimapCluster.Tracking)
        table.insert(frames, GameTimeFrame)
        table.insert(frames, AddonCompartmentFrame)
        table.insert(frames, TimeManagerClockButton)
        if not TimeManagerClockButton and not BBF.minimapTitleClockWait then
            BBF.minimapTitleClockWait = true
            EventUtil.ContinueOnAddOnLoaded("Blizzard_TimeManager", function()
                if TitleHideActive() and not BetterBlizzFramesDB.classicMinimap then
                    titleHidden = false
                    BBF.UpdateMinimapTitle()
                end
            end)
        end
    end
    for _, frame in pairs(frames) do
        if hide then
            if not frame.bbfTitleHook and frame.HookScript then
                frame.bbfTitleHook = true
                frame:HookScript("OnShow", KeepTitleHidden)
            end
            if frame:IsShown() then
                frame.bbfTitleWasShown = true
            end
            frame:Hide()
        elseif frame.bbfTitleWasShown then
            frame.bbfTitleWasShown = nil
            frame:Show()
        end
    end
end

local function HookMinimapTweaks()
    if minimapTweaksHooked then return end
    minimapTweaksHooked = true

    local container = MinimapCluster and MinimapCluster.MinimapContainer
    if container then
        StoreBasePoint(container, container:GetPoint(1))
        hooksecurefunc(container, "SetPoint", function(self, ...)
            if self.bbfNudging then return end
            StoreBasePoint(self, ...)
            ApplyMinimapNudge(self)
        end)
    end

    if BBF.isForever and MinimapCompassTexture then
        hooksecurefunc(MinimapCompassTexture, "SetAtlas", function(self)
            if self.bbfChanging then return end
            ApplyMinimapCompass()
        end)
    end

    EventUtil.ContinueOnAddOnLoaded("Blizzard_TimeManager", ApplyTitleScale)

    local dielFrame = MinimapCluster and MinimapCluster.DielFrame
    if dielFrame then
        dielFrame:HookScript("OnShow", function(self)
            if MinimapTweaksActive() then
                self:Hide()
            end
        end)
    end
end

local MAIL_ICON = "Interface\\Icons\\INV_Letter_15"
local MAIL_BORDER = 136430
local MAIL_ANGLE = 13
local MAIL_RIM_GAP = 9
local MAIL_RIM_SIDE = 0
local MAIL_ICON_X, MAIL_ICON_Y = 15, -15
local MAIL_BORDER_SIZE = 48
local mailHolder

local function ClassicMailActive()
    local db = BetterBlizzFramesDB
    return db.foreverMinimapTweaks and db.minimapClassicMail and not db.classicMinimap
end

function BBF.PlaceMinimapMail()
    local mail = mailHolder and mailHolder.mail
    if not mail or not mailHolder.active then return end
    local width = Minimap:GetWidth()
    if not width or width <= 0 then return end
    local db = BetterBlizzFramesDB
    local scale = math.max(db.minimapClassicMailScale or 1, 1)
    local angle = math.rad(db.minimapClassicMailAngle or MAIL_ANGLE)
    local radius = width / 2 + MAIL_RIM_GAP
    local x = radius * math.cos(angle) - MAIL_RIM_SIDE * math.sin(angle)
    local y = radius * math.sin(angle) + MAIL_RIM_SIDE * math.cos(angle)
    mail:SetScale(scale)
    mail:ClearAllPoints()
    mail:SetPoint("TOPLEFT", Minimap, "CENTER", x / scale - MAIL_ICON_X, y / scale - MAIL_ICON_Y)
end

local function DragMinimapMail()
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local effective = Minimap:GetEffectiveScale()
    local cursor = math.atan2(py / effective - my, px / effective - mx)
    local side = math.atan2(MAIL_RIM_SIDE, Minimap:GetWidth() / 2 + MAIL_RIM_GAP)
    BetterBlizzFramesDB.minimapClassicMailAngle = math.deg(cursor - side) % 360
    BBF.PlaceMinimapMail()
end

local function MailDragStart(self)
    GameTooltip_Hide()
    self:SetScript("OnUpdate", DragMinimapMail)
end

local function MailDragStop(self)
    self:SetScript("OnUpdate", nil)
end

local function SetMailArtShown(mail, classic)
    local alpha = classic and 0 or 1
    if MiniMapMailIcon then MiniMapMailIcon:SetAlpha(alpha) end
    for _, flipbook in ipairs({ mail.NewMailFlipbook, mail.MailReminderFlipbook }) do
        if classic then
            flipbook.bbfAtlas = flipbook.bbfAtlas or flipbook:GetAtlas()
            flipbook:SetTexture(nil)
        elseif flipbook.bbfAtlas then
            flipbook:SetAtlas(flipbook.bbfAtlas)
        end
    end
    mailHolder.icon:SetShown(classic)
    mailHolder.border:SetShown(classic)
end

function BBF.UpdateMinimapMail()
    local active = ClassicMailActive() and true or false
    if not mailHolder and not active then return end
    local indicators = MinimapCluster and MinimapCluster.IndicatorFrame
    local mail = indicators and indicators.MailFrame
    if not mail or not Minimap then return end
    if not mailHolder then
        mailHolder = CreateFrame("Frame", nil, Minimap)
        mailHolder:SetAllPoints(Minimap)
        mailHolder.Layout = function() end
        mailHolder.mail = mail
        mailHolder.icon = mail:CreateTexture(nil, "ARTWORK", nil, 1)
        mailHolder.icon:SetTexture(MAIL_ICON)
        mailHolder.icon:SetSize(18, 18)
        mailHolder.icon:SetPoint("CENTER", mail, "TOPLEFT", MAIL_ICON_X, MAIL_ICON_Y)
        mailHolder.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
        mailHolder.iconMask = mail:CreateMaskTexture()
        mailHolder.iconMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mailHolder.iconMask:SetAllPoints(mailHolder.icon)
        mailHolder.icon:AddMaskTexture(mailHolder.iconMask)
        mailHolder.border = mail:CreateTexture(nil, "OVERLAY")
        mailHolder.border:SetTexture(MAIL_BORDER)
        mailHolder.border:SetSize(MAIL_BORDER_SIZE, MAIL_BORDER_SIZE)
        mailHolder.border:SetPoint("TOPLEFT", mail, "TOPLEFT")
        mailHolder.basePoint = { mail:GetPoint(1) }
        mailHolder.baseWidth, mailHolder.baseHeight = mail:GetSize()
        Minimap:HookScript("OnSizeChanged", BBF.PlaceMinimapMail)
        BBF.minimapMailBorder = mailHolder.border
        if BBF.DarkmodeFrames and BetterBlizzFramesDB.darkModeUi then
            BBF.DarkmodeFrames()
        end
    end
    if mailHolder.active == active then return end
    mailHolder.active = active
    local level = (MinimapBackdrop or Minimap):GetFrameLevel() + 5
    mailHolder:SetFrameLevel(level)
    if active then
        mail:SetParent(mailHolder)
        mail.ignoreInLayout = true
        mail:SetSize(33, 33)
        mail:SetFrameLevel(level + 1)
        mail:RegisterForDrag("LeftButton")
        mail:SetScript("OnDragStart", MailDragStart)
        mail:SetScript("OnDragStop", MailDragStop)
        BBF.PlaceMinimapMail()
    else
        mail:SetParent(indicators)
        mail.ignoreInLayout = nil
        mail:RegisterForDrag()
        mail:SetScript("OnDragStart", nil)
        mail:SetScript("OnDragStop", nil)
        mail:SetScript("OnUpdate", nil)
        mail:SetScale(1)
        mail:SetSize(mailHolder.baseWidth, mailHolder.baseHeight)
        mail:ClearAllPoints()
        if mailHolder.basePoint[1] then
            mail:SetPoint(unpack(mailHolder.basePoint))
        end
    end
    SetMailArtShown(mail, active)
    indicators:Layout()
end

local OCD_BUTTON_BORDER = 48
local MINIMAP_BUTTON_BORDER = 136430
local buttonBorderCallback

local OCD_BACKGROUND_X = 5
local MINIMAP_BUTTON_BACKGROUND = 136467

local function SetButtonBackground(lib, name, button)
    local background = button and button.background
    if not background then return end
    if BetterBlizzFramesDB.playerFrameOCD then
        local texture = background:GetTexture()
        local isDefault = texture == MINIMAP_BUTTON_BACKGROUND or (type(texture) == "string" and texture:lower():find("ui%-minimap%-background"))
        if not isDefault and not background.bbfOCDPoint then return end
        local point, rel, relPoint, _, y = background:GetPoint()
        if not point then return end
        background.bbfOCDPoint = true
        background:ClearAllPoints()
        background:SetPoint(point, rel, relPoint, OCD_BACKGROUND_X, y)
    elseif background.bbfOCDPoint then
        background.bbfOCDPoint = nil
        if lib.ResetButtonBackground then
            lib:ResetButtonBackground(name)
        end
    end
end

local function SetButtonBorder(lib, name, button)
    SetButtonBackground(lib, name, button)
    local border = button and button.border
    if not border then return end
    if BetterBlizzFramesDB.playerFrameOCD then
        local texture = border:GetTexture()
        local isRing = texture == MINIMAP_BUTTON_BORDER or (type(texture) == "string" and texture:lower():find("minimap%-trackingborder"))
        if not isRing and not border.bbfOCDSize then return end
        border.bbfOCDSize = true
        border:SetSize(OCD_BUTTON_BORDER, OCD_BUTTON_BORDER)
    elseif border.bbfOCDSize then
        border.bbfOCDSize = nil
        lib:ResetButtonBorder(name)
    end
end

function BBF.UpdateMinimapButtonBorders()
    local lib = LibStub and LibStub("LibDBIcon-1.0", true)
    if not lib or not lib.objects then return end
    if not buttonBorderCallback and lib.RegisterCallback then
        buttonBorderCallback = {}
        lib.RegisterCallback(buttonBorderCallback, "LibDBIcon_IconCreated", function(_, button, name)
            SetButtonBorder(lib, name, button)
        end)
    end
    for name, button in pairs(lib.objects) do
        SetButtonBorder(lib, name, button)
    end
end

function BBF.UpdateMinimapTweaks()
    local db = BetterBlizzFramesDB
    BBF.UpdateMinimapButtonBorders()
    BBF.UpdateMinimapMail()
    if db.classicMinimap then
        if minimapTweaksApplied then
            minimapTweaksApplied = false
            local container = MinimapCluster and MinimapCluster.MinimapContainer
            if container then
                ApplyMinimapNudge(container)
            end
            ApplyTitleScale()
        end
        if BBF.UpdateClassicMinimapLayout then
            BBF.UpdateClassicMinimapLayout()
        end
        return
    end
    local active = MinimapTweaksActive()
    if not active and not minimapTweaksApplied then return end
    minimapTweaksApplied = active

    HookMinimapTweaks()

    local container = MinimapCluster and MinimapCluster.MinimapContainer
    if container then
        ApplyMinimapNudge(container)
    end
    ApplyMinimapCompass()

    if Minimap then
        Minimap:SetScale(active and (db.foreverMinimapScale or 1) or 1)
    end

    local dielFrame = MinimapCluster and MinimapCluster.DielFrame
    if dielFrame then
        dielFrame:SetShown(not active)
    end

    ApplyTitleScale()
    BBF.UpdateMinimapTitle()
end
