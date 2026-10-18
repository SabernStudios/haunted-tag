-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Import Types
local types = ReplicatedStorage.Shared.Types
local CombatTypes = require(types.Combat.CombatTypes)

type BlockPayload = CombatTypes.BlockPayload

return function(payload: BlockPayload)
	local clientHumanoid = payload.Humanoid
	
	clientHumanoid.WalkSpeed = payload.BlockSpeed
end
