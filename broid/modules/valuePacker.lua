-- Author: iGottic

local valuePacker = {}

-- Imports
local oklab = require("broid.modules.oklab")

-- Variables
local converter = {}

converter.number = {
	Pack = function(unpackedValue)
		return unpackedValue[1]
	end,

	Unpack = function(value)
		return {value}
	end,
}

-- converter.table = {
-- 	Pack = function(unpackedValue)
-- 		return unpackedValue
-- 	end,

-- 	Unpack = function(value)
-- 		return value
-- 	end,
-- }

converter.color3 = {
	Pack = function(unpackedValue)
		print("r")
		print(unpackedValue[1])
		print("g")
		print(unpackedValue[2])
		print("b")
		print(unpackedValue[3])
		return oklab.from({X = unpackedValue[1], Y = unpackedValue[2], Z = unpackedValue[3]}, false)
	end,

	Unpack = function(value)
		local oklabValue = oklab.to({R = value[1], G = value[2], B = value[3]})
		return {oklabValue.X, oklabValue.Y, oklabValue.Z}
	end,
}

-- Converts a value into a table
function valuePacker.UnpackValue(value, valueType)
	if converter[valueType] then
		return converter[valueType].Unpack(value)
	end

	print("WARNING: No converter found for value type: " .. valueType)

	return {}
end

-- Converts a table into a value
function valuePacker.PackValue(unpackedValue, valueType)
	if converter[valueType] then
		return converter[valueType].Pack(unpackedValue)
	end

	print("WARNING: No converter found for value type: " .. valueType)

	return nil
end

return valuePacker