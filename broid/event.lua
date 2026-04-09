local event = {}

-- Imports
local symbol = require("broid.modules.symbol")

event.mouseButton1Down = symbol.new("MouseButton1Down")
event.mouseButton1Up = symbol.new("MouseButton1Up")
event.mouseButton2Down = symbol.new("MouseButton2Down")
event.mouseButton2Up = symbol.new("MouseButton2Up")
event.mouseButton3Down = symbol.new("MouseButton3Down")
event.mouseButton3Up = symbol.new("MouseButton3Up")
event.mouseEnter = symbol.new("MouseEnter")
event.mouseLeave = symbol.new("MouseLeave")

return event