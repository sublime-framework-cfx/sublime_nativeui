--- Progress from 'left' and 'right' to 'center'
--- @param menu Menu
--- @param options table
--- @param config table
--- @param data table
--- @param rect DrawProps.rect<{rect: fun(x: float, y: float, w: float, h: float, r: integer, g: integer, b: integer, a: integer): void}>
return function(self, menu, options, config, data, sprite)
    local y <const> = data.y + (data.h * .5) - (data.h * .1) * .5
    local h <const> = data.h * .1

    local startXleft <const> = data.x - (data.w * .5)
    local startXright <const> = data.x + (data.w * .5)
    local w, newXleft, newXright = 0, startXleft, startXright

    while (self.state == menu.index) and (menu.opened) and not menu.playAnimation do
        if w >= (data.w * .5) then
            break
        end

        sprite(
            'commonmenu',
            'gradient_bgd',
            newXleft,
            y,
            w,
            h,
            .0,
            options?.color?[1] or 255,
            options?.color?[2] or 255,
            options?.color?[3] or 255,
            options?.color?[4] or 150
        )

        sprite(
            'commonmenu',
            'gradient_bgd',
            newXright,
            y,
            w,
            h,
            .0,
            options?.color?[1] or 255,
            options?.color?[2] or 255,
            options?.color?[3] or 255,
            options?.color?[4] or 150
        )

        w += (data.w * .005)
        newXleft += (data.w * .005) * .5
        newXright -= (data.w * .005) * .5

        Wait(0)
    end

    return true
end