local StopBlockDefinition = {}

local STATE_NAME = "StopBlock"

local ANIMATION_LENGTH = 0.13333

function StopBlockDefinition.ReturnStateName()
	return STATE_NAME
end

function StopBlockDefinition.ReturnAnimationLength()
	return ANIMATION_LENGTH
end

return StopBlockDefinition
