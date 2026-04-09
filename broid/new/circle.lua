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

return function(properties)
    function properties:IsMouseInBounds()
        local mouseX, mouseY = love.mouse.getPosition()
        local dx = mouseX - getValue(properties.x)
        local dy = mouseY - getValue(properties.y)
        local distanceSquared = dx * dx + dy * dy
        return distanceSquared <= getValue(properties.radius) * getValue(properties.radius)
    end

    return function()
        love.graphics.circle(getValue(properties.drawMode), getValue(properties.x), getValue(properties.y), getValue(properties.radius), getValue(properties.segments))
    end
end