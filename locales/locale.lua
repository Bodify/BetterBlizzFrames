-- Locale system for BetterBlizzFrames
-- Initializes the localization table and fallback system

local addonName = "BetterBlizzFrames"

-- Initialize locale table
BBF.L = BBF.L or {}

-- Get the client's locale
local locale = GetLocale()

-- Store the current locale
BBF.locale = locale

-- Create metatable for fallback to English (enUS)
local L_mt = {
	__index = function(t, key)
		-- If key doesn't exist in current locale, try to return the key itself as fallback
		-- This will show the key name if translation is missing
		return key
	end
}

setmetatable(BBF.L, L_mt)

-- Create global L alias for convenience
L = BBF.L
