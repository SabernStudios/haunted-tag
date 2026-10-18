-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local powerupSpawnObjects = {}

-- Classes
local PowerupSpawnerClass = require(SSS.Classes.Exterior.PowerupSpawnerClass)

local PowerupService = {}

function PowerupService.Init(self: PowerupService, powerupSpawnerFolder: Folder)
	self:Reset()
	
	for _, spawnModel in powerupSpawnerFolder:GetChildren() do
		local powerupSpawner = PowerupSpawnerClass.new(spawnModel)
		
		table.insert(powerupSpawnObjects, powerupSpawner)
	end
end

function PowerupService.Reset(self: PowerupService)
	for _, powerupSpawner in powerupSpawnObjects do
		powerupSpawner:Destroy()
	end
end

type PowerupService = typeof(PowerupService) & {
	
}

return PowerupService
