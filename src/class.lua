local class = {}

local function class.new(prototype)
    local self = {
        __index = prototype
    }

    function self.new(obj)
        return setmetatable(obj, self)
    end

    return self
end

return class