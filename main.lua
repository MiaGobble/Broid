-- Author: iGottic

--[[
    This is a script to test Broid's functionality as I develop it.
    It isn't always going to be best practice, but it's a good way to test things out and make sure they work as intended.
--]]

-- Imports
local broid = require("broid")
local enum = broid.enum
local lifetime = broid.lifetime
local event = broid.event
local color3 = broid.color3
local scale = broid.scale

function love.load()
    local scope = broid.scope(broid)
    local state = scope:value("idle")
    local rotation = scope:spring(0, 20, 0.5)

    local object = scope:new("drawable", {
        drawable = love.graphics.newImage("assets/img/button.png"),
        anchorPointX = 0.5,
        anchorPointY = 0.5,
        x = scale.x(0.5),
        y = scale.y(0.5),
        rotation = rotation,

        scaleX = scope:spring(scope:computed(function(use)
            if use(state) == "idle" then
                return 1
            elseif use(state) == "hover" then
                return 1.1
            elseif use(state) == "press" then
                return 0.8
            end
        end), 30, 0.5),

        scaleY = scope:spring(scope:computed(function(use)
            if use(state) == "idle" then
                return 1
            elseif use(state) == "hover" then
                return 1.1
            elseif use(state) == "press" then
                return 0.8
            end
        end), 30, 0.5),
       
        [event.mouseEnter] = function()
            print("Mouse entered!")
            state.value = "hover"
        end,

        [event.mouseLeave] = function()
            print("Mouse left!")
            state.value = "idle"
        end,

        [event.mouseButton1Down] = function()
            print("Mouse button 1 down!")
            state.value = "press"
        end,

        [event.mouseButton1Up] = function()
            print("Mouse button 1 up!")
            state.value = "idle"
            rotation.velocity = math.pi / 2
        end,
    })
end

function love.draw()
    broid.draw()
end