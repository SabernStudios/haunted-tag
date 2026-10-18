local SlideDefinition = {}

local STATE_NAME = "Slide"

local START_SLIDE_VELOCITY = 275
local SLIDE_DURATION = 0.4
local SLIDE_COOLDOWN = SLIDE_DURATION + 4
local SLIDE_RATE = 0.015
local SLIDE_ITERATIONS = math.floor(SLIDE_DURATION / SLIDE_RATE)
local SLIDE_STRENGTH_INCREMENT = START_SLIDE_VELOCITY/SLIDE_ITERATIONS
local MIN_SLIDE_STRENGTH = START_SLIDE_VELOCITY * 0.2

function SlideDefinition.ReturnStateName()
	return STATE_NAME
end

function SlideDefinition.ReturnStartSlideVelocity()
	return START_SLIDE_VELOCITY
end

function SlideDefinition.ReturnSlideDuration()
	return SLIDE_DURATION
end

function SlideDefinition.ReturnSlideCooldown()
	return SLIDE_COOLDOWN
end

function SlideDefinition.ReturnSlideRate()
	return SLIDE_RATE
end

function SlideDefinition.ReturnSlideIterations()
	return SLIDE_ITERATIONS
end

function SlideDefinition.ReturnSlideStrengthIncrement()
	return SLIDE_STRENGTH_INCREMENT
end

function SlideDefinition.ReturnMinSlideStrength()
	return MIN_SLIDE_STRENGTH
end

export type SlidePayload = {
	Direction: Vector3,
}

return SlideDefinition
