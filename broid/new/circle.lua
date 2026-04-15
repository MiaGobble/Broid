--[=[
    @type circle {drawMode : enum.drawMode, x : number, y : number, radius : number, segments : number, anchorPointX : number, anchorPointY : number, visible : boolean}
    @within new

    A basic circle element based on `love.graphics.circle`.
]=]

-- Imports
local getValue = require("broid.getValue")
local color3 = require("broid.color3")

return function(properties)
    if not properties.color then
        properties.color = color3.new(1, 1, 1)
    end

    function properties:IsMouseInBounds()
        local mouseX, mouseY = love.mouse.getPosition()
        local x = getValue(properties.x)
        local y = getValue(properties.y)
        local radius = getValue(properties.radius)
        local anchorPointX = getValue(properties.anchorPointX) or 0
        local anchorPointY = getValue(properties.anchorPointY) or 0
        local centerX = x - anchorPointX * radius
        local centerY = y - anchorPointY * radius
        local deltaX = mouseX - centerX
        local deltaY = mouseY - centerY

        return deltaX * deltaX + deltaY * deltaY <= radius * radius
    end

    return function()
        love.graphics.setColor(unpack(getValue(properties.color)))
        love.graphics.circle(getValue(properties.drawMode), getValue(properties.x), getValue(properties.y), getValue(properties.radius), getValue(properties.segments))
    end
end