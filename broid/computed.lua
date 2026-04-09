-- Author: iGottic

local Computed = {}

-- Imports
local modules = "broid.modules"
local bucket = require(modules .. ".bucket")
local Signal = require(modules .. ".signal")
local Symbol = require(modules .. ".symbol")
local GetValue = require("broid.getValue")
local IsState = require("broid.isState")

-- Variables
local ClassSymbol = Symbol.new("Computed")

function Computed:__call(Callback)
    -- This shit has caused me so much pain
    local TroveInstance = bucket.new()
    local ChangedSignal = Signal.new()
    local UsedValues = {}
    local CurrentValue = nil
    local IsInitialized = false
    local AttachedSignal = Signal.new()
    local InstanceSymbol = Symbol.new("ComputedInstance")

    local function Use(ThisValue)
        -- Is Use connecting to a state? If not, just get the value

        if ThisValue ~= nil and IsState(ThisValue) then
            if UsedValues[ThisValue] ~= nil then
                return GetValue(UsedValues[ThisValue])
            end

            UsedValues[ThisValue] = ThisValue

            TroveInstance:Add(ThisValue.Changed:Connect(function()
                CurrentValue = Callback(Use)
                ChangedSignal:Fire("Value", CurrentValue) -- When the state changes, fire the changed signal for computed
            end))
        end

        return GetValue(ThisValue)
    end

    local ActiveComputation; ActiveComputation = setmetatable({
        Destroy = function()
            TroveInstance:Destroy()
        end,
    }, {
        __index = function(_, Index)
            if Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            elseif Index == "Value" then
                -- Same as above, let's not re-calculate

                if not IsInitialized then
                    CurrentValue = Callback(Use)
                    IsInitialized = true
                end

                return CurrentValue
            elseif Index == "Changed" then
                -- We need to connect the Use() functions here to track changes

                if not IsInitialized then
                    CurrentValue = Callback(Use)
                    IsInitialized = true
                end

                return ChangedSignal
            elseif Index == "AttachedToInstance" then
                return AttachedSignal
            end

            return nil
        end
    })

    return ActiveComputation
end

function Computed:__index(Key)
    if Key == "__SEAM_INDEX" then
        return ClassSymbol
    elseif Key == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Computed)

return Meta