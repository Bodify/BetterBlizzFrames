BBF_ForeverRogueComboPointMixin = {}

function BBF_ForeverRogueComboPointMixin:Setup()
    self.isFull = nil
    self.isCharged = nil
    self:ResetVisuals()
    self:Show()
end

function BBF_ForeverRogueComboPointMixin:Update(isFull, isCharged)
    if self.isFull == isFull and self.isCharged == isCharged then
        return
    end

    local wasFull = self.isFull ~= nil and self.isFull or false
    local wasCharged = self.isCharged ~= nil and self.isCharged or false
    self.isFull = isFull
    self.isCharged = isCharged

    self:ResetVisuals()

    local transitionAnim = BBF_ForeverRogueComboPointTransitions.GetTransitionAnim(wasCharged, wasFull, isCharged, isFull)
    if transitionAnim then
        self[transitionAnim]:Restart()
    end
end

function BBF_ForeverRogueComboPointMixin:ResetVisuals()
    for _, transitionAnim in ipairs(self.transitionAnims) do
        transitionAnim:Stop()
    end

    for _, fxTexture in ipairs(self.fxTextures) do
        fxTexture:SetAlpha(0)
    end
end

BBF_ForeverRogueComboPointTransitions = {}

function BBF_ForeverRogueComboPointTransitions.Init()
    local uncharged, charged = false, true
    local empty, full = false, true
    BBF_ForeverRogueComboPointTransitions.transitions = {
        { from = {uncharged, empty}, to = {uncharged, empty}, anim = "unchargedEmpty" },

        { from = {uncharged, empty}, to = {uncharged, full}, anim = "unchargedEmptyToUnchargedFull" },
        { from = {uncharged, empty}, to = {charged, full}, anim = "unchargedEmptyToChargedFull" },
        { from = {uncharged, empty}, to = {charged, empty}, anim = "unchargedEmptyToChargedEmpty" },

        { from = {charged, empty}, to = {charged, full}, anim = "chargedEmptyToChargedFull" },
        { from = {charged, empty}, to = {uncharged, full}, anim = "chargedEmptyToUnchargedFull" },
        { from = {charged, empty}, to = {uncharged, empty}, anim = "chargedEmptyToUnchargedEmpty" },

        { from = {uncharged, full}, to = {uncharged, empty}, anim = "unchargedFullToUnchargedEmpty" },
        { from = {uncharged, full}, to = {charged, full}, anim = "unchargedFullToChargedFull" },
        { from = {uncharged, full}, to = {charged, empty}, anim = "unchargedFullToChargedEmpty" },

        { from = {charged, full}, to = {charged, empty}, anim = "chargedFullToChargedEmpty" },
        { from = {charged, full}, to = {uncharged, empty}, anim = "chargedFullToUnchargedEmpty" },
        { from = {charged, full}, to = {uncharged, full}, anim = "chargedFullToUnchargedFull" },
    }
end

function BBF_ForeverRogueComboPointTransitions.GetTransitionAnim(fromIsCharged, fromIsFull, toIsCharged, toIsFull)
    if not BBF_ForeverRogueComboPointTransitions.transitions then
        BBF_ForeverRogueComboPointTransitions.Init()
    end

    for _, transition in ipairs(BBF_ForeverRogueComboPointTransitions.transitions) do
        local from, to = transition.from, transition.to
        if from[1] == fromIsCharged and from[2] == fromIsFull and to[1] == toIsCharged and to[2] == toIsFull then
            return transition.anim
        end
    end
    return nil
end

BBF_ForeverDruidComboPointMixin = {}

function BBF_ForeverDruidComboPointMixin:Setup()
    self.isActive = nil
    self:ResetVisuals()
    self:Show()
end

function BBF_ForeverDruidComboPointMixin:SetActive(isActive)
    if self.isActive == isActive then
        return
    end

    self.isActive = isActive

    self:ResetVisuals()

    if self.isActive then
        self.FB_Slash:Show()
        self.activateAnim:Restart()
    else
        self.deactivateAnim:Restart()
    end
end

function BBF_ForeverDruidComboPointMixin:ResetVisuals()
    self.activateAnim:Stop()
    self.deactivateAnim:Stop()

    self.FB_Slash:Hide()

    for _, fxTexture in ipairs(self.fxTextures) do
        fxTexture:SetAlpha(0)
    end
end
