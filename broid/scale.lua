--[=[
    @class scale

    A utility for creating scale values that react to the size of the window.

    ```lua
    local scale = broid.scale

    local xScale = scale.x(0.5) -- Scale the x-coordinate by 50%
    local yScale = scale.y(0.8) -- Scale the y-coordinate by 80%
    ```
]=]

local scale = {}

-- Imports
local value = require("broid.value")
local drawCache = require("broid.drawCache")

--[=[
    @param xScale : number
    @return value

    A function that takes a scale factor for the x-coordinate and returns a value that updates based on the window's width.

    ```lua
    local scale = broid.scale

    local xScale = scale.x(0.5) -- Scale the x-coordinate by 50%

    print(xScale.value) -- Assuming a window width of 800, this will print 400.
    ```
]=]

function scale.x(xScale)
    local scaleValue = value(0)

    local function updateScaleValue()
        scaleValue.value = xScale * love.graphics.getWidth()
    end

    updateScaleValue()
    drawCache.add(updateScaleValue)

    return scaleValue
end

--[=[
    @param yScale : number
    @return value

    A function that takes a scale factor for the y-coordinate and returns a value that updates based on the window's height.

    ```lua
    local scale = broid.scale

    local yScale = scale.y(0.8) -- Scale the y-coordinate by 80%

    print(yScale.value) -- Assuming a window height of 600, this will print 480.
    ```
]=]

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