BBF.MonkStaggerBarHandler = MonkStaggerBar

local frame = CreateFrame("Frame");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");

local function InitializeStaggerTracking()
    local meetsRequirements = false;

    local _, class = UnitClass("player");
    meetsRequirements = class == "MONK" and C_SpecializationInfo.GetSpecialization() == SPEC_MONK_BREWMASTER;

    if not meetsRequirements then return true end
    if not MonkStaggerBar then return false end

    if BetterBlizzFramesDB.useCustomStaggerBar and BBF.BBFMonkStaggerBar then
        BBF.MonkStaggerBarHandler = BBF.BBFMonkStaggerBar;
        MonkStaggerBar:Hide();
        BBF.MonkStaggerBarHandler:Show();
    else
        BBF.MonkStaggerBarHandler = MonkStaggerBar;
    end

    return true;
end

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "BetterBlizzFrames" then
        if InitializeStaggerTracking() then
            self:UnregisterEvent("ADDON_LOADED");
        end
    end
end)
