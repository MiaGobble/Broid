local Bucket = {}
Bucket.__index = Bucket

-- Constants
local TABLE_CLEANUP_METHODS = {
	"Destroy",
	"Disconnect",
	"Cleanup",
	"Clean",
	"Cancel",
}

local function GetMatchingCleanupCallback(Object, CleanupMethodName)
	local ThisType = type(Object)

	if ThisType == "function" then
		return Object
	elseif ThisType == "thread" then
		-- return function()
		-- 	task.cancel(Object)
		-- end
	end

	if ThisType == "table" then
		if CleanupMethodName then
			return Object[CleanupMethodName]
		end

		for _, GenericCleanupName in pairs(TABLE_CLEANUP_METHODS) do
			if type(Object[GenericCleanupName]) == "function" then
				return Object[GenericCleanupName]
			end

			if type(Object[GenericCleanupName:lower()]) == "function" then
				return Object[GenericCleanupName:lower()]
			end
		end
	end

	error("No cleanup function found for object")
end

function Bucket.new()
	local self = setmetatable({}, Bucket)

	self.CleanupQueue = {}
	self.IsCleaning = false

	return self
end

function Bucket:Add(Object, CleanupMethodName)
	if self.IsCleaning then
		error("Cannot add an object to bucket during cleanup")
	end

	self.CleanupQueue[Object] = GetMatchingCleanupCallback(Object, CleanupMethodName)
end

function Bucket:AddPromise(Object)
	if self.IsCleaning then
		error("Cannot add a promise to bucket during cleanup")
	end

	--AssertPromiseValidity(Object)

	if Object:getStatus() == "Started" then
		Object:finally(function()
			if self.IsCleaning then
				return
			end

			self.CleanupQueue[Object] = nil
		end)

		self:Add(Object)
	end

	return Object
end

function Bucket:Extend()
	if self.IsCleaning then
		error("Can't extend bucket when cleaning")
	end

	local SubBucket = Bucket.new()

	self:Add(SubBucket)

	return SubBucket
end

function Bucket:Remove(Object)
	if self.IsCleaning then
		error("Can't remove object when cleaning")
	end

	self.CleanupQueue[Object] = nil
end

function Bucket:GetWrappedDestroy()
	return function()
		self:Destroy()
	end
end

function Bucket:Destroy()
	if not self.CleanupQueue or self.IsCleaning then
		return
	end
	
	self.IsCleaning = true

	for Object, CleanupCallback in pairs(self.CleanupQueue) do
        coroutine.wrap(function()
            CleanupCallback(Object)
        end)()

		self.CleanupQueue[Object] = nil
	end

    for index, _ in pairs(self) do
        self[index] = nil
    end
end

return Bucket