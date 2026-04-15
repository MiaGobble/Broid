--[=[
    @class tags

    A declaration used in `new` for declaring tags on an element, which can be retrieved with `element:GetTags()`

    ```lua
    local new = broid.new
    local tags = broid.tags

    local circle = new("circle", {
        [tags] = {"x", "y", "z"}
    })
    
    print(circle:GetTags()[1]) -- "x"
    ```
]=]

local tags = {}

-- Imports
local symbol = require("broid.modules.symbol")

-- Variables
local classSymbol = symbol.new("tags")

function tags:__index(Index)
    if Index == "__BROID_INDEX" then
        return classSymbol
    elseif Index == "__BROID_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

return setmetatable({}, tags)