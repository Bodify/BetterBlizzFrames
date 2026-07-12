local function InitializeStaggerTracking()
    local isBrewmaster = false;

    local _, class = UnitClass("player");
    isBrewmaster = class == "MONK" and C_SpecializationInfo.GetSpecialization() == SPEC_MONK_BREWMASTER;

    if not isBrewmaster then return true end
    if not MonkStaggerBar then return false end

--    if BetterBlizzFramesDB.useCustomStaggerBar and BBF.BBFMonkStaggerBar then
    if true then
        BBF.MonkStaggerBarHandler = BBFMonkStaggerBar;
        MonkStaggerBar:Hide();
        MonkStaggerBar:SetAlpha(0);
    else
        BBF.MonkStaggerBarHandler = MonkStaggerBar;
        BBFMonkStaggerBar:Hide();
        BBFMonkStaggerBar:SetAlpha(0);
    end

    BBF.MonkStaggerBarHandler:Show();
    return true;
end

local loadFrame = CreateFrame("Frame");
loadFrame:RegisterEvent("ADDON_LOADED");
loadFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
loadFrame:RegisterEvent("PLAYER_REGEN_ENABLED");

loadFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "BetterBlizzFrames" then
        if InitializeStaggerTracking() then
            self:UnregisterEvent("ADDON_LOADED");
        end
    end
end)
