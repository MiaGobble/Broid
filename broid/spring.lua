-- Author: iGottic

local Spring = {}

-- Constants
local EPSILON = 0.001

-- Imports
local modules = "broid.modules"
local getValue = require("broid.getValue")
local drawCache = require("broid.drawCache")
local valuePacker = require(modules .. ".valuePacker")
local signal = require(modules .. ".signal")
local isValueChanged = require(modules .. ".isValueChanged")
local symbol = require(modules .. ".symbol")

-- Variables
local classSymbol = symbol.new("spring")

local function getPositionAndVelocity(oldPosition, oldVelocity, target, dampening, speed, timeStarted)
    local timePassed = os.clock() - timeStarted
    local timeValue = timePassed * speed
    local dampeningSquared = dampening ^ 2
    local highSpeedTime = nil
    local cosine = nil
    local sine = nil

    if dampeningSquared < 1 then
        -- Under dampened

        highSpeedTime = (1 - dampeningSquared) ^ 0.5

        local eulersFastTime = math.exp(-dampening * timeValue) / highSpeedTime
        cosine = eulersFastTime * math.cos(highSpeedTime * timeValue)
        sine = eulersFastTime * math.sin(highSpeedTime * timeValue)
    elseif dampeningSquared == 1 then
        -- Critically dampened

        highSpeedTime = 1

        local eulersFastTime = math.exp(-dampening * timeValue)
        cosine = eulersFastTime
        sine = eulersFastTime * timeValue
    else
        -- Over dampened

        highSpeedTime = (dampeningSquared - 1) ^ 0.5
        cosine = math.exp((-dampening + highSpeedTime) * timeValue) / (2 * highSpeedTime) + math.exp((-dampening - highSpeedTime) * timeValue) / (2 * highSpeedTime)
        sine = math.exp((-dampening + highSpeedTime) * timeValue) / (2 * highSpeedTime) - math.exp((-dampening - highSpeedTime) * timeValue) / (2 * highSpeedTime)
    end

    local value0 = {
        highSpeedTime * cosine + dampening * sine,
        1 - (highSpeedTime * cosine + dampening * sine),
        sine / speed,
    }

    local value1 = {
        -speed * sine,
        speed * sine,
        highSpeedTime * cosine - dampening * sine,
    }

    local position = value0[1] * oldPosition + value0[2] * target + value0[3] * oldVelocity
    local velocity = value1[1] * oldPosition + value1[2] * target + value1[3] * oldVelocity

    return position, velocity
end

local function convertValueToUnpackedSprings(value)
    local valueType = type(value)
    local unpackedValue = valuePacker.UnpackValue(value, valueType)

    for index, element in pairs(unpackedValue) do
        unpackedValue[index] = {
            startingPosition = element,
            velocity = 0,
            startingTime = os.clock(),
            target = element,
        }
    end

    return unpackedValue
end

function Spring:__call(value, speed, dampening)
    local currentTarget = getValue(value)
    local valueType = type(currentTarget)
    local unpackedSprings = convertValueToUnpackedSprings(currentTarget)
    local attachedSignal = signal.new()
    local changedSignal = signal.new()
    local currentValue = currentTarget
    local lastValue = currentTarget
    local instanceSymbol = symbol.new("spring")

    local activeValue

    local function updateFunction()
        local packedValues = {}

        if type(value) == "table" and value.__SEAM_OBJECT then
            activeValue.target = getValue(value)
        end

        for index, spring in pairs(unpackedSprings) do
            local position, _ = getPositionAndVelocity(spring.startingPosition, spring.velocity, spring.target, getValue(dampening), getValue(speed), spring.startingTime)

            if math.abs(position) <= EPSILON then
                position = 0
            elseif math.abs(position - spring.target) <= EPSILON then
                position = spring.target
            end

            packedValues[index] = position
        end

        currentValue = valuePacker.PackValue(packedValues, valueType)

        if isValueChanged(lastValue, currentValue) then
            changedSignal:Fire("value")
        end

        lastValue = currentValue
    end

    drawCache.add(updateFunction)

    activeValue = setmetatable({
        Destroy = function()
            unpackedSprings = nil
            drawCache.remove(updateFunction)
        end
    }, {
        __index = function(_, index)
            if index == "__SEAM_OBJECT" then
                return instanceSymbol
            elseif index == "value" then
                return currentValue
            elseif index == "velocity" then
                local packedValues = {}

                for thisIndex, thisSpring in pairs(unpackedSprings) do
                    local _, velocity = getPositionAndVelocity(thisSpring.startingPosition, thisSpring.velocity, thisSpring.target, getValue(dampening), getValue(speed), thisSpring.startingTime)

                    packedValues[thisIndex] = velocity
                end

                return valuePacker.PackValue(packedValues, valueType)
            elseif index == "changed" then
                return changedSignal
            elseif index == "attachedToInstance" then
                return attachedSignal
            elseif index == "speed" then
                return speed
            elseif index == "dampening" then
                return dampening
            end

            return nil
        end,

        __newindex = function(_, index, newValue)
            if index == "target" then
                currentTarget = getValue(newValue)

                local unpackedNewValue = valuePacker.UnpackValue(currentTarget, valueType)

                for thisIndex, thisSpring in pairs(unpackedSprings) do
                    local position, velocity = getPositionAndVelocity(thisSpring.startingPosition, thisSpring.velocity, thisSpring.target, getValue(dampening), getValue(speed), thisSpring.startingTime)

                    thisSpring.startingPosition = position
                    thisSpring.velocity = velocity
                    thisSpring.startingTime = os.clock()
                    thisSpring.target = unpackedNewValue[thisIndex]
                end
            elseif index == "value" then
                local unpackedNewValue = valuePacker.UnpackValue(newValue, valueType)

                for thisIndex, thisSpring in pairs(unpackedSprings) do
                    local _, velocity = getPositionAndVelocity(thisSpring.startingPosition, thisSpring.velocity, thisSpring.target, getValue(dampening), getValue(speed), thisSpring.startingTime)

                    thisSpring.startingPosition = unpackedNewValue[thisIndex]
                    thisSpring.velocity = velocity
                    thisSpring.startingTime = os.clock()
                end
            elseif index == "dampening" then
                dampening = newValue
            elseif index == "speed" then
                speed = newValue
            elseif index == "velocity" then
                local unpackedNewValue = valuePacker.UnpackValue(newValue, valueType)

                for thisIndex, thisSpring in pairs(unpackedSprings) do
                    local position, _ = getPositionAndVelocity(thisSpring.startingPosition, thisSpring.velocity, thisSpring.target, getValue(dampening), getValue(speed), thisSpring.startingTime)

                    thisSpring.velocity = unpackedNewValue[thisIndex]
                    thisSpring.startingPosition = position
                    thisSpring.startingTime = os.clock()
                end
            end
        end,
    })

    return activeValue
end

function Spring:__index(index)
    if index == "__SEAM_OBJECT" then
        return classSymbol
    elseif index == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

return setmetatable({}, Spring)