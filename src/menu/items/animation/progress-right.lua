--- Progress from 'left' to 'right'
--- @param menu Menu
--- @param options table
--- @param config table
--- @param data table
--- @param rect DrawProps.rect<{rect: fun(x: float, y: float, w: float, h: float, r: integer, g: integer, b: integer, a: integer): void}>
return function(self, menu, options, config, data, rect)
    local y <const> = data.y + (data.h * .5) - (data.h * .1) * .5
    local h <const> = data.h * .1
    local startX <const> = data.x - (data.w * .5)
    local w, newX = 0, startX

    while (self.state == menu.index) and (menu.opened) do
        if w >= data.w then
            break
        end

        rect(
            newX,
            y,
            w,
            h,
            options?.color?[1] or 255,
            options?.color?[2] or 255,
            options?.color?[3] or 255,
            options?.color?[4] or 150
        )

        w += (data.w * .005)
        newX += (data.w * .005) * .5

        Wait(0)
    end
end