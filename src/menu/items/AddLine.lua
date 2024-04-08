-- local config <const> = require '@sublime_nativeui.config.menu.line'

---@param self Items
---@param menu Menu
---@param styles table
return function(self, menu, styles)
    menu.size += 1

    if menu.index == menu.size then -- is active so go to next
        if menu.lastIndex > menu.index then -- if last index is greater than current index, we up
            menu.index -= 1 -- decrement index to up
        elseif menu.lastIndex < menu.index then -- if last index is less than current index, we down
            menu.index += 1 -- increment index to down
        end
    end

    if styles and (type(styles) == 'table' and table.type(styles) == 'hash') then
        ---@todo personalize line style, color, animation, etc ...
    end
end