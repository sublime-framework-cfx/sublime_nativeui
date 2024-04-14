local MATH = {}

function MATH.Round(num, numDecimalPlaces)
    return tonumber(string.format("%."..(numDecimalPlaces or 0).."f", num))
end

return MATH