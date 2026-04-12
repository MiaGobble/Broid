--[[
    @prop drawable : Drawable
    @prop x : number
    @prop y : number
    @prop rotation : numbeR
    @prop scaleX : number
    @prop scaleY : number
    @prop originOffsetX : number
    @prop originOffsetY : number
    @prop shearX : number
    @prop shearY : number
    @prop anchorPointX : number
    @prop anchorPointY : number
    @prop visible : boolean
]]

-- Imports
local getValue = require("broid.getValue")

return function(properties)
    function properties:IsMouseInBounds()
        local mouseX, mouseY = love.mouse.getPosition()
        local drawable = getValue(properties.drawable)
        local x = getValue(properties.x)
        local y = getValue(properties.y)
        local width = drawable:getWidth()
        local height = drawable:getHeight()
        local originOffsetX = getValue(properties.originOffsetX) or 0
        local originOffsetY = getValue(properties.originOffsetY) or 0
        local rotation = getValue(properties.rotation) or 0
        local scaleX = getValue(properties.scaleX) or 1
        local scaleY = getValue(properties.scaleY) or 1
        local anchorPointX = getValue(properties.anchorPointX) or 0
        local anchorPointY = getValue(properties.anchorPointY) or 0
        local cos = math.cos(rotation)
        local sin = math.sin(rotation)
        local deltaX = mouseX - x
        local deltaY = mouseY - y
        local localX = (deltaX * cos + deltaY * sin) / scaleX + originOffsetX + anchorPointX * width
        local localY = (-deltaX * sin + deltaY * cos) / scaleY + originOffsetY + anchorPointY * height

        return localX >= 0 and localX <= width and localY >= 0 and localY <= height
    end

    return function()
        love.graphics.draw(
            getValue(properties.drawable),
            getValue(properties.x),
            getValue(properties.y),
            getValue(properties.rotation) or 0,
            getValue(properties.scaleX) or 1,
            getValue(properties.scaleY) or 1,
            (getValue(properties.originOffsetX) or 0) + (getValue(properties.anchorPointX) or 0) * getValue(properties.drawable):getWidth(),
            (getValue(properties.originOffsetY) or 0) + (getValue(properties.anchorPointY) or 0) * getValue(properties.drawable):getHeight(),
            getValue(properties.shearX) or 0,
            getValue(properties.shearY) or 0
        )
    end
end