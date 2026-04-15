--[=[
    @class isState

    A utility for checking if a value is a state object.

    ```lua
    local value = broid.value
    local isState = broid.isState

    local foo = value.new(1)
    print(isState(foo)) -- true
    print(isState(123)) -- false
    print(isState("Hello")) -- false
    ```
]=]

local isState = {}

-- Constants
local RECOGNIZED_STATE_SYMBOLS = {"spring", "computedInstance", "renderedInstance", "value"}

function isState:__call(checkedValue)
    if type(checkedValue) ~= "table" then
        return false -- Not a state since it's not a table
    end

    if not checkedValue.__BROID_OBJECT then
        return false -- Not a state since it's not from Broid or not a Broid object
    end

    for _, value in pairs(RECOGNIZED_STATE_SYMBOLS) do
        if value == tostring(checkedValue.__BROID_OBJECT) then
            return true
        end
    end

    return false -- Default to false
end

function isState:__index(key)
    if key == "__BROID_CAN_BE_SCOPED" then
        return false
    end

    return nil
end

return setmetatable({}, isState)