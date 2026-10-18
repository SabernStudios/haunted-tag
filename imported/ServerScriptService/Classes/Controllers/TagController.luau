local TagController = {}

TagController.__index = TagController

-- Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Import types
local CombatTypes = require(ReplicatedStorage.Shared.Types.Combat.CombatTypes)
type ComboPayload = CombatTypes.ComboPayload
type AttackPayload = CombatTypes.AttackPayload
type ClientAttackPayload = CombatTypes.ClientAttackPayload
type BlockPayload = CombatTypes.BlockPayload
type ClientBlockPayload = CombatTypes.ClientBlockPayload
type StopBlockPayload = CombatTypes.StopBlockPayload
type ClientStopBlockPayload = CombatTypes.ClientStopBlockPayload

local TagTypes = require(ReplicatedStorage.Shared.Types.Tag.TagTypes)
type TagPayload = TagTypes.TagPayload

-- Classes
local Classes = SSS.Classes

-- Actions
local actions = Classes.Actions
local combatActions = actions.Combat
local tagActions = actions.Tag

-- Definitions
local ActionDefinitions = ReplicatedStorage.Shared.Definitions.Actions
local CombatDefinitions = ActionDefinitions.Combat
local AttackDefinition = require(CombatDefinitions.AttackDefinition)
local BlockDefinition = require(CombatDefinitions.BlockDefinition)
local StopBlockDefinition = require(CombatDefinitions.StopBlockDefinition)

local TagDefinition = require(ActionDefinitions.Tag.TagDefinition)

-- Remotes
local Remotes = ReplicatedStorage.Shared.Remotes
local characterAction = Remotes.CharacterAction

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)
local TagService = require(SSS.Services.TagService)

-- Packages
local Signal = require(ReplicatedStorage.Packages.Signal)

function TagController.new(character): TagController
	local self = setmetatable({}, TagController)

	self.Character = character
	self.State = character.State

	self.CharacterInstance = self.Character.Character
	self.Humanoid = self.CharacterInstance:FindFirstChildOfClass("Humanoid")
	self.RootPart = self.CharacterInstance:FindFirstChild("HumanoidRootPart")

	self.combo = 0
	self.maxed = false
	self.lastAttack = 0
	self.isTagged = false

	self.Actions = {
		Tagging = require(tagActions.Tagging),
		Attack = require(combatActions.Attack),
		Block = require(combatActions.Block),
		StopBlock = require(combatActions.StopBlock),
	}

	-- Signals
	self.OnHit = Signal.new()

	self.OnHit:Connect(function(character: Model, stunTime: number)
		self:TakeHit(character, stunTime)
	end)

	return self
end

function TagController:TakeHit(target: Model, stunTime: number)
	local targetCharacter = CharacterService:GetCharacterFromCharacter(target)
	local targetPlayer = Players:GetPlayerFromCharacter(target)

	-- Checks
	if not targetCharacter then
		warn("[TAG_CONTROLLER]: Target is not a character")
		return
	end

	if targetCharacter.State:GetState("Status") == "Ragdolled" then
		return
	end

	if targetCharacter.State:GetState("Status") == "Invincible" then
		return
	end

	targetCharacter.Ragdoll:TryRagdoll(stunTime)
	--targetCharacter.Stun:TryStun(stunTime)

	if targetCharacter.IsNPC then
		targetCharacter.Animation:Play("Stun", 0.1)
	else
		local data = {
			Held = false,
		}

		characterAction:FireClient(targetPlayer :: Player, "Stun", data)
	end
	
	TagService:TagPlayer(Players:GetPlayerFromCharacter(self.CharacterInstance), targetPlayer)

	---- Client
	--CollectionService:AddTag(targetCharacter.Character, "Tagged")

	--task.delay(1, function()
	--	CollectionService:RemoveTag(targetCharacter.Character, "Tagged")
	--end)
end

function TagController:TakeDamage(damage: number)
	self.Humanoid:TakeDamage(damage)
end

function TagController:TryKnockback(direction: Vector3, strength: number)
	local rootPart = self.RootPart

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(100000, 100000, 100000)
	bv.Velocity = direction * strength + Vector3.new(0, 1, 0) * strength
	bv.Parent = rootPart

	game.Debris:AddItem(bv, 0.2)
end

function TagController:PlatformStandCharacter()
	local humanoid = self.CharacterInstance:FindFirstChildOfClass("Humanoid")
	humanoid.PlatformStand = not humanoid.PlatformStand
end

function TagController:TryTag(payload: TagPayload)
	local stateName = TagDefinition.ReturnStateName()
	
	-- Sanity Check
	if not TagService:GetIsTagger(Players:GetPlayerFromCharacter(self.CharacterInstance)) then
		warn("[TAG_CONTROLLER]: Player is not a tagger")
		return
	end
	
	-- Cooldown Checks
	if not self.Character.Cooldown:Ready(stateName :: string) then
		warn("[TAG_CONTROLLER]: Cooldown not ready")
		return
	end
	
	-- State Checks
	if self.State:GetState("Status") == "Ragdolled" or self.State:GetState("Status") == "Stunned" then
		warn("[TAG_CONTROLLER]: Character is ragdolled or stunned")
		return
	end

	-- Execution
	self.Character.TimedState:Apply(stateName :: string, TagDefinition.ReturnComboBuffer() :: number, self.State:GetState("Tag"))
	self.Character.Cooldown:Apply(stateName :: string, TagDefinition.ReturnComboBuffer() :: number)

	local actionPayload = {
		Character = self.CharacterInstance,
		--AttackDef = payload.AttackDef,
		Event = self.OnHit,
	}

	self.Actions.Tagging(actionPayload :: TagPayload)

	local player = Players:GetPlayerFromCharacter(self.CharacterInstance)
	
	characterAction:FireClient(player :: Player, stateName, {})
end

function TagController:TryAttack(payload: TagPayload)
	local stateName = AttackDefinition.ReturnStateName()

	local canSet = self.State:BasicStateMachineValidation(stateName :: string)

	if not canSet then
		return
	end

	-- Cooldown Checks
	if not self.Character.Cooldown:Ready(stateName :: string) then
		warn("[COMBAT_CONTROLLER]: Cooldown not ready")
		return
	end

	-- Execution
	self.Character.TimedState:Apply(stateName :: string, AttackDefinition.ReturnComboBuffer() :: number, self.State:GetState("Combat"))
	self.Character.Cooldown:Apply(stateName :: string, AttackDefinition.ReturnComboBuffer() :: number)

	local comboPayload = {
		--AttackDef = payload.AttackDef,
	}

	self:CalculateCombo(comboPayload :: ComboPayload)

	local actionPayload = {
		Character = self.CharacterInstance,
		Combo = self.combo,
		Maxed = self.maxed,
		--AttackDef = payload.AttackDef,
		Event = self.OnHit,
	}

	self.Actions.Attack(actionPayload :: AttackPayload)

	local player = Players:GetPlayerFromCharacter(self.CharacterInstance)
	local setCombo = self.combo

	if self.maxed then
		setCombo = AttackDefinition.ReturnMaxCombo()
	end

	local data = {
		AttackName = "Melee", -- TODO: get from attackDef
		Combo = setCombo,
		Held = false,
	}

	if self.Character.IsNPC then
		self.Character.Animation:OnActionStarted(stateName, data :: ClientAttackPayload)
	else
		characterAction:FireClient(player :: Player, stateName, data :: ClientAttackPayload)
	end
end

function TagController:TryBlock(payload: BlockPayload)
	local stateName = BlockDefinition.ReturnStateName()

	local canSet = self.State:BasicStateMachineValidation(stateName :: string)

	if not canSet then
		return
	end

	-- Cooldown Checks
	if not self.Character.Cooldown:Ready(stateName :: string) then
		warn("[COMBAT_CONTROLLER]: Cooldown not ready")
		return
	end

	-- Execution
	self.State:SetState("Combat", stateName :: string)

	local actionPayload = {
		Humanoid = self.Humanoid,
		BlockSpeed = self.Character.Movement:ReturnBlockSpeed() :: number,
	}

	self.Actions.Block(actionPayload :: BlockPayload)

	local player = Players:GetPlayerFromCharacter(self.CharacterInstance)

	local data = {
		BlockName = stateName,
		Held = true,
	}

	if self.Character.IsNPC then
		self.Character.Animation:OnActionStarted(stateName, data :: ClientBlockPayload)
	else
		characterAction:FireClient(player :: Player, "Block", data :: ClientBlockPayload)
	end
end

function TagController:TryStopBlock(payload: StopBlockPayload)
	local stateName = StopBlockDefinition.ReturnStateName()

	local canSet = self.State:BasicStateMachineValidation(stateName :: string)

	if not canSet then
		warn("[COMBAT_CONTROLLER]: Cannot transition")
		return
	end

	-- Cooldown Checks
	if not self.Character.Cooldown:Ready(stateName :: string) then
		warn("[COMBAT_CONTROLLER]: Cooldown not ready")
		return
	end

	-- Execution
	self.Character.TimedState:Apply(stateName :: string, StopBlockDefinition.ReturnAnimationLength() :: number, "None")

	local actionPayload = {
		Humanoid = self.Humanoid,
		WalkSpeed = self.Character.Movement:ReturnNormalWalkSpeed(),
	}

	self.Actions.StopBlock(actionPayload :: BlockPayload)

	local player = Players:GetPlayerFromCharacter(self.CharacterInstance)

	local data = {
		StopBlockName = stateName,
	}

	if self.Character.IsNPC then
		self.Character.Animation:OnActionStarted(stateName, data :: ClientStopBlockPayload)
	else
		characterAction:FireClient(player :: Player, "StopBlock", data :: ClientStopBlockPayload)
	end
end

type TagController = typeof(TagController) & {

}

return TagController