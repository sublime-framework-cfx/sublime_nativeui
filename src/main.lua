local MenusRegistered, currentVisible = {}, nil

local function PlayExports(export, ...)
    local resourceName <const> = export:match('(.+)%..+')
    local methodName <const> = export:match('.+%.(.+)')
    return exports[resourceName][methodName](nil, ...)
end

---@class SubRegisterMenuProps
---@field id string

---@class RegisterMenuProps
---@field id string
---@field env string
---@field submenu SubRegisterMenuProps

---@param menu RegisterMenuProps
---@return nil
local function RegisterMenu(menu)
    if MenusRegistered[menu.id] then
        return  warn(('Menu with id %s already registered in this resource : %s'):format(menu.id, menu.env))
    end

    MenusRegistered[menu.id] = menu
end

---@param id string
---@param subId? string
---@return nil
local function OpenMenu(id, subId)
    if not MenusRegistered[id] then
        return warn(('Menu with id %s not registered'):format(id))
    end

    if currentVisible then
        local menu <const> = MenusRegistered[currentVisible]
        local exp <const> = menu.env..'.'..'CloseMenu'
        PlayExports(exp, id, subId)
    end

    local menu <const> = MenusRegistered[id]
    local exp <const> = menu.env..'.'..'OpenMenu'
    PlayExports(exp, id, subId)

    currentVisible = id
end

local function CloseMenu()
    if not currentVisible then
        return warn('No menu visible')
    end

    local menu <const> = MenusRegistered[currentVisible]
    local exp <const> = menu.env..'.'..'CloseMenu'
    currentVisible = PlayExports(exp, currentVisible)
end

local function CurrentOpen()
    return currentVisible
end

local function UpdateMenu(id, subId)
    if not MenusRegistered[id] then
        return warn(('Menu with id %s not registered'):format(id))
    end

    if MenusRegistered[id].submenu[subId] then
        return warn(('Submenu with id %s not registered in menu %s'):format(subId, id))
    end

    MenusRegistered[id].submenu[subId] = subId
end

exports('RegisterMenu', RegisterMenu)
exports('OpenMenu', OpenMenu)
exports('CloseMenu', CloseMenu)
exports('CurrentOpen', CurrentOpen)
exports('UpdateMenu', UpdateMenu)


RegisterCommand('ook', function()
    if not currentVisible then
        OpenMenu('main')
    else
        print('currentVisible', currentVisible)
        currentVisible = CloseMenu()
    end
end)