-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Definition
local StopSprintDefinition = require(ReplicatedStorage.Shared.Definitions.Actions.Movement.StopSprintDefinition)
type StopSprintPayload = StopSprintDefinition.StopSprintPayload

return function (payload: StopSprintPayload)
	local clientHumanoid = payload.Humanoid
	clientHumanoid.WalkSpeed = payload.WalkSpeed
end