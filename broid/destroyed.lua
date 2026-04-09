-- Author: iGottic

local Destroyed = {}

-- Imports
local Symbol = require("broid.modules.symbol")

-- Variables
local ClassSymbol = Symbol.new("Destroyed")

function Destroyed:__index(Index)
    if Index == "__SEAM_INDEX" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

local Meta = setmetatable({}, Destroyed)

return Meta