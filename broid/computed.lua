-- Author: iGottic

local computed = {}

-- Imports
local modules = "broid.modules"
local bucket = require(modules .. ".bucket")
local signal = require(modules .. ".signal")
local symbol = require(modules .. ".symbol")
local getValue = require("broid.getValue")
local isState = require("broid.isState")

-- Variables
local classSymbol = symbol.new("computed")

function computed:__call(callback)
    -- This shit has caused me so much pain
    local bucketInstance = bucket.new()
    local changedSignal = signal.new()
    local usedValues = {}
    local currentValue = nil
    local isInitialized = false
    local attachedSignal = signal.new()
    local instanceSymbol = symbol.new("computedInstance")

    local function use(thisValue)
        -- Is use connecting to a state? If not, just get the value

        if thisValue ~= nil and isState(thisValue) then
            if usedValues[thisValue] ~= nil then
                return getValue(usedValues[thisValue])
            end

            usedValues[thisValue] = thisValue

            bucketInstance:Add(thisValue.changed:Connect(function()
                currentValue = callback(use)
                changedSignal:Fire("value", currentValue) -- When the state changes, fire the changed signal for computed
            end))
        end

        return getValue(thisValue)
    end

    local activeComputation; activeComputation = setmetatable({
        Destroy = function()
            bucketInstance:Destroy()
        end,
    }, {
        __index = function(_, index)
            if index == "__BROID_OBJECT" then
                return instanceSymbol
            elseif index == "value" then
                -- Same as above, let's not re-calculate

                if not isInitialized then
                    currentValue = callback(use)
                    isInitialized = true
                end

                return currentValue
            elseif index == "changed" then
                -- We need to connect the use() functions here to track changes

                if not isInitialized then
                    currentValue = callback(use)
                    isInitialized = true
                end

                return changedSignal
            elseif index == "attachedToInstance" then
                return attachedSignal
            end

            return nil
        end
    })

    return activeComputation
end

function computed:__index(key)
    if key == "__BROID_INDEX" then
        return classSymbol
    elseif key == "__BROID_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

return setmetatable({}, computed)