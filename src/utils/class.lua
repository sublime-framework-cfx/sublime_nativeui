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
    return obj
end

---@param name string
---@param super? table
---@return table
local function class(name, super)
    local self = {
        __name = name,
        new = NewInstance
    }

    self.__index = self
    return super and setmetatable(self, { __index = super }) or self
end

return class