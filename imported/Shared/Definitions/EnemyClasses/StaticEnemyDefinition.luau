local StaticEnemyDefinition = {}

local ATTACK_RANGE = 10
local REACTION_TIME = 0.4
local SPRINT_DURATION = 3

local RANGE = 100

local UPDATE_TIME = 0.1

function StaticEnemyDefinition.ReturnAttackRange()
	return ATTACK_RANGE
end

function StaticEnemyDefinition.ReturnReactionTime()
	return REACTION_TIME
end

function StaticEnemyDefinition.ReturnSprintDuration()
	return SPRINT_DURATION
end

function StaticEnemyDefinition.ReturnRange()
	return RANGE
end

function StaticEnemyDefinition.ReturnUpdateTime()
	return UPDATE_TIME
end

return StaticEnemyDefinition
