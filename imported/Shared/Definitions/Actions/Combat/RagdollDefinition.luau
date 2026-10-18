local RagdollDefinition = {}

local STATE_NAME = "Ragdolled"

local INVINCIBLE_TIME = 0.75

function RagdollDefinition.ReturnStateName()
	return STATE_NAME
end

function RagdollDefinition.ReturnInvincibleTime()
	return INVINCIBLE_TIME
end

return RagdollDefinition
