local config <const> = require '@sublime_nativeui.config.menu.global' 
local class <const> = require '@sublime_nativeui.src.utils.class'
local Controler <const> = require '@sublime_nativeui.src.menu.components.controler'
local animations <const> = require '@sublime_nativeui.src.menu.components.animation.play'
local draw <const> = require '@sublime_nativeui.src.utils.draw'
math.round = require '@sublime_nativeui.src.utils.math'.Round


local Menu = class('menu')
local Items, Panels = class('items'), class('panels')
local nativeui = _ENV.nativeui

function Items:IsActive()
    local active <const> = self.menu.index == self.menu.counter
    
    if active then
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

    self.banner = self.banner == nil and config.banner or self.banner
    self.bannerH = self.banner and (self.bannerH or config.bannerH)
    self.subtitle = self.subtitle == nil and config.subtitle or self.subtitle 
    self.subtitleH = (not self.subtitle and false) or (self.subtitleH or config.subtitleH)
    self.glare = (not self.banner and false) or (self.glare or config.glare)
    self.scaleformGlare = (self.glare and nativeui.RequestGlare())
    self.pagination = self.pagination or config.pagination
    self.background = self.background == nil and config.background or self.background
    self.backgroundColor = self.backgroundColor or config.backgroundColor

    self.opened = false
    self.index, self.lastIndex = 1, 0
    self.counter, self.totalCounter = 0, 0
    self.maxVisibleItems = self.maxVisibleItems or config.maxVisibleItems
    self.lastDescription = nil

    self.closable = self.closable == nil and true or self.closable

    ---@todo rework to set animation enter and exit
    self.animation = self.animation == nil and config.animation.enabled and config.animation.type or self.animation
    self.playAnimation = false

    nativeui.RegisterMenu({
        id = self.id,
        env = nativeui.env,
        type = 'menu',
        name = self.name or self.id
    })

    self.Items, self.Panels = Items:new({
        menu = self
    }), Panels:new({
        menu = self
    })

    nativeui.menus[self.id] = self
end

function Menu:ResetIndex()
    self.index = 1
    self.lastIndex = 0
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

function Menu:SetSizeResponsive()
    local rw <const>, rh <const> = nativeui.cache.rw, nativeui.cache.rh
    local ratio <const> = nativeui.cache.ratio
    -- example w = 2540, data.w = .2 (alors 2540 * .2 = 508) 508 / 2540 = 0.2

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

function Menu:Banner()
    local y <const> = self:GetY(self.bannerH)
    --DrawRect(self.x, y, self.w, self.bannerH, self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4])
    draw.rect({
        x = self.x,
        y = y,
        w = self.w,
        h = self.bannerH,
        r = self.backgroundColor[1],
        g = self.backgroundColor[2],
        b = self.backgroundColor[3],
        a = self.backgroundColor[4]
    })
    draw.text({
        x = self.x * .35,
        y = y * .7,
        text = self.title,
        font = 1,
        scale = .9,
        color = {255, 255, 255, 255},
        shadow = true
    })
    self.offsetY += (self.bannerH + self.padding)

    if self.scaleformGlare then ---@todo A voir pour refaire les calcules pour calibrer le scaleform a la bannière...
        --print(self.base, self.ratio, MathRound(self.ratio, 2))
        local gx <const> = (self.x / self.rw + 0.485) 
        local gy <const> = self.y + 0.449

        -- permet compatible format 21/9 & 16/9 mais pas le reste
        local reScale <const> = math.round(self.ratio, 2) == 1.0 and 1.0 or (math.round(self.ratio, 2) - (.1 * .7))
        DrawScaleformMovie(self.scaleformGlare, gx * reScale, gy, 1.0, 1.0, 255, 255, 255, 255, 0)
    end
    if self.subtitle then
        self:Subtitle()
    end
end

function Menu:Subtitle()
    local y = self:GetY(self.subtitleH)
    draw.rect({
        x = self.x,
        y = y + self.offsetY,
        w = self.w,
        h = self.subtitleH,
        r = 0,
        g = 0,
        b = 0,
        a = 200
    })

    draw.text({
        x = self.x - self.w / 2 + .005,
        y = y * .785 + self.offsetY,
        text = self.subtitle,
        font = 0,
        scale = .27,
        color = {255, 255, 255, 255},
        shadow = true
    })

    draw.text({
        x = self.x + self.w / 2 - .005,
        y = y * .785 + self.offsetY,
        text = self.index .. '/' .. self.totalCounter,
        font = 0,
        scale = .27,
        color = {255, 255, 255, 255},
        shadow = true,
        alignment = 'right'
    })

    self.offsetY += (self.subtitleH + self.padding)
end

function Menu:SetSubtitle(value)
    if value and self.subtitle ~= value then
        self.subtitle = value
    end
end

function Menu:Background()
    local y = self:GetY(self.totalOffsetY)

    -- DrawRect(self.x, y, self.w, self.offsetY, 255, 255, 255, 100)
    draw.rect({
        x = self.x,
        y = y,
        w = self.w,
        h = self.totalOffsetY,
        r = self.backgroundColor[1],
        g = self.backgroundColor[2],
        b = self.backgroundColor[3],
        a = self.backgroundColor[4]
    })
end

function Menu:Description() ---@todo
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

    draw.rect({
        x = self.x,
        y = yRect,
        w = self.w,
        h = (self.descH * .5) + .01,
        r = 0,
        g = 0,
        b = 0,
        a = 200
    })

    draw.text({
        x = self.x - self.w / 2 + .005,
        y = yText + self.padding,
        text = self.currentDescription,
        font = 0,
        scale = .27,
        color = {255, 255, 255, 255},
        shadow = true,
        wordWrap = self.w
    })    
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

function Menu:GoPool()
    self:SetSizeResponsive()

    if self.animation or config.animation then
        self.defaultY = self.y
        self.defaultX = self.x
        self.playAnimation = true
        animations('open', self, self.animation or config.animation)
    end

    if self.Opened then
        self:Opened()
    end

    CreateThread(function()
        if self.scaleformGlare then ---@todo à voir dans Menu:Banner()
            PushScaleformMovieFunction(self.scaleformGlare, "SET_DATA_SLOT")
            PopScaleformMovieFunctionVoid()
        end

        while self.opened or self.playAnimation do
            self.counter, self.offsetY, self.offsetX = 0, 0, 0

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

function Menu:Destroy()
    nativeui.menus[self.id] = nil
    return nil
end

function Menu:IsOpen()
    return self.opened
end

function Menu:NextMenu(to)
    local menu <const> = type(to) == 'string' and to or to.id
    nativeui.OpenMenu(menu)
end

function Menu:Open(clearQueue)
    return nativeui.OpenMenu(self.id, nil, clearQueue)
end

function Menu:Close(_type, clearQueue)
    if not self.opened then
        return false, ('Menu with id %s not opened'):format(self.id)
    end

    if _type == 'GoBack' then
        return nativeui.OpenMenu(self.id, _type, clearQueue)
    end

    local closed <const> = nativeui.CloseMenu(self.id, _type, clearQueue)
    return true
end

function Menu:GoOpen()
    if self.opened then
        return false, ('Menu with id %s already opened'):format(self.id)
    end

    self.opened = true
    self:GoPool()

    return self.id
end

function Menu:SetPosition(x, y)
    self.x = x or self.x
    self.y = y or self.y
end

function Menu:GoClose()
    if self.animation or config.animation then
        CreateThread(function()
            if self.animation or config.animation then
                self.playAnimation = true
                animations('close', self, self.animation or config.animation)

                while self.playAnimation do
                    Wait(50)
                end
            end

            if self.Closed then
                self:Closed()
            end
        end)
    else
        if self.Closed then
            self:Closed()
        end
    end

    self.opened = false
    return true
end

return Menu