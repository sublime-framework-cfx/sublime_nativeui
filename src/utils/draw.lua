local draw = {}

----------------------------------------------------
-- draw.text
----------------------------------------------------

---@param str string
---@return table[]
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

---@param str string
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

---@param text string
---@param x float
---@param y float
---@param font integer
---@param scale float
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@param alignment string<'right' | 'center'> | number<1 | 2>
---@param dropShadow boolean
---@param outline boolean
---@param wordWrap number
---@return string, float, float
local function _Text(text, x, y, font, scale, r, g, b, a, alignment, dropShadow, outline, wordWrap)
    local _text <const>, _x <const>, _y <const> = text, x, y
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
            SetTextWrap(_x - (wordWrap / 2), _x + (wordWrap / 2))
        elseif alignment == 2 or alignment == "right" then
            SetTextWrap(0, _x)
        else
            SetTextWrap(_x, _x + wordWrap)
        end
    else
        if alignment == 2 or alignment == "right" then
            SetTextWrap(0, _x)
        end
    end
    return _text, _x, _y
end

---@param str string
---@param font integer
---@param scale float
---@return number
function draw.measureStringWidth(str, font, scale)
    BeginTextCommandGetWidth("CELL_EMAIL_BCON")
    AddTextComponentSubstringPlayerName(str)
    SetTextFont(font or 0)
    SetTextScale(1.0, scale or .0)
    return EndTextCommandGetWidth(true)
end

---@param text string
---@param x float
---@param y float
---@param font integer
---@param scale float
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@param alignment string<'right' | 'center'> | number<1 | 2>
---@param dropShadow boolean
---@param outline boolean
---@param wordWrap number
function draw.text(text, x, y, font, scale, r, g, b, a, alignment, dropShadow, outline, wordWrap)
    local _text <const>, _x <const>, _y <const> = _Text(text, x, y, font, scale, r, g, b, a, alignment, dropShadow, outline, wordWrap)
    BeginTextCommandDisplayText("CELL_EMAIL_BCON")
    AddText(_text)
    EndTextCommandDisplayText(_x, _y)
end

----------------------------------------------------
-- draw.rect
----------------------------------------------------

---@param x float
---@param y float
---@param w float
---@param h float
---@param r integer
---@param g integer
---@param b integer
---@param a integer
function draw.rect(x, y, w, h, r, g, b, a)
    DrawRect(x or .0, y or .0, w or .0, h or .0, r or 0, g or 0, b or 0, a or 100)
end


----------------------------------------------------
-- draw.scaleformMovie
----------------------------------------------------

---@param handle number
---@param x float
---@param y float
---@param w float
---@param h float
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@param unk? integer
function draw.scaleformMovie(handle, x, y, w, h, r, g, b, a, unk)
    DrawScaleformMovie(handle, x, y, w or 1.0, h or 1.0, r or 255, g or 255, b or 255, a or 255, unk or 0)
end

return draw