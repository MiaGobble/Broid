local drawCache = {}

-- Variables
local cache = {}

function drawCache.add(object)
    if cache[object] then -- Swapping from Luau to Lua, this is how I discover there is no table.find
        return
    end

    cache[object] = true
end

function drawCache.remove(object)
    cache[object] = nil
end

function drawCache.getDrawFunctions()
    local array = {}

    for drawFunction, _ in pairs(cache) do
        table.insert(array, drawFunction)
    end

    return array
end

return drawCache