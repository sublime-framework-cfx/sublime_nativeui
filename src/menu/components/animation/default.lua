---@experimental

--[[ that will be rework for easy config et check coords of menu later ... ]]

local animation = {
    config = {
        open = {
            y = -.4
        },
        close = {}
    }
}

function animation.open(menu, config)
    local endY = menu.defaultY
    local currentY = animation.config.open.y

    local startTime = GetGameTimer()
    local duration = 250

    while currentY < endY do
        local currentTime = GetGameTimer()
        local elapsedTime = currentTime - startTime
        local percentComplete = elapsedTime / duration

        if percentComplete >= 1 then
            menu:SetPosition(nil, endY)
            break
        end

        currentY = animation.config.open.y + percentComplete * (endY + math.abs(animation.config.open.y))
        menu:SetPosition(nil, currentY)

        Wait(0)
    end

    menu.playAnimation = false
    return true
end

function animation.close(menu, config)
    local endY = -.5
    local currentY = menu.y
    local startTime = GetGameTimer()
    local duration = 250

    while currentY > endY do
        local currentTime = GetGameTimer()
        local elapsedTime = currentTime - startTime
        local percentComplete = elapsedTime / duration

        if percentComplete >= 1 then
            menu:SetPosition(nil, endY)
            break
        end

        currentY = menu.y - percentComplete * (menu.y + 0.5)
        menu:SetPosition(nil, currentY)
        Wait(0)
    end

    menu.playAnimation = false
    return true
end

return animation