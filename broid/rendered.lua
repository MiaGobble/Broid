--[=[
    @class rendered

    A utility for creating rendered states that always update every frame.

    ```lua
    local rendered = broid.rendered
    local new = broid.new

    local element = new("Circle", {
        x = rendered(function(deltaTime)
            -- This function is called every frame. deltaTime is the time since the last frame.
            return os.clock() % 100
        end),
    })
    ```
]=]

local rendered = {}

-- Imports
local modules = "broid.modules"
local signal = require(modules .. ".Signal")
local symbol = require(modules .. ".Symbol")

-- Variables
local classSymbol = symbol.new("rendered")

function rendered:__call(callback)
    local attachedSignal = signal.new()
    local instanceSymbol = symbol.new("renderedInstance")
    local lastFrame = os.clock()

    local function wrappedCallback()
        local deltaTime = os.clock() - lastFrame
        lastFrame = os.clock()
        return callback(deltaTime)
    end

    local activeComputation = {
        Destroy = function()
            attachedSignal:Destroy()
        end,
    }

    setmetatable(activeComputation, {
        __index = function(_, key)
            if key == "__BROID_OBJECT" then
                return instanceSymbol
            elseif key == "value" then
                return wrappedCallback()
            elseif key == "attachedToInstance" then
                return attachedSignal
            end

            return nil
        end,
    })

    return activeComputation
end

function rendered:__index(key)
    if key == "__BROID_INDEX" then
        return classSymbol
    elseif key == "__BROID_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

return setmetatable({}, rendered)
