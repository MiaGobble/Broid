--[=[
    @class lifetime

    A utility for managing the lifetime of objects. When the end of the lifetime is reached, element:Destroy() is called.

    ```lua
    local lifetime = broid.lifetime
    local new = broid.new

    local element = new("Circle", {
        [lifetime] = 5, -- Lifetime of 5 seconds
    })
    ```
]=]

local lifetime = {}

-- Imports
local symbol = require("broid.modules.symbol")

-- Variables
local classSymbol = symbol.new("lifetime")

function lifetime:__index(Index)
    if Index == "__BROID_INDEX" then
        return classSymbol
    elseif Index == "__BROID_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, lifetime)

return Meta