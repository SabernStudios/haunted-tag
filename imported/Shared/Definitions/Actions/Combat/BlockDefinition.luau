local BlockDefinition = {}

local STATE_NAME = "Block"

local MIN_ANGLE = 80 -- This number represents the minimum angle between the block direction and the attack direction in degrees that is protected from damage (0-180)
local MIN_DOT_PRODUCT = math.cos(math.rad(MIN_ANGLE))

function BlockDefinition.ReturnStateName()
	return STATE_NAME
end

function BlockDefinition.ReturnMinAngle()
	return MIN_ANGLE
end

function BlockDefinition.ReturnMinDotProduct()
	return MIN_DOT_PRODUCT
end

return BlockDefinition
