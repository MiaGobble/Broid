-- Author: iGottic

local ValuePacker = {}

-- Variables
local Converter = {}

Converter.number = {
	Pack = function(UnpackedValue)
		return UnpackedValue[1]
	end,

	Unpack = function(Value)
		return {Value}
	end,
}

-- Converts a value into a table
function ValuePacker.UnpackValue(Value, ValueType)
	if Converter[ValueType] then
		return Converter[ValueType].Unpack(Value)
	end

	return {}
end

-- Converts a table into a value
function ValuePacker.PackValue(UnpackedValue, ValueType)
	if Converter[ValueType] then
		return Converter[ValueType].Pack(UnpackedValue)
	end

	return nil
end

return ValuePacker