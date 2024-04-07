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
        print('isActive', menu.index, menu.size)
    else
        print('isNotActive', menu.index, menu.size)
    end

    return menu.size --[[@as buttonId]] --[[@return integer]]
end