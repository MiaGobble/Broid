--[=[
    @class enum

    A collection of enum values.
]=]

local enum = {}

--[=[
    @prop drawMode : {fill : "fill", line : "line"}
    @within enum

    The draw mode for shapes. "fill" will fill the shape, while "line" will only draw the outline.
]=]

enum.drawMode = {
    fill = "fill",
    line = "line",
}

--[=[
    @prop alignMode : {left : "left", center : "center", right : "right", justify : "justify"}
    @within enum

    The alignment mode for text. "left" will align text to the left, "center" will center the text, "right" will align text to the right, and "justify" will justify the text.
]=]

enum.alignMode = {
    left = "left",
    center = "center",
    right = "right",
    justify = "justify",
}

return enum