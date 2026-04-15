--[=[
    @type text {text : string | table, x : number, y : number, limit : number, align : alignMode, rotation : number, scaleX : number, scaleY : number, originX : number, originY : number, shearX : number, shearY : number, anchorPointX : number, anchorPointY : number, font : Font}
    @within new

    Basic text based on `love.graphics.printf`.
]=]

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
        local rotation = getValue(properties.rotation) or 0
        local width = font:getWidth(text)
        local height = font:getHeight()
        local anchorPointX = getValue(properties.anchorPointX) or 0
        local anchorPointY = getValue(properties.anchorPointY) or 0
        local originX = getValue(properties.originX) or 0
        local originY = getValue(properties.originY) or 0
        local limit = getValue(properties.limit) or width
        local align = getValue(properties.align) or "center"
        local scaleX = getValue(properties.scaleX) or 1
        local scaleY = getValue(properties.scaleY) or 1
        local mouseX, mouseY = love.mouse.getPosition()
        local cos = math.cos(rotation)
        local sin = math.sin(rotation)
        local deltaX = mouseX - x
        local deltaY = mouseY - y
        local localX = (deltaX * cos + deltaY * sin) / scaleX + originX + anchorPointX * width
        local localY = (-deltaX * sin + deltaY * cos) / scaleY + originY + anchorPointY * height

        return localX >= 0 and localX <= width and localY >= 0 and localY <= height
    end

    return function()
        love.graphics.setColor(unpack(getValue(properties.color)))

        -- bear in mind anchor points too, which are not built into love2d
        -- we do this by offsetting the origin based on the anchor point and text dimensions

        local width = (getValue(properties.font) or love.graphics.getFont()):getWidth(getValue(properties.text))
        local height = (getValue(properties.font) or love.graphics.getFont()):getHeight()

        love.graphics.printf(
            getValue(properties.text),
            getValue(properties.x),
            getValue(properties.y),
            getValue(properties.limit) or width,
            getValue(properties.align) or "center",
            getValue(properties.rotation) or 0,
            getValue(properties.scaleX) or 1,
            getValue(properties.scaleY) or 1,
            (getValue(properties.originX) or 0) + (getValue(properties.anchorPointX) or 0) * width,
            (getValue(properties.originY) or 0) + (getValue(properties.anchorPointY) or 0) * height,
            getValue(properties.shearX) or 0,
            getValue(properties.shearY) or 0
        )

    end
end