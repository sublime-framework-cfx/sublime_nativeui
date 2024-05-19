local class <const> = require '@sublime_nativeui.src.utils.class'

local animation = class('AnimationItems')

function animation:play(menu, options, config, data, rect, items)
    if self.state and self.state == menu.index then return end
    self.state = menu.index
    self.current = self.state

    local id <const> = options?.type or 'sneaky'--'progress-join'
    local success <const>, anim <const> = pcall(require, '@sublime_nativeui.src.menu.items.animation.'..id)

    if not success then
        return warn(('Animation button [%s] not found!\n%s'):format(id, anim))
    end

    CreateThread(function()
        ::back::
        --print(items, menu.index, self.state, self.current, menu.opened )
        Wait(0)
        if items == menu.index then
            self.index = menu.index
            local finish = anim(self, menu, options, config, data, rect)
            --print(finish, 'finish')
            if finish and menu.opened then goto back end
        end
    end)
end

return animation

-- local animation = { state = 0 }

-- --- @param options table
-- --- @param config table
-- --- @param data table
-- --- @param rect RectProps
-- function animation:play(menu, options, config, data, rect)
--     if self.state == menu.index then return end
--     self.state = menu.index
--     self.current = self.state

--     local id <const> = options?.type or 'sneaky'--'progress-join'
--     local success <const>, anim <const> = pcall(require, '@sublime_nativeui.src.menu.items.animation.'..id)

--     if not success then
--         return warn(('Animation button [%s] not found!\n%s'):format(id, anim))
--     end

--     CreateThread(function()
--         self.current = self.state
--         while (self.state == menu.index) and (menu.opened) and not menu.playAnimation do Wait(0)
--             anim(self, menu, options, config, data, rect)
--         end

--         if not menu.opened then
--             self.state = 0
--         end
--     end)
-- end