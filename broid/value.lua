-- Author: iGottic

local Value = {}

-- Imports
local modules = "broid.modules"
local bucket = require(modules .. ".bucket")
local Signal = require(modules .. ".signal")
local IsValueChanged = require(modules .. ".isValueChanged")
local Symbol = require(modules .. ".symbol")

-- Variables
local ClassSymbol = Symbol.new("Value")

function Value:__call(ThisValue)
    local bucketInstance = bucket.new()
    local ChangedSignal = Signal.new()
    local AttachedSignal = Signal.new()
    local InstanceSymbol = Symbol.new("Value")
    local IsLocked = false
    local ValueType = ThisValue ~= nil and type(ThisValue) or nil

    --[[
        local This = Value(...)
        This.Value = x OR x = This.Value
        This.Changed -> As rbxscriptsignal
    --]]

    local ActiveValue; ActiveValue = setmetatable({
        Destroy = function()
            bucketInstance:Destroy()
        end
    }, {
        __index = function(_, Index)
            if Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            elseif Index == "Value" then
                return ThisValue
            elseif Index == "Changed" then
                return ChangedSignal
            elseif Index == "AttachedToInstance" then
                return AttachedSignal
            end

            return nil
        end,

        __newindex = function(_, Index, NewValue)
            if Index == "Value" then
                if IsLocked then
                    error("Attempt to modify value when locked.")
                end

                if ValueType ~= nil then
                    if NewValue ~= nil and type(NewValue) ~= ValueType then
                        error("Invalid value type! Expected " .. ValueType .. ", got " .. type(NewValue))
                    end
                elseif NewValue ~= nil then
                    ValueType = type(NewValue)
                end

                if not IsValueChanged(ThisValue, NewValue) then
                    return
                end

                ThisValue = NewValue

                -- Make sure to fire the changed signal for other states
                ChangedSignal:Fire("Value", ThisValue)
                return
            elseif Index == "__LOCKED" then
                if NewValue == true then
                    IsLocked = true
                    ActiveValue:Destroy()
                    return
                else
                    error("Can not unlock values.")
                end
            else
                error("Ran into an unexpected error")
            end
        end,
    })

    return ActiveValue
end

function Value:__index(Index)
    if Index == "__SEAM_INDEX" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Value)

return Meta