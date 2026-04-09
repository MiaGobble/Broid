local color3 = {}

function color3.new(r, g, b)
    return {r, g, b, __TYPE = "color3"}
end

function color3.fromRGB(r, g, b)
    return color3.new(r / 255, g / 255, b / 255)
end

return color3