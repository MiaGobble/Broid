--[=[
    @class scope

    A utility for creating scoped environments that allow for encapsulation of objects.

    ```lua
    local scope = broid.scope

    local myScope = scope(broid) -- Create a new scope with the entire Broid library available
    local customScope = scope({print = print}) -- Create a new scope with only the print function available

    local circle = myScope:new("Circle", {radius = 50}) -- Create a new Circle in myScope

    myScope:Destroy() -- Destroys the circle and any other objects created in myScope
    ```
]=]

--[=[
    @method InnerScope
    @within scope
    @param newScopedObjects : {[any] : any}?
    @return scope

    Creates a scope that extends from the current scope. When the original scope is cleaned up, the inner scope will also be cleaned up.

    ```lua
    local innerScope = myScope:InnerScope({myCustomObject = myCustomObject})
    ```
]=]

--[=[
    @method AddObject
    @within scope
    @param object : any

    Adds an object to the scope. When the scope is destroyed, the object will also be destroyed.

    ```lua
    myScope:AddObject(myCustomObject)
    ```
]=]

--[=[
    @method RemoveObject
    @within scope
    @param object : any

    Removes an object from the scope. The object will be destroyed and will no longer be part of the scope.

    ```lua
    myScope:RemoveObject(myCustomObject)
    ```
]=]

--[=[
    @method Destroy
    @within scope

    Destroys the scope and all objects within it.

    ```lua
    myScope:Destroy()
    ```
]=]

local scope = {}

-- Imports
local modules = "broid.modules"
local bucket = require(modules .. ".bucket")
local symbol = require(modules .. ".symbol")
local createDeepTraceback = require(modules .. ".createDeepTraceback")

-- Variables
local classSymbol = symbol.new("scope")

function scope.__call(_, scopedObjects)
    -- Scopes have been a headache to get working, since I'm a dumdum

    local selfClass = {}
    local selfMeta = {}
    local instanceSymbol = symbol.new("scope")

    if not scopedObjects then
        scopedObjects = {}
    end

    function selfMeta:__index(key)
        if not key then
            print("Attempt to index a scope with nil\n" .. createDeepTraceback())
            return
        end

        if key == "__BROID_OBJECT" then
            -- Some things check if something is a Broid object, so
            -- this is the first thing we should try to return
            return instanceSymbol
        end

        local object = scopedObjects[key]

        if object == nil then
            print("Attempt to index a scope with " .. tostring(key) .. " when it does not exist in scope\n" .. createDeepTraceback())
            return nil
        end
    
        if type(object) ~= "function" and (type(object) ~= "table" or not object.__BROID_CAN_BE_SCOPED) then
            if object.__BROID_OBJECT or object.__BROID_INDEX then
                -- If something from Broid has __BROID_CAN_BE_SCOPED (meaning it can't be scoped) as false,
                -- then we should error what specifically the user tried to use
                error(tostring(object.__BROID_OBJECT or object.__BROID_INDEX) .. " is not a valid scopable Broid object")
            else
                -- Idk just error
                error("Object is not a valid scopable Broid object (unknown object)")
            end
        end
    
        return function(_, ...)
            if not self.bucket then -- If the trove instance doesn't exist, the scope is likely destroyed
                print("Attempted to use something in scope (" .. key .. ") but scope is already destroyed:\n" .. createDeepTraceback())
                return
            end

            -- Broid things are called as functions, so this is a wrapper
            -- function that puts any created instances into the trove
            local tuple = nil

            if type(object) == "function" then
                -- If it's a non-Broid function, let's pass the scope as the first parameter,
                -- then pass in everything else
                tuple = {object(self, ...)}
            elseif object.__BROID_OBJECT and tostring(object.__BROID_OBJECT) == "new" then
                -- For New specifically, we want to actually put scope at the end. In the
                -- future, if Broid requires scopes, this will change
                local args = {...}
                table.insert(args, self)
                tuple = {object(unpack(args))}
            else
                -- Right now, scope is not passed in to most Broid objects
                tuple = {object(...)}
            end
    
            -- If nothing returns, don't bother running the rest of the code
            if #tuple == 0 then
                return
            end

            -- But yeah, let's add created things to the trove
            for _, thisValue in pairs(tuple) do
                self.bucket:Add(thisValue)
            end
    
            -- Unpack the tuple and return it ALLLLLLLL
            return unpack(tuple)
        end
    end

    function selfClass:InnerScope(newScopedObjects)
        -- Default to a blank table
        if newScopedObjects == nil then
            newScopedObjects = {}
        end

        -- Take the current scoped objects and copy them to the new table
        for index, object in pairs(self.scopedObjects) do
            newScopedObjects[index] = object
        end

        local newScope = meta(newScopedObjects) -- Make a new scope
        self.bucket:Add(newScope) -- Add the new sub-scope to the parent trove

        return newScope
    end

    function selfClass:AddObject(object)
        self.bucket:Add(object)
    end

    function selfClass:RemoveObject(object)
        object:Destroy()
        self.bucket[object] = nil
    end

    function selfClass:Destroy()
        self.bucket:Destroy()
        self.bucket = nil
    end

    local scopeInstance = setmetatable(selfClass, selfMeta)
    scopeInstance.scopedObjects = scopedObjects
    scopeInstance.bucket = bucket.new()

    return scopeInstance
end

function scope:__index(key)
    if key == "__BROID_OBJECT" then
        return classSymbol
    elseif key == "__BROID_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

return setmetatable({}, scope)