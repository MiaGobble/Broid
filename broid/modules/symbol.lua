-- Author: iGottic

local Symbol = {}

function Symbol.new(Name)
    local self = newproxy(true)

    getmetatable(self).__tostring = function()
        return Name
    end

    return self
end

return Symbol