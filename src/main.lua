---@param export string
---@param ... unknown
---@return unknown
local function PlayExports(export, ...)
    local resourceName <const> = export:match('(.+)%..+')
    local methodName <const> = export:match('.+%.(.+)')
    return exports[resourceName][methodName](nil, ...)
end

local cache, await <const>, action = {
    rw = 0,
    rh = 0,
    base = 0,
    ratio = 0
}, Citizen.Await, false

---@param key string
---@param value number
function cache:set(key, value)
    if (not self[key]) or (self[key] ~= value) then
        self[key] = value
        TriggerEvent('sublime_nativeui:cache:set', key, value)
    end
end

CreateThread(function()
    while true do
        local rw <const>, rh <const> = GetActiveScreenResolution()
        local base <const> = GetAspectRatio(true)
        local ratio <const> = (16 / 9) / base

        cache:set('rw', rw)
        cache:set('rh', rh)
        cache:set('base', base)
        cache:set('ratio', ratio)

        Wait(5000)
    end
end)

local nativeui = setmetatable({
    registered = {}, ---@type table<string, {id: string, env: string, type: string}>
    current = nil, ---@type string?
    last = nil, ---@type string?
    scaleformGlare = nil, ---@type number?
    exportsMethod = {}, ---@type table<string, boolean>
    queue = {}, ---@type table<number, string>
    path = {
        CreateMenu = '@sublime_nativeui.src.menu.CreateMenu',
        -- CreatePauseMenu = '@sublime_nativeui/src/menu/CreatePauseMenu', -- not implemented!
    }
}, {
    __newindex = function(self, name, value)
        rawset(self, name, value)
        if type(value) == 'function' then
            self.exportsMethod[name] = true
            exports(name, value)
        end
    end
})

---@param id string
---@return table<string, { id: string, env: string, type: string }>
function nativeui.GetMenu(id)
    return nativeui.registered[id]
end

function nativeui.GetAllMenus()
    return nativeui.registered
end

---@return table<string, { rw: number, rh: number, base: number, ratio: number }>
function nativeui.GetCache()
    return cache
end

---@param key string
---@return string
function nativeui.GetPathModule(key)
    return nativeui.path[key]
end

---@return number
function nativeui.RequestGlare()
    if not nativeui.scaleformGlare or not HasScaleformMovieLoaded(nativeui.scaleformGlare) then
        local Promise = promise.new()
        CreateThread(function()
            nativeui.scaleformGlare = RequestScaleformMovie('MP_MENU_GLARE')
            while not HasScaleformMovieLoaded(nativeui.scaleformGlare) do
                Wait(0)
            end
            Promise:resolve(nativeui.scaleformGlare)
        end)
        return await(Promise)
    end
    return nativeui.scaleformGlare
end

---@return table<string, boolean>
function nativeui.GetExportMethod()
    return nativeui.exportsMethod
end

---@return string
function nativeui.CurrentOpen()
    return nativeui.current
end

---@param menu RegisterMenuProps
function nativeui.RegisterMenu(menu)
    if nativeui.registered[menu.id] then
        return  warn(('Menu with id %s already registered in this resource : %s'):format(menu.id, menu.env))
    end

    nativeui.registered[menu.id] = menu
end

---@param menuId string
---@return boolean, string?
local function SearchCloseMenu(menuId)
    local menu <const> = nativeui.registered[menuId]
    local closed <const>, reason <const> = PlayExports(menu.env..'.'..'GoClose', menuId)
    return closed, reason
end

---@param menu table<string, { id: string, env: string, type: string }>
---@param _type string
---@return boolean, string?
local function OpenMenu(menu, _type)
    local opened <const>, reason <const> = PlayExports(menu.env..'.'..'GoOpen', menu.id)
    return opened, reason
end

---@param menuId string
---@param _type? string
---@param clearQueue? boolean
function nativeui.OpenMenu(menuId, _type, clearQueue)
    if not nativeui.registered[menuId] then
        warn(('Menu with id : [%s] not registered'):format(menuId))
        return ---@todo reason when local translation will be implemented
    end

    if nativeui.current == menuId and _type ~= 'GoBack' then
        warn(('Menu [%s] already open'):format(menuId))
        return ---@todo reason when local translation will be implemented
    end

    while action do Wait(0) end
    action = true

    if _type == 'GoBack' then
        if #nativeui.queue > 1 then
            local last <const> = nativeui.queue[#nativeui.queue - 1]
            print('GoBack', last, 'is menu before', menuId)
            local closed <const>, reason <const> = SearchCloseMenu(menuId)   
            if not closed then
                action = false
                warn(('\n\t- Menu id [%s] not closed\n\t- Reason : %s'):format(menuId, reason or 'No reason?'))
                return true, reason
            end
            table.remove(nativeui.queue, #nativeui.queue)
            local menu <const> = nativeui.registered[last]
            local opened <const>, reason <const> = OpenMenu(menu, _type)

            if not opened then
                action = false
                warn(('\n\t- Menu id [%s] not opened\n\t- Reason : %s'):format(menuId, reason or 'No reason?'))
                return opened, reason
            end
            nativeui.last = menuId
            nativeui.current = menu.id
            action = false
            return true
        else
            action = false
            return nativeui.CloseMenu(true)
        end
    end

    if nativeui.current then 
        local closed <const>, reason <const> = SearchCloseMenu(nativeui.current)
        if not closed then
            action = false
            warn(('\n\t- Menu id [%s] not closed\n\t- Reason : %s'):format(menuId, reason or 'No reason?'))
            return closed, reason
        else
            nativeui.last = nativeui.current
        end 
    end

    local menu <const> = nativeui.registered[menuId]
    local opened <const>, reason <const> = OpenMenu(menu, _type)
    if not opened then
        action = false
        warn(('\n\t- Menu id [%s] not opened\n\t- Reason : %s'):format(menuId, reason or 'No reason?'))
        return opened, reason
    end

    nativeui.current = menu.id

    if clearQueue then
        table.wipe(nativeui.queue)
    end

    if not _type then
        nativeui.queue[#nativeui.queue + 1] = menu.id
    end

    action = false
    return true
end

---@param clearQueue boolean
---@return boolean, string?
function nativeui.CloseMenu(clearQueue)
    if not nativeui.current then
        warn('No menu visible')
        return
    end

    while action do Wait(0) end
    action = true

    local closed <const>, reason <const> = SearchCloseMenu(nativeui.current)
    if not closed then
        action = false
        warn(('\n\t- Menu id [%s] not closed\n\t- Reason : %s'):format(nativeui.current, reason or 'No reason?'))
        return closed, reason
    end

    if #nativeui.queue == 1 or clearQueue then
        nativeui.last = nativeui.current
        table.wipe(nativeui.queue)
        nativeui.current = nil
    else
        table.remove(nativeui.queue, #nativeui.queue)
    end

    action = false
    return true
end

function nativeui.OpenLastMenu()
    if nativeui.last then
        nativeui.OpenMenu(nativeui.last)
    end
end

function nativeui.ResetLastMenu()
    nativeui.last = nil
end

---@param id string
function nativeui.DestroyMenu(id)
    if not nativeui.registered[id] then
        warn(('Menu with id [%s] not found'):format(id))
        return 
    end

    if nativeui.current == id then
        warn(('Menu with id [%s] is currently open'):format(id))
        return
    end

    if nativeui.last == id then
        nativeui.last = nil
    end

    PlayExports(nativeui.registered[id].env..'.'..'Destroy', id)
end

---@param name string as resource name
local function OnResourceStop(name)
    for k, v in pairs(nativeui.registered) do
        if v.env == name then
            nativeui.registered[k] = nil

            if nativeui.current == k then
                nativeui.current = nil
            end

            if nativeui.last == k then
                nativeui.last = nil
            end
        end
    end

    if #nativeui.queue > 0 then
        for i = 1, #nativeui.queue do
            local id <const> = nativeui.queue[i]
            if nativeui.registered[id]?.env == name then
                table.remove(nativeui.queue, i)
            end
        end
    end
end

AddEventHandler('onResourceStop', OnResourceStop)

RegisterCommand('cur', function()
    print(nativeui.current, nativeui.last, json.encode(nativeui.queue))
end)

RegisterCommand('debug_sublimeui', function()
    nativeui.current = nil
    nativeui.last = nil
    table.wipe(nativeui.queue)
end)