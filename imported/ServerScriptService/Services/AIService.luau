local AIService = {}

-- Services
local RunService = game:GetService("RunService")

AIService.Brains = {}

function AIService.RegisterBrain(self: AIService, brain)
	AIService.Brains[brain] = true
end

function AIService.UnregisterBrain(self: AIService, brain)
	AIService.Brains[brain] = nil
end

RunService.Heartbeat:Connect(function(deltaTime: number)
	for brain in pairs(AIService.Brains) do
		brain:Update(deltaTime :: number)
	end
end)

type AIService = typeof(AIService) & {
	
}

return AIService
