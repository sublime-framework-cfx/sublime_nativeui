local step, time, pressed, Controler = 0, GetGameTimer(), false, {}

function Controler.GoUp(menu)
    menu.lastPressed = 'up'
    local newIndex = menu.index - 1

    while newIndex > 0 do
        local itemSkipable = menu.Items.stock[newIndex] == 'separator' or menu.Items.stock[newIndex] == 'line'
        if not itemSkipable then
            break
        end
        newIndex -= 1
    end

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

function Controler.GoDown(menu)
    menu.lastPressed = 'down'
    local newIndex = menu.index + 1
    local skipped = false

    if newIndex > menu.counter then
        newIndex = 1
    end

    while (newIndex <= menu.counter)  do
        local itemSkipable = menu.Items.stock[newIndex] == 'separator' or menu.Items.stock[newIndex] == 'line'
        if not itemSkipable then
            break
        end
        skipped = true
        newIndex += 1
    end

    if newIndex > menu.counter then
        menu.index = 1
        menu.pagination.min = 1
        menu.pagination.max = menu.maxVisibleItems
    else
        if menu.index == menu.pagination.max then
            if not skipped then
                menu.pagination.min += 1
                menu.pagination.max = menu.pagination.min + menu.maxVisibleItems - 1
            end
        end

        menu.index = newIndex
    end

    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    time, pressed = GetGameTimer(), true
    step += 1
end

function Controler.Main(menu)
    pressed = false

    if not menu.freezeControl then
        if menu.closable and IsControlJustPressed(0, 194) then -- BACKSPACE
            menu:Close('GoBack')
        end

        if (step < 3 and (GetGameTimer() - time > 150) or (step < 6 and step >= 3 and GetGameTimer() - time > 75)) or (step >= 6 and GetGameTimer() - time > 45) then
            if IsControlPressed(0, 172) then -- UP
                Controler.GoUp(menu)
            elseif IsControlPressed(0, 173) then -- DOWN    
                Controler.GoDown(menu)
            else
                if menu.index == 1 then
                    if (menu.Items.stock?[menu.index] == 'separator') or (menu.Items.stock?[menu.index] == 'line') then
                        Controler.GoDown(menu)
                    end
                end
            end
        else
            pressed = true
        end

        
        if not pressed then step = 0 end
    end
end

return Controler