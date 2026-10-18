local CooldownController = {}
CooldownController.__index = CooldownController

function CooldownController.new(baseCharacter)
	local self = setmetatable({}, CooldownController)
	
	self.Cooldowns = {}
	
	return self
end

function CooldownController:Apply(stateName: string, duration: number)
	self.Cooldowns[stateName] = time() + duration
end

function CooldownController:Ready(stateName: string)
	if not self.Cooldowns[stateName] or self.Cooldowns[stateName] == nil then
		return true
	end
	
	if self.Cooldowns[stateName] < time() then
		return true
	end
	
	return false
end

function CooldownController:ClearCooldown(stateName: string)
	self.Cooldowns[stateName] = nil
end

return CooldownController
