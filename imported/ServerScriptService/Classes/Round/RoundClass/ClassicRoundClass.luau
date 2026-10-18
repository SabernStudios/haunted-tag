-- Classes
local RoundClass = require(script.Parent)

local ClassicRoundClass = {}
ClassicRoundClass.__index = ClassicRoundClass
setmetatable(ClassicRoundClass, {__index = RoundClass})

function ClassicRoundClass.new(): ClassicRoundClass
	local self = RoundClass.new() :: ClassicRoundClass
	
	return self
end

type ClassicRoundClass = typeof(ClassicRoundClass) & {

}

return ClassicRoundClass

