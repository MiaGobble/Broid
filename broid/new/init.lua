local new = {}

-- Imports
local path = ...
local drawCache = require("broid.drawCache")
local lifetime = require("broid.lifetime")
local getValue = require("broid.getValue")
local tags = require("broid.tags")
local destroyed = require("broid.destroyed")
local symbol = require("broid.modules.symbol")
local value = require("broid.value")
local event = require("broid.event")
local elements = {
    circle = require(path .. ".circle")
}

-- Variables
local classSymbol = symbol.new("new")

local function deepCopy(original)
    if type(original) ~= "table" then
        return original
    end

    local copy = {}
    
    for index, subValue in pairs(original) do
        copy[index] = deepCopy(subValue)
    end

    return copy
end

local function getStrippedVersion(dictionary, strippedProps)
    local strippedVersion = deepCopy(dictionary)

    for _, property in ipairs(strippedProps) do
        dictionary[property] = nil
    end

    return strippedVersion
end

function new:__call(elementType, properties, scope)
    local module = elements[elementType]

    if not module then
        error(elementType .. " is not a valid element type")
    end

    local isActive = true
    local createTimestamp = os.clock()
    local drawFunction = module(properties)
    local theseTags = properties[tags] or {}
    local isMouseInside = scope and scope:value(false) or value(false)
    local isMouseDown = {
        scope and scope:value(false) or value(false),
        scope and scope:value(false) or value(false),
        scope and scope:value(false) or value(false)
    }

    local updateFunction = function()
        if properties[lifetime] and os.clock() - createTimestamp > properties[lifetime] then
            properties:destroy()
            return
        end

        if getValue(properties.visible) == false then
            for _, mouseDownValue in ipairs(isMouseDown) do
                mouseDownValue.value = false
            end

            isMouseInside.value = false

            return
        end

        if properties.IsMouseInBounds then
            isMouseInside.value = properties:IsMouseInBounds()

            for mouseIndex, mouseDownValue in ipairs(isMouseDown) do
                if isMouseInside.value and love.mouse.isDown(mouseIndex) then
                    mouseDownValue.value = true
                else
                    mouseDownValue.value = false
                end
            end
        end

        drawFunction()
    end

    drawCache.add(updateFunction)

    isMouseInside.changed:Connect(function()
        if isMouseInside.value then
            if properties[event.mouseEnter] then
                coroutine.wrap(properties[event.mouseEnter])()
            end
        else
            if properties[event.mouseLeave] then
                coroutine.wrap(properties[event.mouseLeave])()
            end
        end
    end)

    for mouseIndex, mouseDownValue in ipairs(isMouseDown) do
        mouseDownValue.changed:Connect(function()
            if mouseDownValue.value then
                if properties[event["mouseButton" .. mouseIndex .. "Down"]] then
                    coroutine.wrap(properties[event["mouseButton" .. mouseIndex .. "Down"]])()
                end
            else
                if properties[event["mouseButton" .. mouseIndex .. "Up"]] then
                    coroutine.wrap(properties[event["mouseButton" .. mouseIndex .. "Up"]])()
                end
            end
        end)
    end

    function properties:Destroy()
        if not isActive then
            error("Attempt to destroy object already that is destroyed")
            return
        end

        isActive = true
        drawCache.remove(updateFunction)

        if properties[destroyed] then
            coroutine.wrap(properties[destroyed])()
        end

        for index, _ in pairs(properties) do
            properties[index] = nil
        end
    end

    function properties:GetTags()
        return getValue(theseTags)
    end

    return getStrippedVersion(properties, {tags, destroyed})
end

function new:__index(index)
    if index == "__BROID_INDEX" then
        return classSymbol
    elseif index == "__BROID_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

return setmetatable({}, new)