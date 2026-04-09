--[[
    @prop text : string | table
    @prop x : number
    @prop y : number
    @prop limit : number
    @prop align : alignMode
    @prop rotation : number
    @prop scaleX : number
    @prop scaleY : number
    @prop originX : number
    @prop originY : number
    @prop shearX : number
    @prop shearY : number
    @prop font : Font
]]

-- Imports
local getValue = require("broid.getValue")
local color3 = require("broid.color3")

return function(properties)
    if not properties.color then
        properties.color = color3.new(1, 1, 1)
    end

    function properties:IsMouseInBounds()
        local text = getValue(properties.text)
        local x = getValue(properties.x)
        local y = getValue(properties.y)
        local font = getValue(properties.font) or love.graphics.getFont()
        local limit = getValue(properties.limit) or 10000
        local rotation = getValue(properties.rotation) or 0
        local width = font:getWidth(text)
        local height = font:getHeight(text)
        local originX = getValue(properties.originX) or 0
        local originY = getValue(properties.originY) or 0
        local shearX = getValue(properties.shearX) or 0
        local shearY = getValue(properties.shearY) or 0
        local scaleX = getValue(properties.scaleX) or 1
        local scaleY = getValue(properties.scaleY) or 1
        local mouseX, mouseY = love.mouse.getPosition()
        local cos = math.cos(rotation)
        local sin = math.sin(rotation)
        local dx = mouseX - x
        local dy = mouseY - y
        local localX = (dx * cos + dy * sin) / scaleX + originX
        local localY = (-dx * sin + dy * cos) / scaleY + originY
        local left = 0
        local right = width
        local top = 0
        local bottom = height

        return localX >= left and localX <= right and localY >= top and localY <= bottom
    end

    return function()
        love.graphics.setColor(unpack(getValue(properties.color)))
        love.graphics.printf(getValue(properties.text), getValue(properties.x), getValue(properties.y), getValue(properties.limit) or math.huge, getValue(properties.align) or "left", getValue(properties.rotation) or 0, getValue(properties.scaleX) or 1, getValue(properties.scaleY) or 1, getValue(properties.originX) or 0, getValue(properties.originY) or 0, getValue(properties.shearX) or 0, getValue(properties.shearY) or 0)
    end
end