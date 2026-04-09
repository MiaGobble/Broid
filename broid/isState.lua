-- Author: iGottic

local IsState = {}

-- Constants
local RECOGNIZED_STATE_SYMBOLS = {"Spring", "Tween", "ComputedInstance", "RenderedInstance", "Value"}

function IsState:__call(CheckedValue)
    if type(CheckedValue) ~= "table" then
        return false -- Not a state since it's not a table
    end

    if not CheckedValue.__SEAM_OBJECT then
        return false -- Not a state since it's not from Seam or not a Seam object
    end

    for _, value in pairs(RECOGNIZED_STATE_SYMBOLS) do
        if value == tostring(CheckedValue.__SEAM_OBJECT) then
            return true
        end
    end

    return false -- Default to false
end

function IsState:__index(Key)
    if Key == "__SEAM_CAN_BE_SCOPED" then
        return false
    end

    return nil
end

local Meta = setmetatable({}, IsState)

return Meta