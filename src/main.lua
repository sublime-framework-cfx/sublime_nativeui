local cache, await <const> = {
    rw = 0,
    rh = 0,
    base = 0,
    ratio = 0
}, Citizen.Await

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
    },
    action = false,
}, {
    __newindex = function(self, name, value)
        rawset(self, name, value)
        if type(value) == 'function' then
            self.exportsMethod[name] = true
            exports(name, value)
        end
    end
})

local function async(func)
    local p = promise.new()
    CreateThread(function()
        func(function(value)
            p:resolve(value)
        end, function(err)
            p:reject(err)
        end)
    end)
    return p
end

-- TriggerEvent obligatoirement quand on ouvre un menu
AddEventHandler('sublime_nativeui:open', function(id, clearQueue)
    if nativeui.action then return end
    nativeui.action = true

    local menu = nativeui.registered[id]

    if not menu then
        nativeui.action = false
        return warn(('Menu with id [%s] not found [%s]'):format(id, 'sublime_nativeui'))
    end

    if nativeui.current == id then
        local menuOpened = nativeui.registered[nativeui.current]
        if menuOpened then
            ---@todo I keep this for now to force auto debug if people try to bug the system
            local result = await(async(function(resolve, reject)
                TriggerEvent('sublime_nativeui:close:' .. menuOpened.env, menuOpened.id, resolve)
            end))

            if not result then
                nativeui.action = false
                nativeui.current = nil
                return warn(('Menu with id [%s] not closed???'):format(nativeui.current))
            end
        end

        nativeui.current = nil
        nativeui.action = false
        return warn(('Menu with id [%s] already open [%s]'):format(id, 'sublime_nativeui'))
    end

    if nativeui.last == id then
        nativeui.last = nil
    end

    if nativeui.current then
        local menuOpened = nativeui.registered[nativeui.current]
        if menuOpened then
            local result = await(async(function(resolve, reject)
                TriggerEvent('sublime_nativeui:close:' .. menuOpened.env, menuOpened.id, resolve)
            end))

            if not result then
                nativeui.action = false
                return warn(('Menu with id [%s] not closed'):format(nativeui.current))
            end
        end
    end

    local opened = await(async(function(resolve, reject)
        TriggerEvent('sublime_nativeui:open:' .. menu.env, menu.id, resolve)
    end))

    if not opened then
        nativeui.action = false
        return warn(('Menu with id [%s] not opened'):format(id))
    end

    if clearQueue then
        table.wipe(nativeui.queue)
    end

    local idQueue = #nativeui.queue + 1

    nativeui.queue[idQueue] = id
    nativeui.current = id
    LocalPlayer.state:set('menuOpen', id, false)
    nativeui.action = false
end)

-- Trigger obligatoirement quand on ferme un menu GoBack ou non
AddEventHandler('sublime_nativeui:close', function(id, back, clearQueue)
    if nativeui.action then return end
    nativeui.action = true

    local menu = nativeui.registered[id]

    if not menu then
        nativeui.action = false
        return warn(('Menu with id [%s] not found'):format(id))
    end

    if nativeui.current ~= id then
        nativeui.action = false
        return warn(('Menu with id [%s] not open'):format(id))
    end

    local result = await(async(function(resolve, reject)
        TriggerEvent('sublime_nativeui:close:' .. menu.env, menu.id, resolve)
    end))

    if not result then
        nativeui.action = false
        return warn(('Menu with id [%s] not closed'):format(id))
    end

    if back and #nativeui.queue > 1 then
        local last = nativeui.queue[#nativeui.queue - 1]
        local menuLast = nativeui.registered[last]

        if menuLast then
            local opened = await(async(function(resolve, reject)
                TriggerEvent('sublime_nativeui:open:' .. menuLast.env, menuLast.id, resolve)
            end))

            if not opened then
                nativeui.action = false
                return warn(('Menu with id [%s] not opened'):format(last))
            end

            nativeui.last = id
            table.remove(nativeui.queue, #nativeui.queue)
            nativeui.current = last
            LocalPlayer.state:set('menuOpen', last, false)
        end
        nativeui.action = false
        return
    end

    if clearQueue or #nativeui.queue == 1 then
        table.wipe(nativeui.queue)
    end

    nativeui.last = id
    nativeui.current = nil
    LocalPlayer.state:set('menuOpen', nil, false)
    nativeui.action = false
end)

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

---@param id string
---@return table<{ id: string, env: string, type: string }>
function nativeui.GetMenu(id)
    return nativeui.registered[id]
end

---@return table<string, { id: string, env: string, type: string }>
function nativeui.GetAllMenus()
    return nativeui.registered
end

---@return table<string, { rw: number, rh: number, base: number, ratio: number, playerid?: number }>
function nativeui.GetCache()
    return cache
end

---@param key string
---@return string
function nativeui.GetPathModule(key)
    return nativeui.path[key]
end

---@return void
function nativeui.ResetLastMenu()
    nativeui.last = nil
end

---@return table<string, boolean>
function nativeui.GetExportMethod()
    return nativeui.exportsMethod
end

---@param fromBag? boolean
---@return string?
function nativeui.CurrentOpen(fromBag)
    return fromBag and LocalPlayer.state.menuOpen or nativeui.current 
end

---@param menu RegisterMenuProps
---@return void
function nativeui.RegisterMenu(menu)
    if nativeui.registered[menu.id] then
        return warn(('Menu with id %s already registered in this resource : %s'):format(menu.id, menu.env))
    end

    nativeui.registered[menu.id] = menu
end

---@param id string
---@param clearQueue? boolean
---@return void
function nativeui.OpenMenu(id, clearQueue) ---@todo don't use it for now!
    if nativeui.action then return end
    local menu = nativeui.registered[id]
    if not menu then
        return warn(('Menu with id %s not found'):format(id))
    end

    --TriggerEvent('sublime_nativeui:open', id, clearQueue)
end

---@param id? string
---@param back? boolean
---@param clearQueue? boolean
---@return void
function nativeui.CloseMenu(id, back, clearQueue) ---@todo don't use it for now!
    if nativeui.action then return end
    local menu = nativeui.registered[id]
    if not menu then
        return warn(('Menu with id %s not found'):format(id))
    end

    --TriggerEvent('sublime_nativeui:close', id, back, clearQueue)
end

---@return void
function nativeui.OpenLastMenu() ---@todo don't use it for now!
    if nativeui.last then
        nativeui.OpenMenu(nativeui.last)
    end
end

---@param menu string|table<{ id: string, env: string, type: string }>
---@return void
function nativeui.DeleteMenu(menu) ---@todo don't use it for now!
    local id = type(menu) == 'table' and menu.id or menu
    if not nativeui.registered[id] then
        return warn(('Menu with id %s not found in this resource : %s'):format(id, menu?.env))
    end

    nativeui.registered[id] = nil
end

---@param name string as resource name
local function OnResourceStop(name)
    for k, v in pairs(nativeui.registered) do
        if v.env == name then
            nativeui.registered[k] = nil

            if LocalPlayer.state.menuOpen == k then
                LocalPlayer.state:set('menuOpen', nil, false)
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

    -- LocalPlayer.state:set('menuOpen', nil, false)
end

AddEventHandler('onResourceStop', OnResourceStop)
--[[

-- Old work

---@param export string
---@param ... unknown
---@return unknown
local function PlayExports(export, ...)
    local resourceName <const> = export:match('(.+)%..+')
    local methodName <const> = export:match('.+%.(.+)')
    return exports[resourceName][methodName](nil, ...)
end


local size = 0
AddStateBagChangeHandler('menuOpen', nil, function(bagName, key, value, reserved, replicated)
    if replicated then return end
    if not cache.playerid then
        cache:set('playerid', PlayerId())
    end
    local ply = GetPlayerFromStateBagName(bagName)
    if ply ~= cache.playerid then return end
    if not value then
        local last = #nativeui.queue > 0 and nativeui.queue[#nativeui.queue] or nil
        if last == LocalPlayer.state.menuOpen then
            table.remove(nativeui.queue, #nativeui.queue)
            last = #nativeui.queue > 0 and nativeui.queue[#nativeui.queue] or nil
            if last then
                local menu = nativeui.registered[last]
                if not menu then return end
                LocalPlayer.state:set('menuOpen', menu.id, false)
            end
            return
        end
        return
    else
        local menu = nativeui.registered[value]
        if not menu then return end
        if #nativeui.queue > 0 then
            local last = nativeui.queue[#nativeui.queue]
            if last == menu.id then
                return
            end
        end
        nativeui.queue[#nativeui.queue + 1] = menu.id
    end
end)
@param id string
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
 ---@param menuId string
---@return boolean, string?
local function SearchCloseMenu(menuId)
    local menu <const> = nativeui.registered[menuId]
    if not menu then return false end
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
    while action do Wait(50) end
    action = true
    if nativeui.current == menuId and _type ~= 'GoBack' then
        warn(('Menu [%s] already open'):format(menuId))
        nativeui.CloseMenu(true)
        action = false
        table.wipe(nativeui.queue)
        --nativeui.current = nil
        nativeui.last = nil
        LocalPlayer.state:set('menuOpen', nil, false)
        return ---@todo reason when local translation will be implemented
    end
    if _type == 'GoBack' then
        if #nativeui.queue > 1 then
            local last <const> = nativeui.queue[#nativeui.queue - 1]
            -- print('GoBack', last, 'is menu before', menuId)
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
             --nativeui.current = menu.id
             LocalPlayer.state:set('menuOpen', menu.id, false)
             action = false
             return true
         else
             action = false
             LocalPlayer.state:set('menuOpen', nil, false)
             return nativeui.CloseMenu(true)
         end
     end
     if LocalPlayer.state.menuOpen then
         local closed <const>, reason <const> = SearchCloseMenu(LocalPlayer.state.menuOpen)
         if not closed then
             action = false
             warn(('\n\t- Menu id [%s] not closed\n\t- Reason : %s'):format(menuId, reason or 'No reason?'))
             return closed, reason
         else
             nativeui.last = LocalPlayer.state.menuOpen
             --LocalPlayer.state:set('menuOpen', nil, false)
         end
     end
     local menu <const> = nativeui.registered[menuId]
     local opened <const>, reason <const> = OpenMenu(menu, _type)
     if not opened then
         action = false
         warn(('\n\t- Menu id [%s] not opened\n\t- Reason : %s'):format(menuId, reason or 'No reason?'))
         return opened, reason
     end
     LocalPlayer.state:set('menuOpen', menu.id, false)
     --nativeui.current = menu.id
     if clearQueue then
         table.wipe(nativeui.queue)
     end
     if not _type then
         if #nativeui.queue > 0 then
             local last <const> = nativeui.queue[#nativeui.queue]
             if last == menu.id then
                 table.remove(nativeui.queue, #nativeui.queue)
             end
         end
         nativeui.queue[#nativeui.queue + 1] = menu.id
     end
     action = false
     return true
 end
 ---@param clearQueue boolean
 ---@return boolean, string?
 function nativeui.CloseMenu(clearQueue)
     while action do Wait(0) end
     -- if not LocalPlayer.state.menuOpen then
     --     warn('No menu visible')
     --     return
     -- end
     action = true
     local closed <const>, reason <const> = SearchCloseMenu(LocalPlayer.state.menuOpen)
     -- if not closed then
     --     action = false
     --     warn(('\n\t- Menu id [%s] not closed\n\t- Reason : %s'):format(LocalPlayer.state.menuOpen, reason or 'No reason?'))
     --     return closed, reason
     -- end
     if closed then
         if #nativeui.queue == 1 or clearQueue then
             nativeui.last = nativeui.current
             table.wipe(nativeui.queue)
             nativeui.current = nil
             LocalPlayer.state:set('menuOpen', nil, false)
         else
             table.remove(nativeui.queue, #nativeui.queue)
         end
     end
     LocalPlayer.state:set('menuOpen', nil, false)
     action = false
     return true
 end
 function nativeui.OpenLastMenu()
     if nativeui.last then
         nativeui.OpenMenu(nativeui.last)
     end
 end
]]