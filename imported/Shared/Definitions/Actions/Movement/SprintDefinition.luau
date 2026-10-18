local SprintDefinition = {}

local STATE_NAME = "Sprint"
local SPRINT_SPEED = 40

function SprintDefinition.ReturnStateName()
	return STATE_NAME
end

function SprintDefinition.ReturnSprintSpeed()
	return SPRINT_SPEED
end

export type SprintPayload = {
	Humanoid: Humanoid,
	SprintSpeed: number,
}

return SprintDefinition
