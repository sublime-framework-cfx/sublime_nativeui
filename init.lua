
if not _VERSION:find('5.4') then
    error("^1 Vous devez activer Lua 5.4 dans la resources où vous utilisez l'import, (lua54 'yes') dans votre fxmanifest!^0", 2)
end

local s_ui <const> = 'sublime_nativeui'
local service <const> = IsDuplicityVersion() and 'server' or 'client'

if service == 'server' then
    error("^1sublime_nativeui ne peut pas être utilisé dans une ressource serveur!^0", 2)
end

if not GetResourceState(s_ui):find('start') then
    error('^1sublime_nativeui doit être lancé avant cette ressource!^0', 2)
end

local export <const> = exports[s_ui]


local loaded = {}
package = not lib and {
    loaded = setmetatable({}, {
        __index = loaded,
        __newindex = function()  end,
        __metatable = false,
    }),
    path = './?.lua;'
} or package

local _require = require

---@param modname string
---@return unknown?
local function LoadModule(modname)
    if type(modname) ~= 'string' then return end

    local module = loaded[modname]

    if not module then
        if module == false then
            error(("^1circular-dependency occurred when loading module '%s'^0"):format(modname), 2)
        end

        if not modname:find('^@') then
            local success, result = pcall(_require, modname)

            if success then
                loaded[modname] = result
                return result
            end

            local modpath = modname:gsub('%.', '/')

            for path in package.path:gmatch('[^;]+') do
                local scriptPath = path:gsub('?', modpath):gsub('%.+%/+', '')
                local resourceFile = LoadResourceFile(supv.env, scriptPath)

                if resourceFile then
                    loaded[modname] = false
                    scriptPath = ('@@%s/%s'):format(supv.env, scriptPath)

                    local chunk, err = load(resourceFile, scriptPath)

                    if err or not chunk then
                        loaded[modname] = nil
                        return error(err or ("unable to load module '%s'"):format(modname), 3)
                    end

                    module = chunk(modname) or true
                    loaded[modname] = module

                    return module
                end
            end
        else
            local rss, dir = modname:gsub('%.', '/'):match('^(.-)/(.+)$')

            if not rss or not dir then return error('Invalid path format: '..modname, 2) end
            rss, dir = rss:gsub('^@', ''), dir..'.lua'
            local chunk = LoadResourceFile(rss, dir)

            if chunk then
                local scriptPath = ('@@%s/%s'):format(rss, dir)
                local func, err = load(chunk, scriptPath)

                if err or not func then
                    return error(err or ("unable to load module '%s'"):format(modname), 2)
                end

                module = func(modname) or true
                loaded[modname] = module

                return module
            end
        end

        return error(("module '%s' not found"):format(modname), 2)
    end

    return module
end

_r = LoadModule

local function void() end
local function load_module(self, index)
    if self.exportsMethod[index] then return end
    local func, err, dir, data

    for k, v in pairs(self.module) do
        dir = v..'/'..index
        data = LoadResourceFile(s_ui, dir..'.lua')
        if data then break end
    end

    if not data then return end

    local chunk <const> = data

    if chunk then
        func, err = load(chunk, ('@@%s/%s'):format(s_ui, dir))       
        if err then error(("Error to loading modules :\n- From : %s\n - Modules : %s\n - Service : %s\n - Error : %s"):format(dir, index, service, err), 3) end

        local result = func()
        rawset(self, index, result or void)
        return self[index]
    end
end

local function call_module(self, index, ...)
    local module = rawget(self, index)
    if not module then
        self[index] = void
        module = load_module(self, index)
        if not module then
            local function method(...)
                return export[index](nil, ...)
            end
            if not ... then
                self[index] = method
            end
            return method
        end
    end
    return module
end

local nativeui = setmetatable({
    menus = {},
    current = '',
    exportsMethod = export:GetExportMethod(),
    env = GetCurrentResourceName(),
    module = {
        --items = 'src/items', ceci ne compte pas comme des module de nativeui
        --panels = 'src/panels', ceci ne compte pas comme des module de nativeui

        -- il y aura plus un module menupause, scaleform, progressbar etc...
        menu = 'src/menu',
    }
}, {
    __index = call_module,
    __call = call_module,
})

_ENV.nativeui = nativeui
_ENV.void = void