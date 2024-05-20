local config <const> = require '@sublime_nativeui.config.menu.button'
---@type DrawProps
local draw <const> = require '@sublime_nativeui.src.utils.draw'
---@param self Items
---@param menu Menu
---@param label string
---@param description string
---@param index integer
---@param list table[]
---@param options table
---@param actions table
---@param nextMenu table | string
---@return table
return function(self, label, description, index, list, options, actions, nextMenu)
    local menu <const> = self.menu
    menu.counter += 1
    self.id = menu.counter
    self.actions = actions
    self.label = label
    self.type = 'list'
    self.description = description
    self.options = options
    self.canInteract = options?.canInteract == nil and true or options.canInteract

    if (menu.counter < menu.pagination.min) or (menu.counter > menu.pagination.max) then
        self:NoVisible()
    else
        local y <const> = menu:GetY(config.h)
        local posY <const> = y + menu.offsetY
        if self:IsActive(posY, self.index, self.list) then
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
            if ((not self.gameTimer) or (self.gameTimer < GetGameTimer())) and self.canInteract then
                if IsControlPressed(0, 190) then -- RIGHT only
                    if index < #list then
                        index += 1
                    else
                        index = 1
                    end

                    self.gameTimer = GetGameTimer() + 100
                    if self.actions?.onListChanged then
                        self:OnListChanged(self.actions.onListChanged, index, list[index])
                    end
                end

                if IsControlPressed(0, 189) then -- LEFT only
                    if index > 1 then
                        index -= 1
                    else
                        index = #list
                    end

                    self.gameTimer = GetGameTimer() + 100
                    if self.actions?.onListChanged then
                        self:OnListChanged(self.actions.onListChanged, index, list[index])
                    end
                end
            end

            -- TAB JustPressed
            if IsControlJustPressed(0, 37) then -- TAB only
                local lastIndex = #list
                if self.actions?.onListChanged then
                    self:OnListChanged(self.actions.onListChanged, lastIndex, list[lastIndex])
                end
            end

            if IsControlJustPressed(0, 191) and self.canInteract then -- ENTER only
                if self?.actions.onSelected then
                    self:OnSelected(self.actions.onSelected, index, list[index])
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

        local offsetX = 0

        if options?.rightlabel then
            if offsetX == 0 then
                offsetX = draw.measureStringWidth(self.options.rightlabel, 0, 0.25)
            end

            draw.text(
                self.options.rightlabel,
                menu.x + menu.w / 2 - .005,
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

        draw.text(
            '← ' .. (list[index]?.label or list?[index] or index) .. ' →',
            menu.x + menu.w / 2 - .005 - offsetX,
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

        menu.offsetY += (config.h + menu.padding)
    end

    return self
end
