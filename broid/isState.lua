-- Author: iGottic

local isState = {}

-- Constants
local RECOGNIZED_STATE_SYMBOLS = {"spring", "computedInstance", "renderedInstance", "value"}

function isState:__call(checkedValue)
    if type(checkedValue) ~= "table" then
        return false -- Not a state since it's not a table
    end

    if not checkedValue.__SEAM_OBJECT then
        return false -- Not a state since it's not from Seam or not a Seam object
    end

    for _, value in pairs(RECOGNIZED_STATE_SYMBOLS) do
        if value == tostring(checkedValue.__SEAM_OBJECT) then
            return true
        end
    end

    return false -- Default to false
end

function isState:__index(key)
    if key == "__SEAM_CAN_BE_SCOPED" then
        return false
    end

    return nil
end

return setmetatable({}, isState)