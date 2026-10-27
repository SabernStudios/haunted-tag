local MovementController = {}
MovementController.__index = MovementController

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Actions
local actions = SSS.Classes.Actions
local movementActions = actions.Movement

-- Action Defintions
local definitions = ReplicatedStorage.Shared.Definitions.Actions
local movementActionDefinitions = definitions.Movement

local DashDefinition = require(movementActionDefinitions.DashDefinition)
type DashPayload = DashDefinition.DashPayload

local SprintDefinition = require(movementActionDefinitions.SprintDefinition)
type SprintPayload = SprintDefinition.SprintPayload

local StopSprintDefinition = require(movementActionDefinitions.StopSprintDefinition)
type StopSprintPayload = StopSprintDefinition.StopSprintPayload

local SlideDefinition = require(movementActionDefinitions.SlideDefinition)
type SlidePayload = SlideDefinition.SlidePayload

-- Remotes
local Remotes = ReplicatedStorage.Shared.Remotes
local characterAction = Remotes.CharacterAction

-- RS Modules
local MovementModule = require(ReplicatedStorage.Shared.Modules.MovementModule)

function MovementController.new(character): MovementController
	local self = setmetatable({}, MovementController)
	
	self.Character = character
	self.State = character.State
	
	self.CharacterInstance = self.Character.Character
	self.Humanoid = self.CharacterInstance:FindFirstChildOfClass("Humanoid")
	self.RootPart = self.CharacterInstance:FindFirstChild("HumanoidRootPart")
	
	self.Actions = {
		Dash = require(movementActions.Dash),
		Slide = require(movementActions.Slide),
		Sprint = require(movementActions.Sprint),
		StopSprint = require(movementActions.StopSprint),
	}
	
	-- Attributes
	self.CorrectedWalkSpeed = StopSprintDefinition.ReturnWalkSpeed()
	self.CorrectedSprintSpeed = SprintDefinition.ReturnSprintSpeed()
	self.BaseWalkSpeed = StopSprintDefinition.ReturnWalkSpeed()
	self.BaseSprintSpeed = SprintDefinition.ReturnSprintSpeed()
	self.WalkSpeed = StopSprintDefinition.ReturnWalkSpeed()
	self.SprintSpeed = SprintDefinition.ReturnSprintSpeed()
	self.BlockSpeed = 10
	
	return self
end

-- Actions
function MovementController:TrySlide(payload: SlidePayload)
	local clientDirection = payload.Direction

	local stateName = SlideDefinition.ReturnStateName()

	-- Checks

	-- Payload Checks
	if not clientDirection then
		warn("[MOVEMENT_CONTROLLER]: Invalid direction")
		return
	end

	-- Direction Checks
	local delayedDirection = MovementModule.ReturnIntendedDashDirection(self.Humanoid :: Humanoid)
	local usedDirection

	usedDirection = clientDirection

	if clientDirection:Dot(delayedDirection) <= 0 then
		usedDirection = delayedDirection
	end

	-- State Checks
	local canSet = self.State:BasicStateMachineValidation(stateName :: string)

	if not canSet then
		warn("[MOVEMENT_CONTROLLER]: Cannot transition")
		return
	end

	-- Cooldown Checks
	if not self.Character.Cooldown:Ready(stateName :: string) then
		warn("[MOVEMENT_CONTROLLER]: Cooldown not ready")
		return
	end
	
	-- Player Check
	local player = Players:GetPlayerFromCharacter(self.CharacterInstance)
	
	if not player then
		warn("[MOVEMENT_CONTROLLER]: Invalid player")
		return
	end

	-- Payload Tweaking
	local newPayload = {
		RootPart = self.RootPart,
		Humanoid = self.Humanoid,
		Direction = usedDirection,
	}

	-- Execution
	self.Character.TimedState:Apply(stateName :: string, SlideDefinition.ReturnSlideDuration() :: number, self.State:GetState("Movement"))
	self.Character.Cooldown:Apply(stateName :: string, SlideDefinition.ReturnSlideCooldown() :: number)
	
	characterAction:FireClient(player :: Player, stateName, {})

	self.Actions.Slide(newPayload :: {})
end

function MovementController:TrySprint()
	local stateName = SprintDefinition.ReturnStateName()
	-- Checks
	
	-- Payload Checks
	if not self.Humanoid or not self.Humanoid:IsA("Humanoid") then
		warn("[MOVEMENT_CONTROLLER]: Invalid humanoid")
		return
	end
	
	-- State Checks
	local canSet = self.State:BasicStateMachineValidation("Sprint")
	
	if not canSet then
		return
	end
	
	local player = Players:GetPlayerFromCharacter(self.CharacterInstance)
	
	-- Execution
	self.State:SetState("Movement", "Sprint")
	
	local payload = {
		Humanoid = self.Humanoid,
		SprintSpeed = self.SprintSpeed
	}
	
	self.Actions.Sprint(payload :: SprintPayload)
end

function MovementController:TryStopSprint()
	local canSet = self.State:BasicStateMachineValidation("StopSprint")

	if not canSet then
		return
	end
	
	-- Execution
	self.State:SetState("Movement", "Idle")
	
	local payload = {
		Humanoid = self.Humanoid,
		WalkSpeed = self.WalkSpeed
	}
	
	self.Actions.StopSprint(payload :: StopSprintPayload)
end

function MovementController:Cancel()
	
end

type MovementController = typeof(MovementController) & {
	
}

return MovementController
