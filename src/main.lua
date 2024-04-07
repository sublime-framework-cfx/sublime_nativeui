local function PlayExports(export, ...)
    local resourceName <const> = export:match('(.+)%..+')
    local methodName <const> = export:match('.+%.(.+)')
    return exports[resourceName][methodName](nil, ...)
end

local nativeui = setmetatable({
    registered = {},
    current = '',
    last = '',
    exportsMethod = {}
}, {
    __newindex = function(self, name, value)
        rawset(self, name, value)
        if type(value) == 'function' then
            self.exportsMethod[name] = true
            exports(name, value)
        end
    end
})

function nativeui.GetExportMethod()
    return nativeui.exportsMethod
end

---@param menu RegisterMenuProps
function nativeui.RegisterMenu(menu)
    if nativeui.registered[menu.id] then
        return  warn(('Menu with id %s already registered in this resource : %s'):format(menu.id, menu.env))
    end

    nativeui.registered[menu.id] = menu
end

---@param id string
---@param subId? string
function nativeui.OpenMenu(id)
    if not nativeui.registered[id] then
        return warn(('Menu with id %s not registered'):format(id))
    end

    if nativeui.current and #nativeui.current > 0 then
        local menu <const> = nativeui.registered[nativeui.current]
        local exp <const> = menu.env..'.'..'CloseMenu'
        PlayExports(exp, id)
    end

    local menu <const> = nativeui.registered[id]
    local exp <const> = menu.env..'.'..'OpenMenu'
    local opened = PlayExports(exp, id)

    nativeui.current = opened
end

function nativeui.CloseMenu()
    if not nativeui.current or #nativeui.current == 0 then
        return warn('No menu visible')
    end

    local menu <const> = nativeui.registered[nativeui.current]
    local exp <const> = menu.env..'.'..'CloseMenu'
    nativeui.current = PlayExports(exp, nativeui.current)
    nativeui.current = ''
end

---@return string
function nativeui.CurrentOpen()
    return (nativeui.current and #nativeui.current > 0) and nativeui.current or ''
end

---@param id string
---@param subId string
function nativeui.UpdateMenu(id, subId)
    if not nativeui.registered[id] then
        return warn(('Menu with id %s not registered'):format(id))
    end

    if nativeui.registered[id].submenu[subId] then
        return warn(('Submenu with id %s not registered in menu %s'):format(subId, id))
    end

    nativeui.registered[id].submenu[subId] = subId
end

function nativeui.SetVisible(id)
    nativeui.current = id
    print(id, #id)
    if #id > 0 then
        nativeui.last = id
    end
end

function nativeui.GetParent(id)
    for k, v in pairs(nativeui.registered) do
        if v.submenu[id] then
            return k
        end
    end

    return false
end

function nativeui.OpenLastMenu()
    if #nativeui.last > 0 then
        print(nativeui.last, nativeui.current)
        if (nativeui.current and #nativeui.current > 0) and (nativeui.current == nativeui.last) then
            return warn('Menu already open')
        end
        nativeui.OpenMenu(nativeui.last)
    end
end

RegisterCommand('lok', function()
    print(json.encode(nativeui.registered, {indent = true}))
end)

RegisterCommand('ook', function()
    print(nativeui.current)
    if not nativeui.current or #nativeui.current == 0 then
        nativeui.OpenMenu('sub')
    else
        nativeui.current = nativeui.CloseMenu()
    end
end)