local animation = { state = 0 }

--- @param options table
--- @param config table
--- @param data table
--- @param rect RectProps
function animation:play(menu, options, config, data, rect)
    if self.state == menu.index then return end
    self.state = menu.index
    self.current = self.state

    local id <const> = options?.type or 'sneaky'--'progress-join'
    local success <const>, anim <const> = pcall(require, '@sublime_nativeui.src.menu.items.animation.'..id)

    if not success then
        return warn(('Animation button [%s] not found!\n%s'):format(id, anim))
    end

    CreateThread(function()
        self.current = self.state
        while (self.state == menu.index) and (menu.opened) and not menu.playAnimation do Wait(0)
            anim(self, menu, options, config, data, rect)
        end

        if not menu.opened then
            self.state = 0
        end
    end)
end

return animation