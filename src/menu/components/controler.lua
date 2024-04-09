local step, time, pressed = 0, GetGameTimer(), false

local function GoUp(menu)
    if IsControlPressed(0, 172) then -- UP
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
end

local function GoDown(menu)
    if IsControlPressed(0, 173) then -- DOWN      
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
end

local function Controler(menu)
    pressed = false

    if menu.closable and IsControlJustPressed(0, 177) then -- BACKSPACE
        menu:Close()
    end

    if (step < 3 and (GetGameTimer() - time > 450) or (step < 6 and GetGameTimer() - time > 350)) or (GetGameTimer() - time > 50) then
        GoUp(menu)
        GoDown(menu)
    else
        pressed = true
    end

    --print(step, 'step', time, GetGameTimer() - time, 'time', pressed, 'pressed')
    if not pressed then step = 0 end
end

return Controler