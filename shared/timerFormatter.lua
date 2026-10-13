do
    local formatters = {}

    local function ColorHex(c)
        local function byte(v)
            return math.floor(math.max(0, math.min(1, v or 1)) * 255 + 0.5)
        end
        return string.format("%02x%02x%02x", byte(c[1]), byte(c[2]), byte(c[3]))
    end

    local function RoundUp()
        local rounding = Enum.NumericRuleFormatRounding
        return rounding and rounding.Up or 1
    end

    local function Breakpoint(threshold, format, step, div)
        return {
            threshold = threshold,
            format = format,
            step = not div and step or nil,
            rounding = RoundUp(),
            components = div and { { div = div, step = step, rounding = RoundUp() } } or nil,
        }
    end

    local units = {
        { threshold = 60, format = "%dm", div = 60 },
        { threshold = 3600, format = "%dh", div = 3600 },
        { threshold = 86400, format = "%dd", div = 86400 },
    }

    function BBF.GetTimerFormatter(lowColor, lowThreshold, milliseconds, hideLong, baseColor, highThreshold, highColor)
        lowThreshold = math.min(math.max(lowThreshold or 0, 0), 59)
        if highThreshold and (not highColor or highThreshold <= lowThreshold) then
            highThreshold = nil
        end
        local key = (lowColor and ColorHex(lowColor) or "-") .. ":" .. lowThreshold .. ":" .. (milliseconds and 1 or 0) .. ":" .. (hideLong and 1 or 0)
        if baseColor then
            key = key .. ":" .. ColorHex(baseColor)
        end
        if highThreshold then
            key = key .. ":" .. highThreshold .. ":" .. ColorHex(highColor)
        end
        local formatter = formatters[key]
        if formatter then return formatter, key end

        local function Wrap(format, color)
            if not color then return format end
            return "|cff" .. ColorHex(color) .. format .. "|r"
        end

        local function ColorAt(threshold)
            if highThreshold and threshold >= highThreshold then return highColor end
            return baseColor
        end

        local function UnitAt(threshold)
            local unit
            for _, u in ipairs(units) do
                if threshold >= u.threshold then unit = u end
            end
            return unit
        end

        local starts = { lowThreshold, 60, 3600, 86400 }
        if highThreshold then
            starts[#starts + 1] = highThreshold
        end
        table.sort(starts)

        local breakpoints = {}
        if lowThreshold > 0 then
            breakpoints[#breakpoints + 1] = Breakpoint(0, Wrap(milliseconds and "%.1f" or "%d", lowColor), milliseconds and 0.1 or 1)
        end
        local last
        for _, threshold in ipairs(starts) do
            if threshold ~= last then
                last = threshold
                local unit = UnitAt(threshold)
                if hideLong and unit then
                    breakpoints[#breakpoints + 1] = { threshold = 60, format = " " }
                    break
                end
                local color = ColorAt(threshold)
                if unit then
                    breakpoints[#breakpoints + 1] = Breakpoint(threshold, Wrap(unit.format, color), 1, unit.div)
                else
                    breakpoints[#breakpoints + 1] = Breakpoint(threshold, Wrap("%d", color), 1)
                end
            end
        end

        formatter = C_StringUtil.CreateNumericRuleFormatter()
        formatter:SetBreakpoints(breakpoints)
        formatters[key] = formatter
        return formatter, key
    end
end
