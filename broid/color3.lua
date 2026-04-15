--[=[
    @class color3

    A Color3 is a color represented by three numbers: red, green, and blue. Each number is between 0 and 1, inclusive.

    ```lua
    local color3 = broid.color3
    local color = color3.new(1, 0, 0) -- Red
    local color = color3.fromRGB(255, 0, 0) -- Red
    local cyan = color3.new(0, 1, 1) -- Cyan
    ```
]=]

--[=[
    @type color3 {[number] : number}
    @within color3

    The color constructed type.
]=]

local color3 = {}

--[=[
    @param r : number -- Red value between 0 and 1
    @param g : number -- Green value between 0 and 1
    @param b : number -- Blue value between 0 and 1
    @return color3
]=]

function color3.new(r, g, b)
    return {r, g, b, __TYPE = "color3"}
end

--[=[
    @param r : number -- Red value between 0 and 255
    @param g : number -- Green value between 0 and 255
    @param b : number -- Blue value between 0 and 255
    @return color3
]=]

function color3.fromRGB(r, g, b)
    return color3.new(r / 255, g / 255, b / 255)
end

return color3