-- Imports
local broid = require("broid")
local timer = require("timer")
local enum = broid.enum
local lifetime = broid.lifetime
local event = broid.event

-- Variables
local object

function love.load()
    local scope = broid.scope(broid)
    local isMoved = scope:value(false)

    local object = scope:new("circle", {
        drawMode = enum.drawMode.fill,
        radius = 200,
        segments = 20,

        x = scope:spring(scope:computed(function(use)
            if use(isMoved) then
                return 350
            else
                return 200
            end
        end), 20, 0.5),

        y = scope:spring(scope:computed(function(use)
            if use(isMoved) then
                return 350
            else
                return 200
            end
        end), 15, 0.5),
       
        [event.mouseEnter] = function()
            print("Mouse entered!")
        end,

        [event.mouseLeave] = function()
            print("Mouse left!")
        end,

        [event.mouseButton1Down] = function()
            print("Mouse button 1 down!")
        end,

        [event.mouseButton1Up] = function()
            print("Mouse button 1 up!")
        end,
    })

    timer.after(2, function()
        isMoved.Value = true
    end)
end

function love.draw()
    broid.draw()
end

function love.update(delta)
    timer.update(delta)
end