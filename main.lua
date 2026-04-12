-- Author: iGottic

--[[
    This is a script to test Broid's functionality as I develop it.
    It isn't always going to be best practice, but it's a good way to test things out and make sure they work as intended.
--]]

-- Imports
local broid = require("broid")
local timer = require("timer")
local enum = broid.enum
local lifetime = broid.lifetime
local event = broid.event
local color3 = broid.color3

function love.load()
    local scope = broid.scope(broid)
    local isMoved = scope:value(false)

    local object = scope:new("drawable", {
        drawable = love.graphics.newImage("assets/img/button.png"),
        anchorPointX = 0.5,
        anchorPointY = 0.5,

        rotation = scope:rendered(function()
            local time = os.clock()
            return time * 1
        end),

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

    timer.after(3, function()
        isMoved.value = true
    end)
end

function love.draw()
    broid.draw()
end

function love.update(delta)
    timer.update(delta)
end