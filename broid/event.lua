local event = {}

-- Imports
local symbol = require("broid.modules.symbol")

event.mouseButton1Down = symbol.new("mouseButton1Down")
event.mouseButton1Up = symbol.new("mouseButton1Up")
event.mouseButton2Down = symbol.new("mouseButton2Down")
event.mouseButton2Up = symbol.new("mouseButton2Up")
event.mouseButton3Down = symbol.new("mouseButton3Down")
event.mouseButton3Up = symbol.new("mouseButton3Up")
event.mouseEnter = symbol.new("mouseEnter")
event.mouseLeave = symbol.new("mouseLeave")

return event