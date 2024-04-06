
if not _VERSION:find('5.4') then
    error("^1 Vous devez activer Lua 5.4 dans la resources où vous utilisez l'import, (lua54 'yes') dans votre fxmanifest!^0", 2)
end

local s_ui <const> = 'sublime_nativeui'
local service <const> = IsDuplicityVersion() and 'server' or 'client'

-- if not GetResourceState(s_ui):find('start') then
-- 	error('^1sublime_nativeui doit être lancé avant cette ressource!^0', 2)
-- end

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

local mt_pvt = {
    __metatable = 'private',
    __ext = 0,
    __pack = function() return '' end,
}

---@param obj table
---@return table
local function NewInstance(self, obj)
    if obj.private then
        setmetatable(obj.private, mt_pvt)
    end

    setmetatable(obj, self)

    if self.Init then obj:Init() end

    if obj.export then
        self.__export[obj.export] = obj
    end

    return obj
end

---@param name string
---@param super? table
---@param exportMethod? boolean
---@return table
local function class(name, super, exportMethod)
    local self = {
        __name = name,
        new = NewInstance
    }

    self.__index = self

    if exportMethod and not super then
        self.__exportMethod = {}
        self.__export = {}

        setmetatable(self, {
            __newindex = function(_, key, value)
                rawset(_, key, value)
                self.__exportMethod[key] = true
            end
        })

        exports('GetExportMethod', function()
            return self.__exportMethod
        end)

        exports('CallExportMethod', function(name, method, ...)
            local export <const> = self.__export[name]
            return export[method](export, ...)
        end)
    end
    
    return super and setmetatable(self, {
        __index = super,
        __newindex = function(_, key, value)
            rawset(_, key, value)
            if type(value) == 'function' then
                if self.__exportMethod then
                    self.__exportMethod[key] = true
                end
            end
        end
    }) or self
end

local ExportMethod, MyClassExport = {}, {}

local function exportsClass(resource, name, prototype)
    ExportMethod[name] = {}
    setmetatable(ExportMethod[name], {
        __index = function(_, index)
            ExportMethod[name] = exports[resource]:GetExportMethod(index)
            return ExportMethod[name][index]
        end
    })

    MyClassExport[name] = {}
    local Class = MyClassExport[name]
    function Class:__index(index)
        local method = MyClassExport[name][index]

        if method then
            return function(...)
                return method(self, ...)
            end
        end

        local export = ExportMethod[name][index]

        if export then
            return function(...)
                return exports[resource]:CallExportMethod(name, index, ...)
            end
        end
    end

    return setmetatable(prototype or {}, Class)
end

function void() end

local function call_module(self, index, ...)
    local module = rawget(self, index)
    if not module then
        self[index] = void
        module = _r('@sublime_nativeui.src.items.'..index)
        if not module then
            return warn(('module %s not found'):format(index))
        end
        self[index] = module
    end
    return module
end

local nativeui = class('nativeui')

_ENV.nativeui = nativeui

local Menus = {}

function nativeui:Init()
    print(self.id)
    self.opened = false
    
    if not self.isSub then
        self.submenu = {}
        exports[s_ui]:RegisterMenu({
            id = self.id,
            env = GetCurrentResourceName(),
            submenu = self.submenu,
        })
    end

    self.items = setmetatable({
        size = 0,
    }, {
        __index = call_module,
        __call = call_module,
    })

    Menus[self.id] = self
end

function nativeui:destroy()
    Menus[self.id] = nil
end

function nativeui:Open()
    local current = exports[s_ui]:CurrentOpen()
    if current then
        if current == self.id then return end
        exports[s_ui]:CloseMenu()
    end
    if self.opened then return end
    
    --if exports[s_ui]:() then return end
    self.opened = true
    self:GoPool()
end

function nativeui:AddSubMenu(_menu)
    if self.submenu[_menu.id] then return end
    _menu.isSub = true
    self.submenu[_menu.id] = nativeui:new(_menu, self)
    exports[s_ui]:UpdateMenu(self.id, _menu.id)
    return self.submenu[_menu.id]
end

function nativeui:Close()
    if not self.opened then return end
    self.opened = false
    --self:onClose()
end

function nativeui.CloseAll()
    if exports[s_ui]:CurrentOpen() then
        exports[s_ui]:CloseMenu()
        return nil
    end
end

function nativeui:isOpen()
    return self.opened
end

function nativeui:GoPool()
    CreateThread(function()
        while self.opened do
            self.items.size = 0
            self:pool(self.items)
            DrawRect(0.5, 0.5, self.width or .2, 0.2, self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4])
            Wait(0)
        end
    end)
end

local function OpenMenu(id)
   if Menus[id] then
       Menus[id]:Open()
   end 
end

local function CloseMenu(id)
    if Menus[id] then
        Menus[id]:Close()
        return nil
    end
end

exports('OpenMenu', OpenMenu)
exports('CloseMenu', CloseMenu)