local config <const> = require '@sublime_nativeui.config.menu.global' 
local class <const> = require '@sublime_nativeui.src.utils.class'
local Controler <const> = require '@sublime_nativeui.src.menu.components.controler'

local Menu = class('menu')
local nativeui = _ENV.nativeui
local Items, Panels = setmetatable({
    actions = {},
}, {
    __index = function(self, index)
        local item <const> = rawget(self, index)
        if item then return item end
        local success <const>, result <const> = pcall(require, ('@sublime_nativeui.src.menu.items.%s'):format(index))
        if not result then return warn(('item %s not found'):format(index)) end
        rawset(self, index, result)
        return result
    end,
}), setmetatable({}, {
    __index = function(self, index)
        local panel <const> = rawget(self, index)
        if panel then return panel end
        local success <const>, result <const> = pcall(require, ('@sublime_nativeui.src.menu.panels.%s'):format(index))
        if not result then return warn(('panel %s not found'):format(index)) end
        rawset(self, index, result)
        return result
    end,
})

function Items:IsActive(menu)
    local active <const> = menu.index == menu.counter
    
    if active then
        if menu.lastIndex == 0 then
            menu.lastIndex = menu.index

            if self.actions.onEnter then
                self.actions.onEnter(self, menu)
            end
        end

        if self.actions.onActive then
            self.actions.onActive(self, menu)
        end
    end

    return active
end

function Items:IsLastActive(menu)
    local isLast <const> = menu.lastIndex == menu.counter

    if isLast then
        if self.actions.onExit then
            self.actions.onExit(self, menu)
        end

        menu.lastIndex = 0
    end

    return isLast
end

function Menu:Init()
    if not self.id then return warn('Menu id is required') end
    self.offsetY, self.offsetX = 0, 0
    self.padding = self.padding or config.padding
    self.x = self.x or config.default.x
    self.y = self.y or config.default.y
    self.w = self.w or config.default.w
    self.h = self.h or config.default.h
    self.mouse = self.mouse or config.mouse

    self.banner = self.banner == nil and config.banner or self.banner
    self.bannerH = self.banner and (self.bannerH or config.bannerH)
    self.subtitle = self.subtitle == nil and config.subtitle or self.subtitle 
    self.subtitleH = (not self.subtitle and false) or (self.subtitleH or config.subtitleH)
    self.glare = (not self.banner and false) or (self.glare or config.glare)
    self.pagination = self.pagination or config.pagination
    self.background = self.background == nil and config.background or self.background
    self.backgroundColor = self.backgroundColor or config.backgroundColor

    self.opened = false
    self.index, self.lastIndex = 1, 0
    self.counter = 0
    self.submenu = {}
    self.maxVisibleItems = self.maxVisibleItems or config.maxVisibleItems

    self.closable = self.closable == nil and true or self.closable

    -- print(self.banner, self.subtitle)

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

function Menu:SetSizeResponsive()
    local rw <const>, rh <const> = GetActiveScreenResolution()
    local base <const> = GetAspectRatio(true)
    local ratio <const> = (16 / 9) / base
    -- example w = 2540, data.w = .2 (alors 2540 * .2 = 508) 508 / 2540 = 0.2

    self.w = ratio * ((rw * config.default.w) / rw)
    --self.h = ratio * ((rh * self.default.h) / rh)
    self.x = (self.w / 2) + config.default.x
    self.y = config.default.y
end

function Menu:GetY(h)
    -- print(h, self.default.y, 'gety', (h / 2) + self.default.y)
    return (h / 2) + self.y
end

function Menu:Banner()
    local y = self:GetY(self.bannerH)
    DrawRect(self.x, y, self.w, self.bannerH, self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4])
    self.offsetY += (self.bannerH + self.padding)
    if self.subtitle then
        self:Subtitle()
    end
end

function Menu:Subtitle()
    local y = self:GetY(self.subtitleH)
    DrawRect(self.x, y + self.offsetY, self.w, self.subtitleH, 255, self.backgroundColor[2], self.backgroundColor[3], 50)
    self.offsetY += (self.subtitleH + self.padding)
end

function Menu:Background()
    local y = self:GetY(self.offsetY) 
    DrawRect(self.x, y, self.w, self.offsetY, 255, 255, 255, 100)
end


function Menu:Description() ---@todo
    --self.offsetY += .025
    DrawRect(self.x, self.y + self.offset, self.w, .025, 0, self.backgroundColor[2], 255, 50)
end

function Menu:GoPool()
    CreateThread(function()
        while self.opened do
            self:SetSizeResponsive()
            Wait(5000)
        end
    end)

    CreateThread(function()
        while self.opened do
            self.counter, self.offsetY, self.offsetX = 0, 0, 0

            if self.banner then
                self:Banner()
            elseif self.subtitle then
                self:Subtitle()            
            end

            self:Pool(Items, Panels)
            
            if self.currentDescription then
                --self:Description()
            end

            if self.background then
                self:Background()
            end

            Controler(self)
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
    if self.Closed then
        self:Closed()
    end

    if self.back then
        nativeui.OpenMenu(self.back)
        self.back = nil
    end

    return ''
end

function Menu:GoTo(to)
    if type(to) == 'string' then
        nativeui.OpenMenu(to)
    else
        to:Open()
        to.back = self.id
    end
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
        -- print(closed)
        return closed
    else
        local parent = nativeui.GetParent(id)
        if parent then
            found = nativeui.menus[parent].submenu[id]
            if found then
                local closed = found:Close()
                -- print(closed)
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