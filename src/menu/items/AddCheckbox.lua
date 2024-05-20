local config <const> = require '@sublime_nativeui.config.menu.button'
---@type DrawProps
local draw <const> = require '@sublime_nativeui.src.utils.draw'
---@param self Items
---@param menu Menu
---@param label string
---@param description string
---@param checked boolean
---@param options table
---@param actions table
---@param nextMenu table | string
---@return table
return function(self, label, description, checked, options, actions, nextMenu)
    local menu <const> = self.menu
    menu.counter += 1
    self.id = menu.counter
    self.actions = actions or self
    self.label = label
    self.description = description
    self.options = options
    self.canInteract = options?.canInteract == nil and true or options.canInteract
    self.type = 'button'

    if (menu.counter < menu.pagination.min) or (menu.counter > menu.pagination.max ) then
        self:NoVisible()
    else
        local y <const> = menu:GetY(config.h)
        local posY <const> = y + menu.offsetY
        if self:IsActive(posY) then
            self.y = posY

            draw.sprite(
                'commonmenu',
                'gradient_nav',
                menu.x,
                self.y,
                menu.w,
                config.h,
                .0,
                options?.color?.highlight?[1] or 200,
                options?.color?.highlight?[2] or 200,
                options?.color?.highlight?[3] or 200,
                options?.color?.highlight?[4] or 150
            )

            menu.currentDescription = description
            if IsControlJustPressed(0, 191) and self.canInteract then -- ENTER only
                checked = not checked
                
                if self?.actions.onSelected then
                    self:OnSelected(self.actions.onSelected, checked)
                end

                if not checked then
                    if self.actions?.onUnChecked then
                        self:OnChecked(self.actions.onUnChecked, checked)
                    end
                else
                    if self.actions?.onChecked then
                        self:OnChecked(self.actions.onChecked, checked)
                    end
                end

                if nextMenu then
                    menu:NextMenu(nextMenu, posY, config.h, menu.x + menu.w)
                end
            end
        else
            draw.sprite(
                'commonmenu',
                'gradient_nav',
                menu.x,
                y + menu.offsetY,
                menu.w,
                config.h,
                .0,
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

        local posX <const> = menu.x + menu.w / 2 - .0125
        if checked then
            draw.sprite(
                'commonmenu',
                'shop_box_tickb',
                posX,
                y + menu.offsetY,
                .025,
                .025,
                .0,
                255,
                255,
                255,
                255
            )
        else
            draw.sprite(
                'commonmenu',
                'shop_box_blankb',
                posX,
                y + menu.offsetY,
                .025,
                .025,
                .0,
                255,
                255,
                255,
                255
            )
        end

        local offetX = draw.measureStringWidth(label, 0, 0.25)/6

        if self.options?.rightlabel then
            draw.text(
                self.options.rightlabel,
                posX - (offetX or 0) - .005,
                y + menu.offsetY - .0125,
                0,
                0.25,
                options?.color?.text?[1] or 255,
                options?.color?.text?[2] or 255,
                options?.color?.text?[3] or 255,
                options?.color?.text?[4] or 255,
                2, -- alignment right
                options?.dropShadow or false,
                false
            )
        end

        menu.offsetY += (config.h + menu.padding)
    end

    self.stock[self.id] = self.type
    return self
end