local config <const> = require '@sublime_nativeui.config.menu.button'

---@param self Items
---@param menu Menu
---@param label string
---@param description string
---@return integer buttonId
return function(self, menu, label, description)
    menu.size += 1
    --print(test, test2, menu.size)

    if menu.index == menu.size then
        menu.currentDescription = description
        --print('isActive', menu.index, menu.size)
    else
        --print('isNotActive', menu.index, menu.size)
    end

    menu.offset += config.h + menu.marginItem
    if menu.size == 1 then
        DrawRect(menu.x, menu.y + menu.offset, menu.w, config.h, 0, 0, 255, 75)
    elseif menu.size == 2 then
        DrawRect(menu.x, menu.y + menu.offset, menu.w, config.h, 0, 255, 0, 50)
    else
        DrawRect(menu.x, menu.y + menu.offset, menu.w, config.h, 255, 0, 0, 50)
    end

    return menu.size --[[@as buttonId]] --[[@return integer]]
end