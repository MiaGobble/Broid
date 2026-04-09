-- Author: iGottic
local value = {}

-- Imports
local modules = "broid.modules"
local bucket = require(modules .. ".bucket")
local signal = require(modules .. ".signal")
local isValueChanged = require(modules .. ".isValueChanged")
local symbol = require(modules .. ".symbol")

-- Variables
local classSymbol = symbol.new("value")

function value:__call(initialValue)
    local bucketInstance = bucket.new()
    local changedSignal = signal.new()
    local attachedSignal = signal.new()
    local instanceSymbol = symbol.new("value")
    local isLocked = false
    local valueType = initialValue ~= nil and type(initialValue) or nil

    local activeValue; activeValue = setmetatable({
        Destroy = function()
            bucketInstance:Destroy()
        end
    }, {
        __index = function(_, index)
            if index == "__SEAM_OBJECT" then
                return instanceSymbol
            elseif index == "value" then
                return initialValue
            elseif index == "changed" then
                return changedSignal
            elseif index == "attachedToInstance" then
                return attachedSignal
            end

            return nil
        end,

        __newindex = function(_, index, newValue)
            if index == "value" then
                if isLocked then
                    error("Attempt to modify value when locked.")
                end

                if valueType ~= nil then
                    if newValue ~= nil and type(newValue) ~= valueType then
                        error("Invalid value type! Expected " .. valueType .. ", got " .. type(newValue))
                    end
                elseif newValue ~= nil then
                    valueType = type(newValue)
                end

                if not isValueChanged(initialValue, newValue) then
                    return
                end

                initialValue = newValue

                -- Make sure to fire the changed signal for other states
                changedSignal:Fire("value", initialValue)
                return
            elseif index == "__locked" then
                if newValue == true then
                    isLocked = true
                    activeValue:destroy()
                    return
                else
                    error("Can not unlock values.")
                end
            else
                error("Ran into an unexpected error")
            end
        end,
    })

    return activeValue
end

function value:__index(index)
    if index == "__SEAM_INDEX" then
        return classSymbol
    elseif index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

return setmetatable({}, value)