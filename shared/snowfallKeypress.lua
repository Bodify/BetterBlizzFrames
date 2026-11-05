-- Snowfall Keypress is based on jButtonFlash by woldner which is based on SnowfallKeyPress. Credit goes to that work.

local keypressOn, keypressHooked, keypressOverlay, keypressAnim

local function CreateKeypressFlash()
    keypressOverlay = CreateFrame("Frame")
    keypressOverlay:SetFrameStrata("TOOLTIP")

    local texture = keypressOverlay:CreateTexture()
    texture:SetTexture("Interface\\Cooldown\\star4")
    texture:SetAlpha(0)
    texture:SetAllPoints(keypressOverlay)
    texture:SetBlendMode("ADD")
    texture:SetDrawLayer("OVERLAY", 7)

    keypressAnim = texture:CreateAnimationGroup()

    local alpha = keypressAnim:CreateAnimation("Alpha")
    alpha:SetFromAlpha(0)
    alpha:SetToAlpha(1)
    alpha:SetDuration(0)
    alpha:SetOrder(1)

    local grow = keypressAnim:CreateAnimation("Scale")
    grow:SetScale(1.5, 1.5)
    grow:SetDuration(0)
    grow:SetOrder(1)

    local shrink = keypressAnim:CreateAnimation("Scale")
    shrink:SetScale(0, 0)
    shrink:SetDuration(0.3)
    shrink:SetOrder(2)

    local rotation = keypressAnim:CreateAnimation("Rotation")
    rotation:SetDegrees(90)
    rotation:SetDuration(0.3)
    rotation:SetOrder(2)
end

local function FlashButton(button)
    if not keypressOn or not button or not button:IsVisible() then return end
    keypressOverlay:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
    keypressOverlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
    keypressAnim:Stop()
    keypressAnim:Play()
end

local function OnAddonButtonClick(button, _, down)
    if down then FlashButton(button) end
end

local function OnAddonButtonState(button, state)
    if state == "PUSHED" then FlashButton(button) end
end

local function HookAddonButtons(prefix, count)
    for i = 1, count do
        local button = _G[prefix .. i]
        if button and not button.bbfKeypressHooked then
            button.bbfKeypressHooked = true
            button:HookScript("OnClick", OnAddonButtonClick)
            if button.SetButtonStateBase then
                hooksecurefunc(button, "SetButtonStateBase", OnAddonButtonState)
            end
        end
    end
end

function BBF.SnowfallKeypress()
    keypressOn = BetterBlizzFramesDB.snowfallKeypress and true or false
    if not keypressOn then return end

    if not keypressHooked then
        keypressHooked = true
        CreateKeypressFlash()
        hooksecurefunc("ActionButtonDown", function(id)
            FlashButton(GetActionButtonForID(id))
        end)
        hooksecurefunc("MultiActionButtonDown", function(bar, id)
            FlashButton(_G[bar .. "Button" .. id])
        end)
    end

    HookAddonButtons("BT4Button", 180)
    HookAddonButtons("DominosActionButton", 168)
end
