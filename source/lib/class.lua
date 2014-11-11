-- Gian Hancock March-April 2014

class = {}

function class:new()
	local newClass = {}
	newClass.metaTable = {["__index"] = newClass} --["__metatable"] = "Please add metatable functions to the <ClassName>.metaTable field"}
	setmetatable(newClass, newClass.metaTable)
	
	function newClass:new(...)
		local newInstance = {}
		setmetatable(newInstance, newClass.metaTable)
		if (newInstance.init) then
			newInstance:init(...)
		end
		return newInstance
	end
	
	return newClass
end