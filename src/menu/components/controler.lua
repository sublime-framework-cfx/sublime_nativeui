local step, time, pressed = 0, GetGameTimer(), false

local function GoUp(menu)
    local newIndex <const> = menu.index - 1

    if newIndex < 1 then
        menu.index = menu.counter
        
        menu.pagination.min = menu.counter - menu.maxVisibleItems + 1
        menu.pagination.max = menu.counter
    else
        if menu.index == menu.pagination.min then
            menu.pagination.min -= 1
            menu.pagination.max = menu.pagination.min + menu.maxVisibleItems - 1
        end
        menu.index = newIndex
    end

    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    time, pressed = GetGameTimer(), true
    step += 1
end

local function GoDown(menu)
    local newIndex <const> = menu.index + 1

    if newIndex > menu.counter then
        menu.index = 1
        menu.pagination.min = 1
        menu.pagination.max = menu.maxVisibleItems
    else
        if menu.index == menu.pagination.max then
            menu.pagination.min += 1
            menu.pagination.max = menu.pagination.min + menu.maxVisibleItems - 1
        end

        menu.index = newIndex
    end

    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    time, pressed = GetGameTimer(), true
    step += 1
end

local function Controler(menu)
    pressed = false

    if menu.closable and IsControlJustPressed(0, 194) then -- BACKSPACE
        menu:Close('GoBack')
    end

    if (step < 3 and (GetGameTimer() - time > 150) or (step < 6 and step >= 3 and GetGameTimer() - time > 75)) or (step >= 6 and GetGameTimer() - time > 45) then
        if IsControlPressed(0, 172) then -- UP
            GoUp(menu)
        elseif IsControlPressed(0, 173) then -- DOWN    
            GoDown(menu)
        end
    else
        pressed = true
    end

    --print(step, 'step', time, GetGameTimer() - time, 'time', pressed, 'pressed')
    if not pressed then step = 0 end
end

return Controler, GoUp, GoDown