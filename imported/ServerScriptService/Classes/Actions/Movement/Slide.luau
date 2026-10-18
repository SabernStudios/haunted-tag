-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Defintion
local SlideDefinition = require(ReplicatedStorage.Shared.Definitions.Actions.Movement.SlideDefinition)
type SlidePayload = SlideDefinition.SlidePayload

return function (payload: {})
	local stateName = SlideDefinition.ReturnStateName()

	local rootPart: BasePart = payload.RootPart
	local direction = payload.Direction

	local START_SLIDE_VELOCITY = SlideDefinition.ReturnStartSlideVelocity()
	local SLIDE_DURATION = SlideDefinition.ReturnSlideDuration()
	local SLIDE_RATE = SlideDefinition.ReturnSlideRate()
	local SLIDE_STRENGTH_INCREMENT = SlideDefinition.ReturnSlideStrengthIncrement()
	local MIN_SLIDE_STRENGTH = SlideDefinition.ReturnMinSlideStrength()

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
	bodyVelocity.Parent = rootPart

	local dashStrength = START_SLIDE_VELOCITY

	for i = 0, SLIDE_DURATION, SLIDE_RATE do
		bodyVelocity.Velocity = Vector3.new(direction.X, 0, direction.Z) * dashStrength

		if dashStrength > MIN_SLIDE_STRENGTH then
			dashStrength -= SLIDE_STRENGTH_INCREMENT

			if dashStrength < MIN_SLIDE_STRENGTH then
				dashStrength = MIN_SLIDE_STRENGTH
			end
		end

		task.wait(SLIDE_RATE)
	end

	bodyVelocity:Destroy()
end