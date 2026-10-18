-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Definition
local SprintDefinition = require(ReplicatedStorage.Shared.Definitions.Actions.Movement.SprintDefinition)
type SprintPayload = SprintDefinition.SprintPayload

return function (payload: SprintPayload)
	local clientHumanoid = payload.Humanoid
	clientHumanoid.WalkSpeed = payload.SprintSpeed
end
