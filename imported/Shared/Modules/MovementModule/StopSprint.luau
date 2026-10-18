local StopSprint = {}

return {
	duration = nil,
	cooldown = nil,
	execute = function(payload: {})
		local player = payload.player
		local character = player.Character
		local humanoid = character:WaitForChild("Humanoid")

		humanoid.WalkSpeed = 16
	end
} 