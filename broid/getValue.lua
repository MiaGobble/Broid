-- Author: iGottic

local getValue = {}

-- Imports
local isState = require("broid.isState")

function getValue:__call(state)
    -- Nothing exists? No problem.
    if state == nil then
        return nil
    end

    -- Is it a state? Return the value of that state.
    if isState(state) then
        return state.value
    end

    -- Just normal userdata? That's cool too.
    return state
end

function getValue:__index(key)
    if key == "__BROID_CAN_BE_SCOPED" then
        return false
    end

    return nil
end

local Meta = setmetatable({}, getValue)

return Meta