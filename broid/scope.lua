-- Author: iGottic

local Scope = {}

-- Imports
local modules = "broid.modules"
local bucket = require(modules .. ".bucket")
local Symbol = require(modules .. ".symbol")
local CreateDeepTraceback = require(modules .. ".createDeepTraceback")

-- Variables
local ClassSymbol = Symbol.new("Scope")
local Meta = setmetatable({}, Scope)

local function deepCopy(original)
    if type(original) ~= "table" then
        return original
    end

    local copy = {}
    
    for index, value in pairs(original) do
        copy[index] = deepCopy(value)
    end

    return copy
end

function Scope.__call(_, ScopedObjects)
    -- Scopes have been a headache to get working, since I'm a dumdum

    local selfClass = {}
    local selfMeta = {}
    local InstanceSymbol = Symbol.new("Scope")

    if not ScopedObjects then
        ScopedObjects = {}
    end

    --ScopedObjects = deepCopy(ScopedObjects)

    function selfMeta:__index(Key)
        if not Key then
            print("Attempt to index a scope with nil\n" .. CreateDeepTraceback())
            return
        end

        if Key == "__SEAM_OBJECT" then
            -- Some things check if something is a seam object, so
            -- this is the first thing we should try to return
            return InstanceSymbol
        end

        local Object = ScopedObjects[Key]

        if Object == nil then
            print("Attempt to index a scope with {Key} when it does not exist in scope\n" .. CreateDeepTraceback())
            return nil
        end
    
        if type(Object) ~= "function" and (type(Object) ~= "table" or not Object.__SEAM_CAN_BE_SCOPED) then
            if Object.__SEAM_OBJECT or Object.__SEAM_INDEX then
                -- If something from seam has __SEAM_CAN_BE_SCOPED (meaning it can't be scoped) as false,
                -- then we should error what specifically the user tried to use
                error(tostring(Object.__SEAM_OBJECT or Object.__SEAM_INDEX) .. " is not a valid scopable Seam object")
            else
                -- Idk just error
                error("Object is not a valid scopable Seam object (unknown object)")
            end
        end
    
        return function(_, ...)
            if not self.bucket then -- If the trove instance doesn't exist, the scope is likely destroyed
                print("Attempted to use something in scope (" .. Key .. ") but scope is already destroyed:\n" .. CreateDeepTraceback())
                return
            end

            -- Seam things are called as functions, so this is a wrapper
            -- function that puts any created instances into the trove
            local Tuple = nil

            if type(Object) == "function" then
                -- If it's a non-Seam function, let's pass the scope as the first parameter,
                -- then pass in everything else
                Tuple = {Object(self, ...)}
            elseif Object.__SEAM_OBJECT and tostring(Object.__SEAM_OBJECT) == "New" then
                -- For New specifically, we want to actually put scope at the end. In the
                -- future, if seam requires scopes, this will change
                local Args = {...}
                table.insert(Args, self)
                Tuple = {Object(unpack(Args))}
            else
                -- Right now, scope is not passed in to most seam objects
                Tuple = {Object(...)}
            end
    
            -- If nothing returns, don't bother running the rest of the code
            if #Tuple == 0 then
                return
            end

            -- But yeah, let's add created things to the trove
            for _, ThisValue in pairs(Tuple) do
                self.bucket:Add(ThisValue)
            end
    
            -- Unpack the tuple and return it ALLLLLLLL
            return unpack(Tuple)
        end
    end

    function selfClass:InnerScope(NewScopedObjects)
        -- Default to a blank table
        if NewScopedObjects == nil then
            NewScopedObjects = {}
        end

        -- Take the current scoped objects and copy them to the new table
        for Index, Object in pairs(self.ScopedObjects) do
            NewScopedObjects[Index] = Object
        end

        local NewScope = Meta(NewScopedObjects) -- Make a new scope
        self.bucket:Add(NewScope) -- Add the new sub-scope to the parent trove

        return NewScope
    end

    function selfClass:AddObject(Object)
        self.bucket:Add(Object)
    end

    function selfClass:RemoveObject(Object)
        Object:Destroy()
        self.bucket[Object] = nil
    end

    function selfClass:Destroy()
        self.bucket:Destroy()
        self.bucket = nil
    end

    local ScopeInstance = setmetatable(selfClass, selfMeta)
    ScopeInstance.ScopedObjects = ScopedObjects
    ScopeInstance.bucket = bucket.new()

    return ScopeInstance
end

function Scope:__index(Key)
    if Key == "__SEAM_OBJECT" then
        return ClassSymbol
    elseif Key == "__SEAM_CAN_BE_SCOPED" then
        return true
    else
        return nil
    end
end

return Meta