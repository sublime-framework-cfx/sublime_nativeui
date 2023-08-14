local sublime_nativeui <const> = 'sublime_nativeui'
local export <const> = exports[sublime_nativeui]

local function load_module(self, index)
    local func, err 
    local dir <const> = ('imports/%s'):format(index)
    local chunk <const> = LoadResourceFile(sublime_nativeui, ('%s.lua'):format(dir))

    if chunk then
        func, err = load(chunk, ('@@%s/%s'):format(sublime_nativeui, index))
        
        if err then error(("Erreur pendant le chargement du module\n- Provenant de : %s\n- Modules : %s\n - Erreur : %s"):format(dir, index, err), 3) end

        local result = func()
        rawset(self, index, result)
        return self[index]
    end
end

local function call_module(self, index, ...)
    local module = rawget(self, index)
    if not module then
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

nativeui = setmetatable({}, {
    __index = call_module,
    __call = call_module
})