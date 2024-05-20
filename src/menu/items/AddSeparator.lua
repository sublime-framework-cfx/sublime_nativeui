local config <const> = require '@sublime_nativeui.config.menu.button'
---@type DrawProps
local draw <const> = require '@sublime_nativeui.src.utils.draw'
---@param self Items
---@param menu Menu
---@param label string
---@param description string
---@param options table
---@param actions table
---@param nextMenu table | string
---@return integer buttonId
return function(self, label, options)
    local menu <const> = self.menu
    menu.counter += 1
    self.id = menu.counter
    self.label = label
    self.options = options
    self.type = 'separator'

    if (menu.counter < menu.pagination.min) or (menu.counter > menu.pagination.max ) then
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

        if label then
            local size <const> = draw.measureStringWidth(label, 0, 0.25)
            local x <const> = menu.x - menu.w / 2 + (menu.w - size) / 2

            draw.text(
                '↓ '..label..' ↓',
                x,
                self.y - .0125,
                0,
                0.25,
                options?.color?.text?[1] or 255,
                options?.color?.text?[2] or 255,
                options?.color?.text?[3] or 255,
                options?.color?.text?[4] or 255,
                0, -- alignment left
                options?.dropShadow or false,
                false
            )
        end

        menu.offsetY += (config.h + menu.padding)
    end

    self.stock[self.id] = self.type
    return self
end