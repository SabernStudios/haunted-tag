-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Classes
local Classes = SSS.Classes

local PowerupClass = require(Classes.Exterior.PowerupClass)
local PowerupClasses = Classes.Exterior.PowerupClass

local TwoTimesSpeedClass = require(PowerupClasses.TwoTimesSpeedClass)
local ThreeTimesSpeedClass = require(PowerupClasses.ThreeTimesSpeedClass)
local InvisibleClass = require(PowerupClasses.InvisibleClass)

local PowerupTable = {
	TwoTimesSpeedClass,
	ThreeTimesSpeedClass,
	InvisibleClass,
}

-- Remotes
local Remotes = ReplicatedStorage.Shared.Remotes

local Pickup = Remotes.Pickup

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)

local StatService = require(SSS.Services.StatService)

local PowerupSpawnerClass = {}
PowerupSpawnerClass.__index = PowerupSpawnerClass

function PowerupSpawnerClass.new(spawnerModel: Model): PowerupSpawnerClass
	local self = setmetatable({}, PowerupSpawnerClass)
	
	self.Model = spawnerModel
	self.PowerupSpawn = spawnerModel:FindFirstChild("PowerupSpawn")
	self.PowerupBase = spawnerModel:FindFirstChild("PowerupBase")
	
	self.Powerup = nil
	
	self.CooldownActive = false
	self.CooldownTime = 25
	
	self:SpawnRandomPowerup()
	
	self.PowerupSpawn.Touched:Connect(function(hit: BasePart)
		-- Check if the hit part is a player
		-- TODO: Add remote event functionality + server behavior
		if self.CooldownActive then
			return
		end
		
		local character = hit:FindFirstAncestorOfClass("Model")
		if not character or not character:FindFirstChild("Humanoid") then
			return
		end
		
		local baseCharacter = CharacterService:GetCharacterFromCharacter(character)
		
		if not baseCharacter then
			return
		end
		
		baseCharacter.Powerup.Powerup = self.Powerup
		
		if not self.Powerup.IsAction then
			baseCharacter.Powerup:TryActivatePowerup()
			
			StatService:IncrementPlayerStat(Players:GetPlayerFromCharacter(character), "PowerupsUsed", 1)
		end
		
		-- If EndTime is ~= 0, powerup will be known as active
		Pickup:FireClient(Players:GetPlayerFromCharacter(character), "Powerup", {EndTime = time() + self.Powerup.Duration, PowerupName = self.Powerup.PowerupName, PowerupModel = self.Powerup.OriginalModel, SpawnerPart = self.PowerupSpawn})
		
		self.Powerup.Model:Destroy()
		self.Powerup = nil

		task.spawn(function()
			self.CooldownActive = true
			task.wait(self.CooldownTime)
			self.CooldownActive = false
			self:SpawnRandomPowerup()
		end)
	end)
	
	return self
end

function PowerupSpawnerClass:SpawnRandomPowerup()
	local randomPowerup = PowerupTable[math.random(1, #PowerupTable)]
	
	local newPowerup = randomPowerup.new()
	newPowerup.Model:PivotTo(CFrame.new(self.PowerupSpawn.CFrame.Position) * CFrame.fromEulerAnglesXYZ(newPowerup.Model:GetPivot():ToEulerAnglesXYZ()))
	newPowerup.Model.Parent = self.PowerupBase
	
	self.Powerup = newPowerup
	
	task.spawn(function()
		while self.Powerup == newPowerup do
			self:SpinPowerup(2)
			task.wait(0.01)
		end
	end)
end

function PowerupSpawnerClass:SpinPowerup(amount: number)
	self.Powerup.Model:PivotTo(self.Powerup.Model:GetPivot() * CFrame.Angles(0, math.rad(amount), 0))
end

function PowerupSpawnerClass:Destroy()
	if self.Model then
		self.Model:Destroy()
	end
	
	if self.Powerup then
		self.Powerup:Destroy()
	end
	
	self = nil
end

type PowerupSpawnerClass = typeof(PowerupSpawnerClass) & {
	
}

return PowerupSpawnerClass
