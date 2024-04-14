--- Progress from 'left' and 'right' to 'center'
--- @param options table
--- @param menu Menu
--- @param config table
--- @param data table
--- @param rect RectProps
return function(self, menu, options, config, data, rect)
    local y <const> = data.y + (data.h * .5) - (data.h * .1) * .5
    local h <const> = data.h * .1

    local startXleft <const> = data.x - (data.w * .5)
    local startXright <const> = data.x + (data.w * .5)
    local w, newXleft, newXright = 0, startXleft, startXright

    while (self.state == menu.index) and (menu.opened) and not menu.playAnimation do
        if w >= (data.w * .5) then
            break
        end

        rect({
            x = newXleft,
            y = y,
            w = w,
            h = h,
            r = options?.color?[1] or 255,
            g = options?.color?[2] or 255,
            b = options?.color?[3] or 255,
            a = options?.color?[4] or 150
        })

        rect({
            x = newXright,
            y = y,
            w = w,
            h = h,
            r = options?.color?[1] or 255,
            g = options?.color?[2] or 255,
            b = options?.color?[3] or 255,
            a = options?.color?[4] or 150
        })

        w += (data.w * .005)
        newXleft += (data.w * .005) * .5
        newXright -= (data.w * .005) * .5

        Wait(0)
    end

    Wait(0)
end