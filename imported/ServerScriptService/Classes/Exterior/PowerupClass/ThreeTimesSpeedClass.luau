-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Classes
local PowerupClass = require(script.Parent)

-- Assets
local Assets = ReplicatedStorage.Assets
local ThreeTimesSpeed = Assets.Powerups.ThreeTimesSpeed

local ThreeTimesSpeedClass = {}
ThreeTimesSpeedClass.__index = ThreeTimesSpeedClass
setmetatable(ThreeTimesSpeedClass, {__index = PowerupClass})

function ThreeTimesSpeedClass.new(): ThreeTimesSpeedClass
	local isAction = false
	local speedMultiplier = 1.75
	
	local self = PowerupClass.new(ThreeTimesSpeed:Clone() :: Model, ThreeTimesSpeed :: Model, speedMultiplier .. "x Speed", "Speed", isAction)
	setmetatable(self, ThreeTimesSpeedClass)
	
	self.SpeedMultiplier = speedMultiplier
	
	self.PowerupType = self.SpeedMultiplier .. "x Speed"
	self.Duration = 2.5
	
	return self
end

function ThreeTimesSpeedClass:Activate(baseCharacter, token)
	task.spawn(function()
		baseCharacter.Movement.SprintSpeed = baseCharacter.Movement.CorrectedSprintSpeed * self.SpeedMultiplier
		baseCharacter.Character.Humanoid.WalkSpeed = baseCharacter.Movement.CorrectedSprintSpeed * self.SpeedMultiplier
		
		task.wait(self.Duration)
		
		if baseCharacter.Powerup.ActiveToken[self.PowerupType] ~= token then
			return
		end
		
		baseCharacter.Movement.SprintSpeed = baseCharacter.Movement.CorrectedSprintSpeed
		baseCharacter.Character.Humanoid.WalkSpeed = baseCharacter.Movement.CorrectedSprintSpeed
		
		self:Destroy()
	end)
end

type ThreeTimesSpeedClass = typeof(ThreeTimesSpeedClass) & {
	
}

return ThreeTimesSpeedClass
