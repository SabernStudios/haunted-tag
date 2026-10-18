-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Classes
local PowerupClass = require(script.Parent)

-- Assets
local Assets = ReplicatedStorage.Assets
local TwoTimesSpeed = Assets.Powerups.TwoTimesSpeed

local TwoTimesSpeedClass = {}
TwoTimesSpeedClass.__index = TwoTimesSpeedClass
setmetatable(TwoTimesSpeedClass, {__index = PowerupClass})

function TwoTimesSpeedClass.new(): TwoTimesSpeedClass
	local isAction = false
	local speedMultiplier = 1.5
	
	local self = PowerupClass.new(TwoTimesSpeed:Clone() :: Model, TwoTimesSpeed, speedMultiplier .. "x Speed", "Speed", isAction)
	setmetatable(self, TwoTimesSpeedClass)
	
	self.SpeedMultiplier = speedMultiplier
	
	self.PowerupType = self.SpeedMultiplier .. "x Speed"
	self.Duration = 3
	
	return self
end

function TwoTimesSpeedClass:Activate(baseCharacter, token)
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

type TwoTimesSpeedClass = typeof(TwoTimesSpeedClass) & {
	
}

return TwoTimesSpeedClass
