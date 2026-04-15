--[=[
    @class destroyed

    A declaration in `new` that calls a function when an element is destroyed.
    
    ```lua
    local destroyed = broid.destroyed
    local new = broid.new

    local element = new("Circle", {
        [destroyed] = function()
            print("Element was destroyed!")
        end
    })
    
    element:Destroy() -- Prints "Element was destroyed!"
    ```
]=]

local destroyed = {}

-- Imports
local symbol = require("broid.modules.symbol")

-- Variables
local classSymbol = symbol.new("destroyed")

function destroyed:__index(Index)
    if Index == "__BROID_INDEX" then
        return classSymbol
    elseif Index == "__BROID_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

return setmetatable({}, destroyed)