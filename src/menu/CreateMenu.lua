local config <const> = require '@sublime_nativeui.config.menu.global' 
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

function Items:IsActive(menu)
    return menu.index == menu.size
end

function Menu:Init()
    if not self.id then
        return warn('Menu id is required')
    end

    self.x = self.x or config.x
    self.y = self.y or config.y
    self.w = self.w or config.w
    self.offset = 0
    self.marginItem = self.marginItem or config.marginItem

    self.default = {
        x = self.x,
        y = self.y,
        w = self.w,
        --offset = self.offset,
    }

    self.banner = self.banner or config.banner
    self.glare = (not self.banner and false) or (self.glare or config.glare)
    self.pagination = self.pagination or config.pagination
    self.backgroundColor = self.backgroundColor or config.backgroundColor

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


local function Responsive(data)
    local w, h = GetActiveScreenResolution()
    local base = GetAspectRatio(true)
    local ratio = (16 / 9) / base
    local width = ratio * w

    local x = data.x + (data.w * data.x)
    local newData = {
        x = (x * width) / w,
        w = (data.w * width) / w,
        y = data.y,
        h = data.h,
    }

    return newData
end

function Menu:Banner()
    self.offset = .1
    DrawRect(self.x, self.offset + (self.y / 2), self.w, self.offset, self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4])
    if self.subtitle then
        self:Subtitle()
    end
end

function Menu:Background()
    DrawRect(self.x, self.offset - (self.y * 2), self.w, self.offset, 0, 0, 0, 100)
end

function Menu:Subtitle()
    self.offset += .03
    DrawRect(self.x, self.y + self.offset, self.w, .03, 255, self.backgroundColor[2], self.backgroundColor[3], 50)
end

function Menu:Description()
    self.offset += .025
    DrawRect(self.x, self.y + self.offset, self.w, .025, 0, self.backgroundColor[2], 255, 50)
end

function Menu:GoPool()
    CreateThread(function()
        while self.opened do
            local data = Responsive(self.default)

            self.x = data.x
            self.y = data.y
            self.w = data.w
            Wait(5000)
        end
    end)

    CreateThread(function()
        while self.opened do
            self.size, self.offset = 0, 0
            if self.banner then
                self:Banner()
            elseif self.subtitle then
                self:Subtitle()            
            end
            self:pool(Items, Panels)
            
            if self.currentDescription then
                self:Description()
            end

            self:Background()
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