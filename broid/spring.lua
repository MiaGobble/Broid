-- Author: iGottic

local Spring = {}

-- Constants
local EPSILON = 0.001

-- Imports
local modules = "broid.modules"
local GetValue = require("broid.getValue")
local drawCache = require("broid.drawCache")
local ValuePacker = require(modules .. ".valuePacker")
local Signal = require(modules .. ".signal")
local IsValueChanged = require(modules .. ".isValueChanged")
local Symbol = require(modules .. ".symbol")

-- Variables
local ClassSymbol = Symbol.new("Spring")

local function GetPositionAndVelocity(OldPosition, OldVelocity, Target, Dampening, Speed, TimeStarted)
    local TimePassed = os.clock() - TimeStarted
    local TimeValue = TimePassed * Speed
    local DampeningSquared = Dampening ^ 2
    local HighSpeedTime = nil
    local Cosine = nil
    local Sine = nil

    if DampeningSquared < 1 then
        -- Under dampened

        HighSpeedTime = (1 - DampeningSquared) ^ 0.5

        local EulersFastTime = math.exp(-Dampening * TimeValue) / HighSpeedTime
        Cosine = EulersFastTime * math.cos(HighSpeedTime * TimeValue)
        Sine = EulersFastTime * math.sin(HighSpeedTime * TimeValue)
    elseif DampeningSquared == 1 then
        -- Critically dampened

        HighSpeedTime = 1

        local EulersFastTime = math.exp(-Dampening * TimeValue)
        Cosine = EulersFastTime
        Sine = EulersFastTime * TimeValue
    else
        -- Over dampened

        HighSpeedTime = (DampeningSquared - 1) ^ 0.5
        Cosine = math.exp((-Dampening + HighSpeedTime) * TimeValue) / (2 * HighSpeedTime) + math.exp((-Dampening - HighSpeedTime) * TimeValue) / (2 * HighSpeedTime)
        Sine = math.exp((-Dampening + HighSpeedTime) * TimeValue) / (2 * HighSpeedTime) - math.exp((-Dampening - HighSpeedTime) * TimeValue) / (2 * HighSpeedTime)
    end

    local Value0 = {
        HighSpeedTime * Cosine + Dampening * Sine,
        1 - (HighSpeedTime * Cosine + Dampening * Sine),
        Sine / Speed,
    }

    local Value1 = {
        -Speed * Sine,
        Speed * Sine,
        HighSpeedTime * Cosine - Dampening * Sine,
    }

    local Position = Value0[1] * OldPosition + Value0[2] * Target + Value0[3] * OldVelocity
    local Velocity = Value1[1] * OldPosition + Value1[2] * Target + Value1[3] * OldVelocity

    return Position, Velocity
end

local function ConvertValueToUnpackedSprings(Value)
    local ValueType = type(Value)
    local UnpackedValue = ValuePacker.UnpackValue(Value, ValueType)

    for Index, Element in pairs(UnpackedValue) do
        UnpackedValue[Index] = {
            StartingPosition = Element,
            Velocity = 0,
            StartingTime = os.clock(),
            Target = Element,
        }
    end

    return UnpackedValue
end

function Spring:__call(Value, Speed, Dampening)
    local CurrentTarget = GetValue(Value)
    local ValueType = type(CurrentTarget)
    local UnpackedSprings = ConvertValueToUnpackedSprings(CurrentTarget)
    local AttachedSignal = Signal.new()
    local ChangedSignal = Signal.new()
    local CurrentValue = CurrentTarget
    local LastValue = CurrentTarget
    local InstanceSymbol = Symbol.new("Spring")

    local ActiveValue

    local function updateFunction()
        local PackedValues = {}

        if type(Value) == "table" and Value.__SEAM_OBJECT then
            ActiveValue.Target = GetValue(Value)
        end

        for Index, Spring in pairs(UnpackedSprings) do
            local Position, _ = GetPositionAndVelocity(Spring.StartingPosition, Spring.Velocity, Spring.Target, GetValue(Dampening), GetValue(Speed), Spring.StartingTime)

			if math.abs(Position) <= EPSILON then
				Position = 0
			elseif math.abs(Position - Spring.Target) <= EPSILON then
				Position = Spring.Target
			end

            PackedValues[Index] = Position
        end

        CurrentValue = ValuePacker.PackValue(PackedValues, ValueType)

        if IsValueChanged(LastValue, CurrentValue) then
            ChangedSignal:Fire("Value")
        end

        LastValue = CurrentValue
    end

    drawCache.add(updateFunction)

    ActiveValue = setmetatable({
        Destroy = function()
            UnpackedSprings = nil
            drawCache.remove(updateFunction)
        end
    }, {
        __index = function(_, Index)
            if Index == "__SEAM_OBJECT" then
                return InstanceSymbol
            elseif Index == "Value" then
                return CurrentValue
            elseif Index == "Velocity" then
                local PackedValues = {}

                for ThisIndex, ThisSpring in pairs(UnpackedSprings) do
                    local _, Velocity = GetPositionAndVelocity(ThisSpring.StartingPosition, ThisSpring.Velocity, ThisSpring.Target, GetValue(Dampening), GetValue(Speed), ThisSpring.StartingTime)

                    PackedValues[ThisIndex] = Velocity
                end

                return ValuePacker.PackValue(PackedValues, ValueType)
            elseif Index == "Changed" then
                return ChangedSignal
            elseif Index == "AttachedToInstance" then
                return AttachedSignal
            elseif Index == "Speed" then
                return Speed
            elseif Index == "Dampening" then
                return Dampening
            end

            return nil
        end,

        __newindex = function(_, Index, NewValue)
            if Index == "Target" then
                CurrentTarget = GetValue(NewValue)

                local UnpackedNewValue = ValuePacker.UnpackValue(CurrentTarget, ValueType)

                for ThisIndex, ThisSpring in pairs(UnpackedSprings) do
                    local Position, Velocity = GetPositionAndVelocity(ThisSpring.StartingPosition, ThisSpring.Velocity, ThisSpring.Target, GetValue(Dampening), GetValue(Speed), ThisSpring.StartingTime)

                    ThisSpring.StartingPosition = Position
                    ThisSpring.Velocity = Velocity
                    ThisSpring.StartingTime = os.clock()
                    ThisSpring.Target = UnpackedNewValue[ThisIndex]
                end
            elseif Index == "Value" then
                local UnpackedNewValue = ValuePacker.UnpackValue(NewValue, ValueType)

                for ThisIndex, ThisSpring in pairs(UnpackedSprings) do
                    local _, Velocity = GetPositionAndVelocity(ThisSpring.StartingPosition, ThisSpring.Velocity, ThisSpring.Target, GetValue(Dampening), GetValue(Speed), ThisSpring.StartingTime)

                    ThisSpring.StartingPosition = UnpackedNewValue[ThisIndex]
                    ThisSpring.Velocity = Velocity
                    ThisSpring.StartingTime = os.clock()
                end
            elseif Index == "Dampening" then
                Dampening = NewValue
            elseif Index == "Speed" then
                Speed = NewValue
            elseif Index == "Velocity" then
                local UnpackedNewValue = ValuePacker.UnpackValue(NewValue, ValueType)

                for ThisIndex, ThisSpring in pairs(UnpackedSprings) do
                    local Position, _ = GetPositionAndVelocity(ThisSpring.StartingPosition, ThisSpring.Velocity, ThisSpring.Target, GetValue(Dampening), GetValue(Speed), ThisSpring.StartingTime)

                    ThisSpring.Velocity = UnpackedNewValue[ThisIndex]
                    ThisSpring.StartingPosition = Position
                    ThisSpring.StartingTime = os.clock()
                end
            end
        end,
    })

    return ActiveValue
end

function Spring:__index(Index)
    if Index == "__SEAM_OBJECT" then
        return ClassSymbol
    elseif Index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

local Meta = setmetatable({}, Spring)

return Meta