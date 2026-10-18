local StunController = {}

StunController.__index = StunController

function StunController.new(character): StunController
	local self = setmetatable({}, StunController)
	
	self.Character = character
	self.State = character.State
	self.ActiveToken = 0
	self.Active = false
	
	self.CharacterInstance = character.Character
	self.Humanoid = self.CharacterInstance:FindFirstChildOfClass("Humanoid")
	self.RootPart = self.CharacterInstance:FindFirstChild("HumanoidRootPart")
	
	self.Actions = {
		
	}
	
	return self
end

function StunController:TryStun(duration)
	local token = tostring(time())
	self.ActiveToken = token
	self.Active = true
	
	self.Humanoid.WalkSpeed = 0
	self.Humanoid.JumpPower = 0
	self.Humanoid.JumpHeight = 0
	
	self.Character.TimedState:Apply("Stunned", duration, "NoStatus")
	self.State:SetState("Movement", "Idle")
	self.State:SetState("Combat", "None")
	
	task.delay(duration, function()
		if self.ActiveToken ~= token then return end
		
		self.Active = false
		self.Humanoid.WalkSpeed = 16
		self.Humanoid.JumpPower = 50
		self.Humanoid.JumpHeight = 7.2
	end)
end

type StunController = typeof(StunController) & {
	
}

return StunController
