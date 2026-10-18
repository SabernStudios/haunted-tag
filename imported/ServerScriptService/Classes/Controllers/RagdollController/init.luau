local RagdollController = {}
RagdollController.__index = RagdollController

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Definitions
local RagdollDefinition = require(ReplicatedStorage.Shared.Definitions.Actions.Combat.RagdollDefinition)

local OriginalJoints = {}

local RagdollControllerUtils = require(script.RagdollControllerUtils)

function RagdollController.new(character): RagdollController
	local self = setmetatable({}, RagdollController)
	
	self.Character = character
	self.State = character.State
	
	self.CharacterInstance = character.Character
	self.Humanoid = self.CharacterInstance:WaitForChild("Humanoid")
	self.Joints = RagdollControllerUtils.SaveJoints(self.CharacterInstance)
	self.ActiveToken = 0
	self.Active = false
	
	return self
end

function RagdollController:TryRagdoll(duration: number)
	local stateName = RagdollDefinition.ReturnStateName()

	local canSet = self.State:BasicStateMachineValidation(stateName :: string)

	if not canSet then
		warn("[RAGDOLL_CONTROLLER]: Cannot transition")
		return
	end
	
	local token = tostring(time())
	self.ActiveToken = token
	self.Active = true
	
	self.Character.TimedState:Apply(stateName, duration, "NoStatus")
	self.State:SetState("Movement", "Idle")
	
	self:RagdollPlayer()
	
	task.delay(duration, function()
		if self.ActiveToken ~= token then return end
		
		self.Active = false
		self.Character.TimedState:ApplyOverride("Invincible", RagdollDefinition.ReturnInvincibleTime(), "NoStatus")
		self.Character.Ragdoll:UnragdollPlayer()
		self.Character.Movement:TrySprint()
	end)
end

-- Ragdoll a character
function RagdollController:RagdollPlayer()
	local character = self.CharacterInstance
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Stop all playing animations
	for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
		track:Stop(0)
	end

	-- Convert Motor6Ds to physics-controlled
	for _, data in pairs(self.Joints or {}) do
		RagdollControllerUtils.Motor6DToSocket(data.Motor)
	end

	-- Enable ragdoll physics
	humanoid.PlatformStand = true
	humanoid.AutoRotate = false
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end

-- Unragdoll a character
function RagdollController:UnragdollPlayer()
	local character = self.CharacterInstance
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Remove BallSocketConstraints and attachments
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("BallSocketConstraint") or obj:IsA("Attachment") then
			if obj.Name:find("_A0") or obj.Name:find("_A1") then
				obj:Destroy()
			end
		end
	end

	-- Re-enable original Motor6Ds
	for _, data in pairs(self.Joints or {}) do
		local motor = data.Motor
		if motor and motor.Parent then
			motor.C0 = data.C0
			motor.C1 = data.C1
			motor.Enabled = true
		end
	end

	-- Restore humanoid movement and animations
	humanoid.PlatformStand = false
	humanoid.AutoRotate = true
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50
	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

type RagdollController = typeof(RagdollController) & {
	
}

return RagdollController
