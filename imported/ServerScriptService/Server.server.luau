local PS = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Controller Data
local controllerDataTable = {}

-- Classes
local BaseCharacterClass = require(SSS.Classes.Character.BaseCharacterClass)

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)
local EnemyService = require(SSS.Services.EnemyService)
local PowerupService = require(SSS.Services.PowerupService)
local RoundService = require(SSS.Services.RoundService)
local TaskService = require(SSS.Services.TaskService)
local TagService = require(SSS.Services.TagService)

local function onPlayerAdded(player: Player)
	local character = player.Character or player.CharacterAdded:Wait()
	
	BaseCharacterClass.new({
		name = player.Name,
		character = character,
	})

	TaskService:CreatePlayerTasks(player)
	
	--RoundService:SpawnPlayerInLobby(player)
end

PS.PlayerAdded:Connect(function(player: Player)
	onPlayerAdded(player)
	
	player.CharacterAdded:Connect(function(character: Model)
		local newControllerData
		if controllerDataTable[player] then
			newControllerData = controllerDataTable[player]
			newControllerData[player] = nil
		else
			newControllerData = {}
			controllerDataTable[player] = newControllerData
		end
		BaseCharacterClass.new({
			name = player.Name,
			character = character,
			controllerData = newControllerData
		})
		
		--RoundService:SpawnPlayerInLobby(player)
	end)
	
	player.CharacterRemoving:Connect(function(character: Model)
		local controllerData = CharacterService:GetCharacterFromCharacter(character):GetControllerData()
		controllerDataTable[player] = controllerData
		CharacterService:UnregisterCharacter(character)
		
		if TagService:GetIsTagger(player) then
			TagService:RemoveTagger(player)
		end
	end)
end)

PS.PlayerRemoving:Connect(function(player: Player)
	table.remove(CharacterService.Characters, table.find(CharacterService.Characters, player))
	
	if TagService:GetIsTagger(player) then
		TagService:RemoveTagger(player)
	end
	-- TODO: Save data
end)

--PowerupService:Init()

task.wait(4)

--RoundService:StartRound()
