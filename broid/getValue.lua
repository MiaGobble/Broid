-- Author: iGottic

local GetValue = {}

-- Imports
local IsState = require("broid.isState")

function GetValue:__call(State)
    -- Nothing exists? No problem.
    if State == nil then
        return nil
    end

    -- Is it a state? Return the value of that state.
    if IsState(State) then
        return State.Value
    end

    -- Just normal userdata? That's cool too.
    return State
end

function GetValue:__index(Key)
    if Key == "__SEAM_CAN_BE_SCOPED" then
        return false
    end

    return nil
end

local Meta = setmetatable({}, GetValue)

return Meta