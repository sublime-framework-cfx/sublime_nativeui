local draw = {}

----------------------------------------------------
-- draw.text
----------------------------------------------------

local function StringToArray(str)
    local charCount <const>, strings = #str, {}
    local strCount <const> = math.ceil(charCount / 99)

    for i = 1, strCount do
        local start <const> = (i - 1) * 99 + 1
        local clamp <const> = math.clamp(#string.sub(str, start), 0, 99)
        local finish <const> = ((i ~= 1) and (start - 1) or 0) + clamp

        strings[i] = str:sub(start, finish)
    end

    return strings
end

local function AddText(str)
    local str <const> = tostring(str)
    local charCount <const> = #str

    if charCount < 100 then
        AddTextComponentSubstringPlayerName(str)
    else
        local strings <const> = StringToArray(str)
        for i = 1, #strings do
            AddTextComponentSubstringPlayerName(strings[i])
        end
    end
end

local function _Text(text, x, y, font, scale, r, g, b, a, alignment, dropShadow, outline, wordWrap)
    local Text <const>, X <const>, Y <const> = text, x, y
    SetTextFont(font or 0)
    SetTextScale(1.0, scale or 0)
    SetTextColour(r or 255, g or 255, b or 255, a or 255)
    if dropShadow then
        SetTextDropShadow()
    end
    if outline then
        SetTextOutline()
    end
    if alignment ~= nil then
        if alignment == 1 or alignment == "center" or alignment == "centre" then
            SetTextCentre(true)
        elseif alignment == 2 or alignment == "right" then
            SetTextRightJustify(true)
        end
    end
    if wordWrap and wordWrap ~= 0 then
        if alignment == 1 or alignment == "center" or alignment == "centre" then
            SetTextWrap(X - (wordWrap / 2), X + (wordWrap / 2))
        elseif alignment == 2 or alignment == "right" then
            SetTextWrap(0, X)
        else
            SetTextWrap(X, X + wordWrap)
        end
    else
        if alignment == 2 or alignment == "right" then
            SetTextWrap(0, X)
        end
    end
    return Text, X, Y
end


function draw.measureStringWidth(str, font, scale)
    BeginTextCommandGetWidth("CELL_EMAIL_BCON")
    AddTextComponentSubstringPlayerName(str)
    SetTextFont(font or 0)
    SetTextScale(1.0, scale or 0)
    return EndTextCommandGetWidth(true)
end

---@param data TextProps
function draw.text(data)
    local text <const>, x <const>, y <const> = _Text(data.text, data.x, data.y, data.font, data.scale, data.r, data.g, data.b, data.a, data.alignment, data.dropShadow, data.outline, data.wordWrap)
    BeginTextCommandDisplayText("CELL_EMAIL_BCON")
    AddText(text)
    EndTextCommandDisplayText(x, y)
end

----------------------------------------------------
-- draw.rect
----------------------------------------------------

---@param data RectProps
function draw.rect(data)
    DrawRect(data.x or .0, data.y or .0, data.w or .0, data.h or .0, data.r or 0, data.g or 0, data.b or 0, data.a or 100)
end

return draw