local STATE_NAME = "StopSprint"

local WalkSpeed = 16

local StopSprintDefinition = {}

function StopSprintDefinition.ReturnStateName()
	return STATE_NAME
end

function StopSprintDefinition.ReturnWalkSpeed()
	return WalkSpeed
end

export type StopSprintPayload = {
	Humanoid: Humanoid,
	WalkSpeed: number,
}

return StopSprintDefinition
