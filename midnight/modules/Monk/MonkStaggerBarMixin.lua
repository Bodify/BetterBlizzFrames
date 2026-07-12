local STAGGER_STATES = {
    RED 	= { key = "red", threshold = .70 },
    YELLOW 	= { key = "yellow", threshold = .30 },
    GREEN 	= { key = "green" }
}

BBFMonkStaggerBarMixin = {};

function BBFMonkStaggerBarMixin:Initialize()
    self.frequentUpdates = true;
    self.requiredClass = "MONK";
    self.requiredSpec = SPEC_MONK_BREWMASTER;

    self.baseMixin.Initialize(self);
end

function BBFMonkStaggerBarMixin:UpdatePower()
    self:UpdateMinMaxPower();
    self.baseMixin.UpdatePower(self);
    self:UpdateArt();
end

function BBFMonkStaggerBarMixin:UpdateArt()
    if not self.currentPower or not self.maxPower then
        self.overrideArtInfo = nil;
        self.baseMixin.UpdateArt(self);
        return;
    end

    local percent = self.maxPower > 0 and self.currentPower / self.maxPower or 0;
    local artInfo = PowerBarColor[self.powerName];
    local staggerStateKey;

    if percent >= STAGGER_STATES.RED.threshold then
        staggerStateKey = STAGGER_STATES.RED.key;
    elseif percent >= STAGGER_STATES.YELLOW.threshold then
        staggerStateKey = STAGGER_STATES.YELLOW.key;
    else
        staggerStateKey = STAGGER_STATES.GREEN.key;
    end

    if self.staggerStateKey ~= staggerStateKey then
        self.staggerStateKey = staggerStateKey;

        self.overrideArtInfo = artInfo[staggerStateKey];
        self.overrideArtInfo.spark = artInfo.spark;

        self.baseMixin.UpdateArt(self);
    end
end

function BBFMonkStaggerBarMixin:EvaluateUnit()
    local meetsRequirements = false;

    local _, class = UnitClass(self:GetUnit());
    meetsRequirements = class == self.requiredClass and C_SpecializationInfo.GetSpecialization() == self.requiredSpec;

    self:SetBarEnabled(meetsRequirements);
end

function BBFMonkStaggerBarMixin:OnBarEnabled()
    self:UpdatePower();
end

function BBFMonkStaggerBarMixin:GetCurrentPower()
    return UnitStagger(self:GetUnit()) or 0;
end

function BBFMonkStaggerBarMixin:GetCurrentMinMaxPower()
    local maxHealth = UnitHealthMax(self:GetUnit());
    return 0, (maxHealth*2);
end
