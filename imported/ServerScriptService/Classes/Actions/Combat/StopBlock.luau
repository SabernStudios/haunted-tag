-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Import Types
local types = ReplicatedStorage.Shared.Types
local CombatTypes = require(types.Combat.CombatTypes)

type StopBlockPayload = CombatTypes.StopBlockPayload

return function(payload: StopBlockPayload)
	local clientHumanoid = payload.Humanoid

	clientHumanoid.WalkSpeed = payload.WalkSpeed
end
