local config <const> = require '@sublime_nativeui.config.menu.button'
---@type DrawProps
local draw <const> = require '@sublime_nativeui.src.utils.draw'
---@param self Items
---@param styles table
return function(self, options)
    ---@todo
    local menu <const> = self.menu
    menu.counter += 1
    self.id = menu.counter
    self.options = options
    self.type = 'line'

    if (menu.counter < menu.pagination.min) or (menu.counter > menu.pagination.max) then
        self:NoVisible()
    else
        local y <const> = menu:GetY(config.h)
        self.y = y + menu.offsetY

        draw.sprite(
            'commonmenu',
            'gradient_nav',
            menu.x,
            self.y,
            menu.w,
            config.h,
            .0,
            options?.color?.background?[1] or 0,
            options?.color?.background?[2] or 0,
            options?.color?.background?[3] or 0,
            options?.color?.background?[4] or 120
        )

        local rw <const> = menu.w * 0.70  
        local rh <const> = config.h * 0.075
        local ry <const> = self.y - rh / 2

        draw.sprite(
            'commonmenu',
            'gradient_nav',
            menu.x,
            ry,
            rw,
            rh,
            .0,
            options?.color?.line?[1] or 255,
            options?.color?.line?[2] or 255,
            options?.color?.line?[3] or 255,
            options?.color?.line?[4] or 255
        )

        menu.offsetY += (config.h + menu.padding)
    end

    self.stock[self.id] = self.type
    return self
end
