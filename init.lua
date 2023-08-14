local moduleLoaded = {}

local function load_module(path)
    if moduleLoaded[path] then
        return moduleLoaded[path]
    end

    local module_path <const> = ("%s.lua"):format(path)
    local module_file <const> = LoadResourceFile('sublime_nativeui', module_path)
    if not module_file then
        error("Impossible de chargé le module : "..path)
    end

    moduleLoaded[path] = load(module_file)()
    return moduleLoaded[path]
end

local function call_module(path)
    path = path:gsub('%.', '/')
    local module = load_module(path)
    if not module then
        return error("Le module n'a pas charger : "..path)
    end
    return module
end

require = call_module