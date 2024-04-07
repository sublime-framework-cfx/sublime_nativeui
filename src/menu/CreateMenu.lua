local config <const> = require '@sublime_nativeui.config.menu' 
local class <const> = require '@sublime_nativeui.src.utils.class'
local Menu = class('menu')
local nativeui = _ENV.nativeui
local Items, Panels = setmetatable({}, {
    __index = function(self, index)
        local item = rawget(self, index)
        if item then return item end
        item = require(('@sublime_nativeui.src.menu.items.%s'):format(index))
        if not item then return warn(('item %s not found'):format(index)) end
        rawset(self, index, item)
        return item
    end,
}), setmetatable({}, {
    __index = function(self, index)
        local panel = rawget(self, index)
        if panel then return panel end
        panel = require(('@sublime_nativeui.src.menu.panels.%s'):format(index))
        if not panel then return warn(('panel %s not found'):format(index)) end
        rawset(self, index, panel)
        return panel
    end,
})

function Menu:Init()
    if not self.id then
        return warn('Menu id is required')
    end

    self.x = self.x or config.x
    self.y = self.y or config.y

    self.opened = false
    self.index = 1
    self.size = 0
    self.submenu = {}

    if self.parent then
        if type(self.parent) == 'string' then
            self.parent = nativeui.menus[self.parent]
        elseif type(self.parent) == 'table' then
            self.parent = nativeui.menus[self.parent.id]
        end

        local menu = nativeui.menus[self.parent.id]
        menu.submenu[self.id] = self
        nativeui.RegisterMenu({
            id = self.id,
            env = nativeui.env,
            submenu = {}
        })
        nativeui.UpdateMenu(menu.id, self.id)
    else
        nativeui.RegisterMenu({
            id = self.id,
            env = nativeui.env,
            submenu = {}
        })
    end

    nativeui.menus[self.id] = self
end

function Menu:Open()
    if nativeui.CurrentOpen() then
        nativeui.CloseMenu()
    end

    if self.opened then
        return ''
    end

    self.opened = true
    nativeui.current = self.id
    nativeui.SetVisible(self.id)
    self:GoPool()
    return self.id
end

function Menu:GoPool()
    CreateThread(function()
        while self.opened do
            self.size = 0
            self:pool(Items, Panels)
            DrawRect(0.5, 0.5, self.width or .2, 0.2, self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4])
            Wait(0)
        end
    end)
end

function Menu:Close()
    if not self.opened then
        return ''
    end

    nativeui.current = ''
    nativeui.SetVisible('')
    self.opened = false
    return ''
end

function Menu:Destroy()
    nativeui.menus[self.id] = nil
    return nil, collectgarbage()
end

function Menu:IsOpen()
    return self.opened
end

local function CloseMenu(id)
    local found = nativeui.menus[id]
    if found then
        local closed = found:Close()
        print(closed)
        return closed
    else
        local parent = nativeui.GetParent(id)
        if parent then
            found = nativeui.menus[parent].submenu[id]
            if found then
                local closed = found:Close()
                print(closed)
                return closed
            end
        end
    end

    return warn(('Menu with id %s not found'):format(id))
end

local function OpenMenu(id)
    local found = nativeui.menus[id]
    if found then
        return found:Open()
    else
        local parent = nativeui.GetParent(id)
        if parent then
            found = nativeui.menus[parent].submenu[id]
            if found then
                return found:Open()
            end
        end
    end

    return warn(('Menu with id %s not found'):format(id))
end

exports('CloseMenu', CloseMenu)
exports('OpenMenu', OpenMenu)

return Menu