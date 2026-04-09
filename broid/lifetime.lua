-- Author: iGottic

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