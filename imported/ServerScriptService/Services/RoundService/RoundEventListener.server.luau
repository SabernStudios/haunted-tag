-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remotes
local Remotes = ReplicatedStorage.Shared.Remotes

local roundEvent = Remotes.RoundEvent

-- Custom Services
local Services = ReplicatedStorage.Shared.Services

local RoundService = require(script.Parent)

roundEvent.OnServerEvent:Connect(function(player: Player, eventName: string, payload: {})
	RoundService:OnEvent(player, eventName, payload)
end)
