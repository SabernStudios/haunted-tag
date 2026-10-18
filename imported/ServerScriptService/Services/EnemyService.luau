local EnemyService = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Classes
local Classes = SSS.Classes
local BaseCharacterClass = require(Classes.Character.BaseCharacterClass)

-- Injectable
local injectableFunctions = {
	GetNearestCharacter = function(enemyRootPart: BasePart)
		return EnemyService:GetNearestCharacter(enemyRootPart)
	end,
	GetNearestCharacterInRange = function(enemyRootPart: BasePart, range: number)
		return EnemyService:GetNearestCharacterInRange(enemyRootPart, range)
	end,
}

-- Spawn functions
function EnemyService.SpawnDummy(self: EnemyService, position: Vector3)
	local dummy = ReplicatedStorage.Assets.NPCs.Dummy:Clone()
	dummy.Parent = workspace
	dummy:PivotTo(CFrame.new(position))
	
	BaseCharacterClass.new({
		name = "Dummy",
		character = dummy,
		NPCData = {
			IsNPC = true,
			IsSmart = false,
			IsDummy = true,
			DummyType = "None",
			EnemyType = "Dummy",
		},
	})
end

function EnemyService.SpawnAttackDummy(self: EnemyService, position: Vector3)
	local attackDummy = ReplicatedStorage.Assets.NPCs.AttackDummy:Clone()
	attackDummy.Parent = workspace
	attackDummy:PivotTo(CFrame.new(position))

	BaseCharacterClass.new({
		name = "Dummy",
		character = attackDummy,
		NPCData = {
			IsNPC = true,
			IsSmart = false,
			IsDummy = true,
			DummyType = "Attack",
			EnemyType = "Dummy",
		},
	})
end

function EnemyService.SpawnBlockDummy(self: EnemyService, position: Vector3)
	local blockDummy = ReplicatedStorage.Assets.NPCs.BlockDummy:Clone()
	blockDummy.Parent = workspace
	blockDummy:PivotTo(CFrame.new(position))
	
	BaseCharacterClass.new({
		name = "BlockDummy",
		character = blockDummy,
		NPCData = {
			IsNPC = true,
			IsSmart = false,
			IsDummy = true,
			DummyType = "Block",
			EnemyType = "Dummy",
		},
	})
end

function EnemyService.SpawnStaticEnemy(self: EnemyService, position: Vector3)
	local staticEnemy = ReplicatedStorage.Assets.NPCs.StaticEnemy:Clone()
	staticEnemy.Parent = workspace
	staticEnemy:PivotTo(CFrame.new(position))
	
	BaseCharacterClass.new({
		name = "StaticEnemy",
		character = staticEnemy,
		NPCData = {
			IsNPC = true,
			IsSmart = false,
			IsDummy = false,
			DummyType = "None",
			EnemyType = "StaticEnemy",
			EnemyFunctions = injectableFunctions,
			AgentParams = {
				AgentCanClimb = true,
			},
		},
	})
end

-- Enemy look-up functions
function EnemyService.GetNearestCharacter(self: EnemyService, enemyRootPart: Part)
	local playerTable = Players:GetPlayers()
	local nearestCharacter = nil
	local nearestDistance = math.huge
	
	for _, player in playerTable do
		if player.Character then
			local character = player.Character
			local distance = (character:GetPivot().Position - enemyRootPart.Position).Magnitude
			
			if distance < nearestDistance then
				nearestDistance = distance
				nearestCharacter = character
			end
		end
	end
	
	return nearestCharacter
end

function EnemyService.GetNearestCharacterInRange(self: EnemyService, enemyRootPart: Part, range: number)
	local playerTable = Players:GetPlayers()
	local nearestCharacter = nil
	local nearestDistance = math.huge
	
	for _, player in playerTable do
		if player.Character then
			local character = player.Character
			local distance = (character:GetPivot().Position - enemyRootPart.Position).Magnitude
			
			if distance < nearestDistance and distance <= range then
				nearestDistance = distance
				nearestCharacter = character
			end
		end
	end
	
	return nearestCharacter
end

type EnemyService = typeof(EnemyService) & {
	
}

return EnemyService
