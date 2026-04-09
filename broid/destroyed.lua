-- Author: iGottic

local destroyed = {}

-- Imports
local Symbol = require("broid.modules.symbol")

-- Variables
local ClassSymbol = Symbol.new("destroyed")

function destroyed:__index(Index)
    if Index == "__SEAM_INDEX" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

return setmetatable({}, destroyed)