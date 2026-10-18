-- Services
local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")

-- Constants
local CHASE_DISTANCE = 50
local CHASE_FIDELITY = 0.1

-- Variables
local activated = false

-- Custom Services
local Services = SSS.Services

local TagService = require(Services.TagService)
local StatService = require(Services.StatService)

local ChaseService = {}

function ChaseService.Init()
	
end

-- This function serves to actively update the chase state of every player in game after a certain fidelity time
function ChaseService.Activate(self: ChaseService)
	activated = true
	
	task.spawn(function()
		while activated do
			for _, player in TagService:GetTaggers() do
				local taggerCharacter = player.Character or player.CharacterAdded:Wait()
				local taggerHRP = taggerCharacter:WaitForChild("HumanoidRootPart")
				
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = {taggerCharacter}
				
				for _, target in Players:GetPlayers() do
					local targetCharacter = target.Character or target.CharacterAdded:Wait()
					local targetHRP = targetCharacter:WaitForChild("HumanoidRootPart")
					
					if (targetHRP.Position - taggerHRP.Position).Magnitude > CHASE_DISTANCE then
						continue
					end
					
					local ray = workspace:Raycast(taggerHRP.Position, 1.2 * (targetHRP.Position - taggerHRP.Position), raycastParams)
					
					if ray then
						StatService:IncrementPlayerStat(target, "TimeSpentInChase", CHASE_FIDELITY)
					else
						
					end
				end
			end
			
			task.wait(CHASE_FIDELITY)
		end
	end)
	
	task.spawn(function()
		while activated do
			for _, player in StatService:GetCurrentRound():GetPlayers() do
				local isTagger = TagService:GetIsTagger(player)
				
				if not isTagger then
					StatService:IncrementPlayerStat(player, "TimeSurvived", CHASE_FIDELITY)
				end
			end
			
			task.wait(CHASE_FIDELITY)
		end
	end)
end

function ChaseService.Deactivate(self: ChaseService)
	activated = false
end

type ChaseService = typeof(ChaseService) & {
	
}

return ChaseService
