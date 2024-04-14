local config <const> = require '@sublime_nativeui.config.menu.button'
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

    if (menu.counter < menu.pagination.min) or (menu.counter > menu.pagination.max ) then
        if self.actions.onExit then
            self:IsLastActive() 
        end
    else
        local y <const> = menu:GetY(config.h)
        if self:IsActive(menu) then
            --DrawRect(menu.x, y + menu.offsetY, menu.w, config.h, 255, 255, 255, 255)
            draw.rect({
                x = menu.x,
                y = y + menu.offsetY,
                w = menu.w,
                h = config.h,
                r = options?.color?.highlight?[1] or 200,
                g = options?.color?.highlight?[2] or 200,
                b = options?.color?.highlight?[3] or 200,
                a = options?.color?.highlight?[4] or 150
            })

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
            if IsControlJustPressed(0, 191) then -- ENTER only
                if self?.actions.onSelected then
                    self.actions.onSelected(self)
                    PlaySoundFrontend(-1, "SELECT", "HUD_LIQUOR_STORE_SOUNDSET", true)
                end

                if nextMenu then
                    menu:NextMenu(nextMenu)
                end
            end
        else
            --DrawRect(menu.x, y + menu.offsetY, menu.w, config.h, 0, 0, 0, 120)
            draw.rect({
                x = menu.x,
                y = y + menu.offsetY,
                w = menu.w,
                h = config.h,
                r = options?.color?.background?[1] or 0,
                g = options?.color?.background?[2] or 0,
                b = options?.color?.background?[3] or 0,
                a = options?.color?.background?[4] or 120
            })
            if self?.actions.onExit then
                self:IsLastActive() 
            end
        end

        if label then
            draw.text({
                text = label,
                x = menu.x - menu.w / 2 + .005,
                y = y + menu.offsetY - .0125,
                font = 0,
                scale = 0.25,
                r = options?.color?.text?[1] or 255,
                g = options?.color?.text?[2] or 255,
                b = options?.color?.text?[3] or 255,
                a = options?.color?.text?[4] or 255,
                alignment = 0,
                dropShadow = options?.dropShadow or false,
                outline = false,
                wordWrap = 0
            })
        end

        menu.offsetY += (config.h + menu.padding)
    end

    return self
end