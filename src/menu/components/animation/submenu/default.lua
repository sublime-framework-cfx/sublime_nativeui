local animation = {
    config = {
        open = {
            w = 0  -- initial width for the open animation
        },
        close = {}
    }
}

--- Animation de déroulement de gauche à droite
function animation.open(menu, config)
    local endW = menu.defaultW
    local startX = menu.defaultX  -- Initial position
    local currentW = animation.config.open.w
    menu.w = currentW
    menu.x = startX

    local startTime = GetGameTimer()
    local duration = 175

    while currentW < endW do
        local currentTime = GetGameTimer()
        local elapsedTime = currentTime - startTime
        local percentComplete = elapsedTime / duration

        if percentComplete >= 1 then
            menu.w = endW
            menu.x = startX
            break
        end

        currentW = animation.config.open.w + percentComplete * (endW - animation.config.open.w)
        menu.w = currentW
        menu.x = (startX + (currentW / 2) - (endW / 2))

        Wait(0)
    end

    menu.playAnimation = false
    return true
end

--- Animation de repliement de droite à gauche
function animation.close(menu, config)
    local endW = 0
    local startX = menu.x
    local currentW = menu.w
    local startTime = GetGameTimer()
    local duration = 50

    while currentW > endW and menu.parent.opened do
        local currentTime = GetGameTimer()
        local elapsedTime = currentTime - startTime
        local percentComplete = elapsedTime / duration
        if percentComplete >= 1.5 then
            break
        end

        currentW = menu.defaultW - percentComplete * (menu.w - endW)
        menu.w = currentW
        menu.x = (startX + (currentW / 2) - (menu.defaultW / 2))
        Wait(0)
    end
    
    menu.playAnimation = false
    return true
end

return animation
