-- Progress from 'center' to 'right' and 'left'
--- @param options table
--- @param menu Menu
--- @param config table
--- @param data table
--- @param rect RectProps
return function(self, menu, options, config, data, rect)
    local endX <const> = data.x + data.w
    local y <const> = data.y + (data.h * .5) - (data.h * .1) * .5
    local h <const> = data.h * .1
    local w = 0

    while (self.state == menu.index) and (menu.opened) do
        if w >= data.w then
            break
        end

        
        rect({
            x = data.x,
            y = y,
            w = w,
            h = h,
            r = options?.color?[1] or 255,
            g = options?.color?[2] or 255,
            b = options?.color?[3] or 255,
            a = options?.color?[4] or 150
        })

        w += (data.w * .005)
        Wait(0)
    end
end