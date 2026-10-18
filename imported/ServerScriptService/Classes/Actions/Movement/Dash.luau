-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Defintion
local DashDefinition = require(ReplicatedStorage.Shared.Definitions.Actions.Movement.DashDefinition)
type DashPayload = DashDefinition.DashPayload

return function (payload: {})
	local stateName = DashDefinition.ReturnStateName()
	
	local rootPart: BasePart = payload.RootPart
	local direction = payload.Direction
	
	local START_DASH_VELOCITY = DashDefinition.ReturnStartDashVelocity()
	local DASH_DURATION = DashDefinition.ReturnDashDuration()
	local DASH_RATE = DashDefinition.ReturnDashRate()
	local DASH_STRENGTH_INCREMENT = DashDefinition.ReturnDashStrengthIncrement()
	local MIN_DASH_STRENGTH = DashDefinition.ReturnMinDashStrength()
	
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
	bodyVelocity.Parent = rootPart

	local dashStrength = START_DASH_VELOCITY

	for i = 0, DASH_DURATION, DASH_RATE do
		bodyVelocity.Velocity = Vector3.new(direction.X, 0, direction.Z) * dashStrength

		if dashStrength > MIN_DASH_STRENGTH then
			dashStrength -= DASH_STRENGTH_INCREMENT

			if dashStrength < MIN_DASH_STRENGTH then
				dashStrength = MIN_DASH_STRENGTH
			end
		end

		task.wait(DASH_RATE)
	end

	bodyVelocity:Destroy()
end
