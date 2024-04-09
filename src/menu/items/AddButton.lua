local config <const> = require '@sublime_nativeui.config.menu.button'

---@param self Items
---@param menu Menu
---@param label string
---@param description string
---@param options table
---@param actions table
---@param nextMenu table | string
---@return integer buttonId
return function(self, menu, label, description, options, actions, nextMenu)
    menu.counter += 1
    self.id = menu.counter
    self.actions = actions or self.actions

    if (menu.counter < menu.pagination.min) or (menu.counter > menu.pagination.max ) then
        if self.actions.onExit then
            self:IsLastActive(menu) 
        end
    else
        local y <const> = menu:GetY(config.h)
        if self:IsActive(menu) then
            DrawRect(menu.x, y + menu.offsetY, menu.w, config.h, 255, 255, 255, 255)
            menu.currentDescription = description
            if IsControlJustPressed(0, 18) then
                if self.actions.onSelected then
                    self.actions.onSelected(self, menu)
                    PlaySoundFrontend(-1, "SELECT", "HUD_LIQUOR_STORE_SOUNDSET", true)
                end

                if nextMenu then
                    menu:GoTo(nextMenu)
                end
            end
        else
            DrawRect(menu.x, y + menu.offsetY, menu.w, config.h, 0, 0, 0, 120)
            if self.actions.onExit then
                self:IsLastActive(menu) 
            end
        end

        menu.offsetY += (config.h + menu.padding)
    end
    return self.id
end