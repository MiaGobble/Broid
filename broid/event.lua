--[=[
    @class event

    A collection of events that can be used as delcarations in elements.

    ```lua
    local event = broid.event
    local new = broid.new

    local circle = new("Circle", {
        -- ...
        [event.mouseButton1Down] = function() -- Prints when clicking circle
            print("Mouse button 1 down!")
        end,
    })
    ```
]=]

--[=[
    @type event symbol
    @within event

    An event type that can be used as a declaration in elements. When the event is fired, the function connected to it will be called.
]=]

local event = {}

-- Imports
local symbol = require("broid.modules.symbol")

--[=[
    @prop mouseButton1Down : event
    @within event

    Fired when the left mouse button is pressed down on an element.
]=]

event.mouseButton1Down = symbol.new("mouseButton1Down")

--[=[
    @prop mouseButton1Up : event
    @within event

    Fired when the left mouse button is released on an element.
]=]

event.mouseButton1Up = symbol.new("mouseButton1Up")

--[=[
    @prop mouseButton2Down : event
    @within event

    Fired when the right mouse button is pressed down on an element.
]=]

event.mouseButton2Down = symbol.new("mouseButton2Down")

--[=[
    @prop mouseButton2Up : event
    @within event

    Fired when the right mouse button is released on an element.
]=]

event.mouseButton2Up = symbol.new("mouseButton2Up")

--[=[
    @prop mouseButton3Down : event
    @within event

    Fired when the middle mouse button is pressed down on an element.
]=]

event.mouseButton3Down = symbol.new("mouseButton3Down")

--[=[
    @prop mouseButton3Up : event
    @within event

    Fired when the middle mouse button is released on an element.
]=]

event.mouseButton3Up = symbol.new("mouseButton3Up")

--[=[
    @prop mouseEnter : event
    @within event

    Fired when the mouse enters an element.
]=]

event.mouseEnter = symbol.new("mouseEnter")

--[=[
    @prop mouseLeave : event
    @within event

    Fired when the mouse leaves an element.
]=]

event.mouseLeave = symbol.new("mouseLeave")

return event