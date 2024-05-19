local config <const> = require '@sublime_nativeui.config.menu.global' 
local class <const> = require '@sublime_nativeui.src.utils.class'
local Controler <const> = require '@sublime_nativeui.src.menu.components.controler'
local animationsMenu = require '@sublime_nativeui.src.menu.components.animation.play'
local animationItems = require '@sublime_nativeui.src.menu.items.animation.play'
local configItems <const> = require '@sublime_nativeui.config.menu.button'
---@type DrawProps
local draw <const> = require '@sublime_nativeui.src.utils.draw'
math.round = require '@sublime_nativeui.src.utils.math'.Round

local Menu = class('menu')
local SubMenu = class('submenu', Menu)
--local Items, Panels = class('items'), class('panels')
local nativeui = _ENV.nativeui
local Items = {}

function Items:GetY(h)
    return (h / 2) + self.menu.y
end

function Items:IsActive(y)
    local active <const> = self.menu.index == self.menu.counter
    
    if active then
        if self.canInteract and self.menu.freezeControl then
            self.canInteract = false
        end

        if not self.menu.playAnimation then
            self.animations:play(self.menu, self.options?.animation, configItems.animation, {
                x = self.menu.x,
                y = y,
                w = self.menu.w,
                h = self.h or configItems.h
            }, draw.rect, self.id)
        end

        if self.menu.lastIndex == 0 then
            self.menu.lastIndex = self.menu.index

            if self.actions.onEnter then
                self.actions.onEnter(self)
            end
        end

        if self.actions.onActive then
            self.actions.onActive(self)
        end
    end

    return active
end

function Items:OnSelected(selected)
    CreateThread(function()
        selected()
        PlaySoundFrontend(-1, "SELECT", "HUD_LIQUOR_STORE_SOUNDSET", true)
    end)
end

function Items:IsLastActive()
    local isLast <const> = self.menu.lastIndex == self.menu.counter

    if isLast then
        if self.actions.onExit then
            self.actions.onExit(self, self.menu)
        end

        self.menu.lastIndex = 0
    end

    return isLast
end

function Items:Visible()
    local menu <const> = self.menu

    ---@todo global settings of items
end

function Items:NoVisible()
    if self.actions?.onExit then
        self:IsLastActive() 
    end

    if self.playAnimation then
        self.playAnimation = false
    end
end

function Items:AddButton(label, description, options, actions, nextMenu)
    return require('@sublime_nativeui.src.menu.items.AddButton')(self, label, description, options, actions, nextMenu)
end

-------------------------------------
-- Panels
-------------------------------------
---@todo

-------------------------------------
-- Menu
-------------------------------------

function Menu:Init()
    --print(self.id, self.name, self.type, self.env)
    if not self.id then return warn('Menu id is required') end
    if type(self.id) ~= 'string' then return warn('Menu id must be a string') end
    if nativeui.menus[self.id] or nativeui.GetMenu(self.id) then return warn(('Menu with id %s already exist'):format(self.id)) end

    self.offsetY, self.offsetX = 0, 0
    self.totalOffsetY = 0
    self.padding = self.padding or config.padding
    self.x = self.x or config.default.x
    self.y = self.y or config.default.y
    self.w = self.w or config.default.w
    self.h = self.h or config.default.h
    self.mouse = self.mouse or config.mouse
    self.type = self.parent and 'submenu' or 'menu'

    self.banner = self.banner == nil and config.banner or self.banner
    self.bannerH = self.banner and (self.bannerH or config.bannerH)
    self.subtitle = self.subtitle == nil and config.subtitle or self.subtitle 
    self.subtitleH = (not self.subtitle and false) or (self.subtitleH or config.subtitleH)
    self.glare = (not self.banner and false) or (self.glare or config.glare)
    self.scaleformGlare = (self.glare and nativeui.RequestGlare())
    self.background = self.background == nil and config.background or self.background
    self.backgroundColor = self.backgroundColor or config.backgroundColor

    self.opened = false
    self.index, self.lastIndex = 1, 0
    self.counter, self.totalCounter = 0, 0
    self.maxVisibleItems = self.maxVisibleItems or config.maxVisibleItems
    self.lastDescription = nil
    self.pagination = self.pagination or { min = 1, max = self.maxVisibleItems or config.maxVisibleItems }

    self.closable = self.closable == nil and true or self.closable

    ---@todo rework to set animation enter and exit
    -- self.animation = self.animation == nil and config.animation.enabled and config.animation.type or self.animation
    -- self.playAnimation = false

    --- Controler
    self.lastPressed = nil
    self.stepPressed = 0
    self.timeControl = GetGameTimer()
    self.freezeControl = false

    if self.type == 'menu' then
        nativeui.RegisterMenu({
            id = self.id,
            env = nativeui.env,
            type = 'menu',
            name = self.name or self.id
        })
    elseif self.type == 'submenu' then
        self.banner = false
        self.subtitle = false
    end

    -- self.Items, self.Panels = Items:new({
    --     menu = self
    -- }), Panels:new({
    --     menu = self
    -- })

    self.Items = setmetatable({
        menu = self,
        animations = animationItems:new({
            menu = self,
        }),
        playAnimation = false,
        actions = {}
    }, { __index = Items })

    self.animation = animationsMenu:new({
        menu = self,
    })

    nativeui.menus[self.id] = self
end

---@param bool boolean
function Menu:SetFreezeControl(bool)
    self.freezeControl = bool
end

--require '@sublime_nativeui.src.menu.components.controler'

function Menu:ResetIndex()
    self.index = 1
    self.lastIndex = 0
    self.pagination.min = 1
    self.pagination.max = self.maxVisibleItems or config.maxVisibleItems
    self.lastPressed = nil
end

function Menu:SetGlare(boolean)
    if (not boolean) or (self.glare ~= nil and self.glare == boolean) then return end

    if boolean then
        self.scaleformGlare = nativeui.RequestGlare()
    else
        self.scaleformGlare = nil
    end

    self.glare = boolean
end

function Menu:SetSizeResponsive() ---@todo ici pour le moment ca se base sur un menu en haut à gauche a voir dans le config pour faire les pos 'top-left', 'top-right', 'bottom-left', 'bottom-right'
    local rw <const>, rh <const> = nativeui.cache.rw, nativeui.cache.rh
    local ratio <const> = nativeui.cache.ratio
    -- example: w = 2540, data.w = .2 (alors 2540 * .2 = 508) 508 / 2540 = 0.2

    self.w = ratio * ((rw * config.default.w) / rw)
    self.rh, self.rw = rh, rw
    self.ratio = ratio
    self.base = nativeui.cache.base
    --self.h = ratio * ((rh * self.default.h) / rh)
    self.x = (self.w / 2) + config.default.x
    self.y = config.default.y
end

function Menu:GetY(h)
    return (h / 2) + self.y
end

function Menu:Banner() ---@todo personalization config & menu object
    local y <const> = self:GetY(self.bannerH)
    draw.rect(self.x, y, self.w, self.bannerH, self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4])
    draw.text(self.title, self.x * .35, y * .7, 1, .9, 255, 255, 255, 255, true)
    self.offsetY += (self.bannerH + self.padding)
    if self.scaleformGlare then ---@todo A voir pour refaire les calcules pour calibrer le scaleform a la bannière...
        --print(self.base, self.ratio, MathRound(self.ratio, 2))
        local gx <const> = (self.x / self.rw + 0.485) 
        local gy <const> = self.y + 0.449

        -- A savoir pour info que au niveau de la résolution le scaleform n'est pas impacté, mais il est impacté par le ratio (format image)
        -- Il se base sur 1270 x 720 (16/9) pour le scaleform, donc si on est en 21/9 par exemple, il va falloir recalculer le scaleform
        -- Permet compatible format 21/9 & 16/9 mais pas le reste
        -- Bref j'ai fait quelque calcule pour trouver un compromis, mais c'est pas parfait à voir si des gens trouve mieux...
        local reScale <const> = math.round(self.ratio, 2) == 1.0 and 1.0 or (math.round(self.ratio, 2) - (.1 * .7))
        draw.scaleformMovie(self.scaleformGlare, gx * reScale, gy, 1.0, 1.0, 255, 255, 255, 255)
    end
    if self.subtitle then
        self:Subtitle()
    end
end

function Menu:Subtitle()
    local y <const> = self:GetY(self.subtitleH)
    draw.rect(self.x, y + self.offsetY, self.w, self.subtitleH, 0, 0, 0, 200)
    draw.text(self.subtitle, self.x - self.w / 2 + .005, y * .785 + self.offsetY, 0, .27, 255, 255, 255, 255, true)
    draw.text(self.index .. '/' .. self.totalCounter, self.x + self.w / 2 - .001, y * .785 + self.offsetY, 0, .27, 255, 255, 255, 255, 'right', true)
    self.offsetY += (self.subtitleH + self.padding)
    if not self.parent then
        self.offsetY_banner = (self.offsetY + self.bannerH)
    end
end

function Menu:SetSubtitle(value)
    if value and self.subtitle ~= value then
        self.subtitle = value
    end
end

function Menu:Background() ---@todo personalization config & menu object
    local y = self:GetY(self.totalOffsetY)
    draw.rect(self.x, y, self.w, self.totalOffsetY, self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4])
end

function Menu:Description() ---@todo personalization config & menu object
    if not self.currentDescription then return end
    if self.lastDescription ~= self.currentDescription then 
        self.totalTextWidthDesc = draw.measureStringWidth(self.currentDescription, 0, .27)
        self.lineCountDesc = math.ceil(self.totalTextWidthDesc / self.w)
        self.descH = .04

        if self.currentDescription:find("\n") then
            for line in self.currentDescription:gmatch("[^\n]+") do
                self.lineCountDesc += 1
            end
            self.lineCountDesc -= 1
        end

        if self.lineCountDesc > 1 then
            self.descH *= self.lineCountDesc
        end

        self.lastDescription = self.currentDescription
    end
    
    local yText <const> = self:GetY(self.offsetY * 2 + self.padding) + self.padding
    local yRect <const> = self:GetY(self.offsetY * 2 + self.padding + self.descH * .5) + .005

    ---@todo personalization config & menu object
    draw.rect(self.x, yRect, self.w, (self.descH * .5) + .01, 0, 0, 0, 200)
    draw.text(self.currentDescription, self.x - self.w / 2 + .005, yText + self.padding, 0, .27, 255, 255, 255, 255, nil, true, true, self.w)
end

function Menu:Elements(Item, Panel)
    Item(self.Items)
    self.totalCounter = self.counter
    if self.counter > self.maxVisibleItems then
        -- self:Naviguation()
    end
    if self.currentDescription then
        self:Description()
    end
    if Panel then
        Panel(self.Panels)
    end
    self.totalOffsetY = self.offsetY
end

-- function Menu:GetOffsetFromParent()
--     return self.parent and self.parent.offsetY or 0
-- end

function Menu:GoPool(bool, y, h, x)
    self:SetSizeResponsive()

    if self.Opened then
        self:Opened()
    end

    if self.type == 'submenu' then
        self.parent.freezeControl = true
    end

    if self.animation or config.animation then
        --self.offsetY += (self.bannerH + self.padding)
        local newxY <const> = bool and self:GetY(self.parent.bannerH)
        --self.defaultY = bool and (self:GetY(self.parent.offsetY_banner - self.padding*12)) or self.y
        self.defaultY = bool and (newxY + self.padding)/2 or self.y
        self.defaultW = self.w
        self.defaultX = bool and (self.x + self.defaultW) + self.padding or self.x
        if bool then
            self.x = self.defaultX
            self.y = self.defaultY
        end
        self.playAnimation = true
        self.animation:open(self.animation or config.animation)
    end

    local offsetY = bool and self.defaultY or 0
    if not bool then
        LocalPlayer.state:set('menuOpen', self.id, false) ---@force
    end

    CreateThread(function()
        if self.scaleformGlare then ---@todo à voir dans Menu:Banner()
            PushScaleformMovieFunction(self.scaleformGlare, "SET_DATA_SLOT")
            PopScaleformMovieFunctionVoid()
        end

        while self.opened or self.playAnimation do
            self.counter, self.offsetY, self.offsetX = 0, 0, 0

            if bool and not self.parent.opened then
                self:GoClose()
                return
            elseif not bool then
                if LocalPlayer.state.menuOpen ~= self.id then
                    self:GoClose()
                    return
                end
            end

            if self.condition and type(self.condition) == 'function' then
                if not self.condition() then
                    self:Close(nil, true)
                    return
                end
            end

            if self.background then self:Background() end

            if self.banner then
                self:Banner()
            elseif self.subtitle then
                self:Subtitle()            
            end

            if not self.IsVisible then
                error(('IsVisible method is required for id : %s'):format(self.id), 2)
            end

            self:IsVisible()
            Controler(self)
            Wait(0)
        end
    end)
end

---@return nil
function Menu:Destroy()
    nativeui.menus[self.id] = nil
    return nil
end

---@return boolean
function Menu:IsOpen()
    return self.opened
end

---@param to string | Menu
function Menu:NextMenu(to, y, h, x)
    if (type(to) == 'string') or (not y and not h )then
        local menu <const> = type(to) == 'string' and to or to.id
        TriggerEvent('sublime_nativeui:open', menu)
    else
        local submenu = nativeui.menus[to.id]
        submenu:GoOpen(submenu.parent and true or false, y, h, x)
    end
end

---@param clearQueue? boolean
function Menu:Open(clearQueue)
    if self.opened then
        return false, ('Menu with id %s already opened [%s]'):format(self.id, nativeui.env)
    end

    if self.type == 'submenu' then
        return
    end

    TriggerEvent('sublime_nativeui:open', self.id, clearQueue)
end

---@param _type? string<'GoBack'>
---@param clearQueue? boolean
function Menu:Close(_type, clearQueue)
    if not self.opened then
        return false, ('Menu with id %s not opened'):format(self.id)
    end

    if self.type == 'submenu' then
        self:GoClose()
        local parent = self.parent
        parent:SetFreezeControl(false)
        return
    end

    TriggerEvent('sublime_nativeui:close', self.id, _type == 'GoBack' and true or false, clearQueue)
end

---@param clearQueue? boolean
function Menu:Toggle()
    if self:IsOpen() then
        self:Close()
    else
        self:Open()
    end
end

---@param id string
---@param name string
---@param parent? string
---@return SubMenu
function Menu:AddSubMenu(id, name)
    self.children = SubMenu:new({
        id = id,
        name = name,
        parent = self,
        type = 'submenu'
    }) 
    return self.children
end

---@return boolean, string?
function Menu:GoOpen(bool, y, h, x)
    if self.opened then
        return false, ('Menu with id %s already opened'):format(self.id)
    end

    if self.freezeControl then
        self:SetFreezeControl(false)
    end

    if self.condition and type(self.condition) == 'function' then
        if not self.condition() then
            return
        end
    end

    self.opened = true
    self:GoPool(bool, y, h, x)

    return true
end

---@param x float
---@param y float
function Menu:SetPosition(x, y)
    self.x = x or self.x
    self.y = y or self.y
end

---@return boolean
function Menu:GoClose()
    local p
    if not self.opened then
        return false, ('Menu with id %s not opened'):format(self.id)
    end

    if self.children and self.children.opened then
        return self.children:GoClose()
    end

    if self.animation or config.animation then
        p = promise.new()
        CreateThread(function()
            if self.animation then
                self.playAnimation = true
                self.animation:close(config.animation)

                while self.playAnimation do
                    Wait(50)
                end
            end

            if self.Closed then
                self:Closed()
            end

            self.opened = false
            p:resolve(true)
        end)
    else
        if self.Closed then
            self:Closed()
        end
        self.opened = false
        return true
    end

    return p and nativeui.await(p) or false
end

return Menu