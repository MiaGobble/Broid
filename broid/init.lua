-- Author: iGottic
local broid = {}

-- Imports
local drawCache = require("broid.drawCache")

-- Members
broid.new = require("broid.new")
broid.enum = require("broid.enum")
broid.value = require("broid.value")
broid.spring = require("broid.spring")
broid.computed = require("broid.computed")
broid.lifetime = require("broid.lifetime")
broid.tags = require("broid.tags")
broid.destroyed = require("broid.destroyed")
broid.scope = require("broid.scope")
broid.event = require("broid.event")
broid.getValue = require("broid.getValue")
broid.isState = require("broid.isState")
broid.color3 = require("broid.color3")
broid.rendered = require("broid.rendered")

-- Draw callback
function broid.draw()
    for _, drawFunction in pairs(drawCache.getDrawFunctions()) do
        local success, issue = pcall(drawFunction)

        if not success then
            print("WARNING, ISSUE WITH DRAW: " .. issue)
        end
    end
end

return broid