local scale = {}

-- Imports
local value = require("broid.value")
local drawCache = require("broid.drawCache")

function scale.x(xScale)
    local scaleValue = value(0)

    local function updateScaleValue()
        scaleValue.value = xScale * love.graphics.getWidth()
    end

    updateScaleValue()
    drawCache.add(updateScaleValue)

    return scaleValue
end

function scale.y(yScale)
    local scaleValue = value(0)

    local function updateScaleValue()
        scaleValue.value = yScale * love.graphics.getHeight()
    end

    updateScaleValue()
    drawCache.add(updateScaleValue)

    return scaleValue
end

return scale