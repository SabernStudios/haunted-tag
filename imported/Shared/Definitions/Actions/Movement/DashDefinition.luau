local DashDefinition = {}

local STATE_NAME = "Dash"

local START_DASH_VELOCITY = 200
local DASH_DURATION = 0.4
local DASH_COOLDOWN = DASH_DURATION + 1
local DASH_RATE = 0.015
local DASH_ITERATIONS = math.floor(DASH_DURATION / DASH_RATE)
local DASH_STRENGTH_INCREMENT = START_DASH_VELOCITY/DASH_ITERATIONS
local MIN_DASH_STRENGTH = START_DASH_VELOCITY * 0.2

function DashDefinition.ReturnStateName()
	return STATE_NAME
end

function DashDefinition.ReturnStartDashVelocity()
	return START_DASH_VELOCITY
end

function DashDefinition.ReturnDashDuration()
	return DASH_DURATION
end

function DashDefinition.ReturnDashCooldown()
	return DASH_COOLDOWN
end

function DashDefinition.ReturnDashRate()
	return DASH_RATE
end

function DashDefinition.ReturnDashIterations()
	return DASH_ITERATIONS
end

function DashDefinition.ReturnDashStrengthIncrement()
	return DASH_STRENGTH_INCREMENT
end

function DashDefinition.ReturnMinDashStrength()
	return MIN_DASH_STRENGTH
end

export type DashPayload = {
	Direction: Vector3,
}

return DashDefinition
