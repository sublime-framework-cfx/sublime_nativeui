
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

-- [fr]: Pas besoin de réécrire la fonction require si un des ses objets existe | [en]: No need to rewrite the require function if one of its objects exists 
if not supv and not lib and not sublime then
    local loaded = {}
    package = {
        loaded = setmetatable({}, {
            __index = loaded,
            __newindex = function()  end,
            __metatable = false,
        }),
        path = './?.lua;'
    }

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
                    local resourceFile = LoadResourceFile(nativeui.env, scriptPath)

                    if resourceFile then
                        loaded[modname] = false
                        scriptPath = ('@@%s/%s'):format(nativeui.env, scriptPath)

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

    require = LoadModule
end

if not supv and not sublime then
    local function void() end
    _ENV.void = void
else
    _ENV.void = void
end

local function call_module(self, index, ...)
    local module = rawget(self, index)
    -- print('module', module, index, ...)

    if not module then
        self[index] = void

        if self.exportsMethod[index] then
            local function method(...)
                return export[index](nil, ...)
            end

            if not ... then
                self[index] = method
            end

            return method
        else
            local path <const> = export:GetPathModule(index)
            if not path then
                error(('module %s not found'):format(index), 2)
                return 
            end

            module = require(path)
            
            --[[@? no need that for now
                if not ... then
                    module = require(path)
                else
                    module = require(path)(...)
                end
            --]]

            rawset(self, index, module)
        end
    end

    return module
end

local nativeui = setmetatable({
    menus = {},
    current = '',
    exportsMethod = export:GetExportMethod(),
    env = GetCurrentResourceName(),
}, {
    __index = call_module,
    __call = call_module,
})

_ENV.nativeui = nativeui