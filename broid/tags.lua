-- Author: iGottic

local tags = {}

-- Imports
local symbol = require("broid.modules.symbol")

-- Variables
local classSymbol = symbol.new("tags")

function tags:__index(Index)
    if Index == "__SEAM_INDEX" then
        return classSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return false
    else
        return nil
    end
end

return setmetatable({}, tags)