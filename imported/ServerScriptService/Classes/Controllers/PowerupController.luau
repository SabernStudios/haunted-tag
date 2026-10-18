local PowerupController = {}
PowerupController.__index = PowerupController

function PowerupController.new(baseCharacter): PowerupController
	local self = setmetatable({}, PowerupController)
	
	-- BaseCharacter Stuff
	self.Character = baseCharacter
	self.State = self.Character.State
	
	self.CharacterInstance = self.Character.Character
	
	self.Powerup = nil
	
	self.ActiveToken = {
		Speed = nil,
		Invisible = nil,
	}
	
	return self
end

function PowerupController:TryActivatePowerup()
	if not self.Powerup then
		return
	end
	
	local token = time() + self.Powerup.Duration
	
	self.ActiveToken[self.Powerup.PowerupType] = token
	self.Powerup:Activate(self.Character, token)
	self.Powerup = nil
end

type PowerupController = typeof(PowerupController) & {
	
}

return PowerupController
