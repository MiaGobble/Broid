--[[
    @prop drawMode : enum.drawMode
    @prop x : number
    @prop y : number
    @prop radius : number
    @prop segments : number
    @prop visible : boolean
]]

-- Imports
local getValue = require("broid.getValue")
local color3 = require("broid.color3")

return function(properties)
    if not properties.color then
        properties.color = color3.new(1, 1, 1)
    end

    function properties:IsMouseInBounds()
        local mouseX, mouseY = love.mouse.getPosition()
        local dx = mouseX - getValue(properties.x)
        local dy = mouseY - getValue(properties.y)
        local distanceSquared = dx * dx + dy * dy
        return distanceSquared <= getValue(properties.radius) * getValue(properties.radius)
    end

    return function()
        love.graphics.setColor(unpack(getValue(properties.color)))
        love.graphics.circle(getValue(properties.drawMode), getValue(properties.x), getValue(properties.y), getValue(properties.radius), getValue(properties.segments))
    end
end