local config <const> = require '@sublime_nativeui.config.menu.button'
---@type DrawProps
local draw <const> = require '@sublime_nativeui.src.utils.draw'
local animation <const> = require '@sublime_nativeui.src.menu.items.animation.play'
---@param self Items
---@param menu Menu
---@param label string
---@param description string
---@param options table
---@param actions table
---@param nextMenu table | string
---@return integer buttonId
return function(self, label, description, options, actions, nextMenu)

    local menu <const> = self.menu
    --print(menu.id)
    menu.counter += 1
    self.id = menu.counter
    self.actions = actions or self.actions
    self.label = label
    self.description = description
    self.options = options
    self.canInteract = options?.canInteract == nil and true or options.canInteract

    if (menu.counter < menu.pagination.min) or (menu.counter > menu.pagination.max ) then
        self:NoVisible()
    else
        local y <const> = menu:GetY(config.h)

        if self:IsActive() then
            draw.rect(
                menu.x,
                y + menu.offsetY,
                menu.w,
                config.h,
                options?.color?.highlight?[1] or 200,
                options?.color?.highlight?[2] or 200,
                options?.color?.highlight?[3] or 200,
                options?.color?.highlight?[4] or 150
            )

            if options?.animation or config.animation.enabled then
                if (animation.state ~= self.id) and not menu.playAnimation then
                    animation:play(menu, options?.animation, config.animation, {
                        x = menu.x,
                        y = y + menu.offsetY,
                        w = menu.w,
                        h = config.h
                    }, draw.rect)
                end
            end

            menu.currentDescription = description
            if IsControlJustPressed(0, 191) and self.canInteract then -- ENTER only
                if self?.actions.onSelected then
                    self.actions.onSelected(self)
                    PlaySoundFrontend(-1, "SELECT", "HUD_LIQUOR_STORE_SOUNDSET", true)
                end

                if nextMenu then
                    menu:NextMenu(nextMenu)
                end
            end
        else
            draw.rect(
                menu.x,
                y + menu.offsetY,
                menu.w,
                config.h,
                options?.color?.background?[1] or 0,
                options?.color?.background?[2] or 0,
                options?.color?.background?[3] or 0,
                options?.color?.background?[4] or 120
            )
            if self?.actions.onExit then
                self:IsLastActive() 
            end
        end

        if label then
            draw.text(
                label,
                menu.x - menu.w / 2 + .005,
                y + menu.offsetY - .0125,
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

    return self
end