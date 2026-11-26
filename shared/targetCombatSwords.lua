local eventFrame
local swordFrames = {}

local function SetCovered(region, covered)
    if region.bbfUnderAttackIcon == covered then return end
    region.bbfUnderAttackIcon = covered
    region.bbfSwordSetting = true
    region:SetAlpha(covered and 0 or (region.bbfSwordAlpha or 1))
    region.bbfSwordSetting = nil
end

local function HookAlpha(region)
    region.bbfSwordAlpha = region:GetAlpha()
    hooksecurefunc(region, "SetAlpha", function(self, alpha)
        if self.bbfSwordSetting then return end
        self.bbfSwordAlpha = alpha
        if self.bbfUnderAttackIcon and alpha ~= 0 then
            self.bbfSwordSetting = true
            self:SetAlpha(0)
            self.bbfSwordSetting = nil
        end
    end)
end

local function UpdateSwords(frame)
    local swords = frame.bbfCombatSwords
    if not swords then return end
    local content = frame.TargetFrameContent
    local levelText = content.TargetFrameContentMain.LevelText
    local highLevel = content.TargetFrameContentContextual.HighLevelTexture
    local dx, dy = BBF.LevelTweakOffset("target")
    swords:ClearAllPoints()
    swords:SetPoint("CENTER", frame, "BOTTOMRIGHT", BBF.ClassicTargetLevelX() - 1 + dx, 26.5 + dy)
    local covered = BetterBlizzFramesDB.classicTargetCombatSwords and UnitAffectingCombat(frame.unit) and true or false
    swords:SetShown(covered)
    SetCovered(levelText, covered)
    SetCovered(highLevel, covered)
end

local function UpdateAll()
    for _, frame in ipairs(swordFrames) do
        UpdateSwords(frame)
    end
end

local function SetupFrame(frame)
    if frame.bbfCombatSwords then return end
    local attackIcon = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.AttackIcon
    local swords = frame.ClassicFrame:CreateTexture(nil, "OVERLAY", nil, 7)
    swords:SetSize(attackIcon:GetSize())
    swords:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
    swords:SetTexCoord(1.0, 0.5, 0, 0.484375)
    frame.bbfCombatSwords = swords
    local content = frame.TargetFrameContent
    HookAlpha(content.TargetFrameContentMain.LevelText)
    HookAlpha(content.TargetFrameContentContextual.HighLevelTexture)
    tinsert(swordFrames, frame)
end

function BBF.ClassicTargetCombatSwords()
    if not BBF.classicFramesBuilt then return end
    if BetterBlizzFramesDB.classicTargetCombatSwords then
        SetupFrame(TargetFrame)
        if FocusFrame then
            SetupFrame(FocusFrame)
        end
        if not eventFrame then
            eventFrame = CreateFrame("Frame")
            eventFrame:SetScript("OnEvent", UpdateAll)
        end
        eventFrame:RegisterUnitEvent("UNIT_FLAGS", "target", "focus")
        eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        if FocusFrame then
            eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        end
    elseif eventFrame then
        eventFrame:UnregisterAllEvents()
    end
    UpdateAll()
end
