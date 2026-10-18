local CombatController = {}

CombatController.__index = CombatController

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

-- Classes
local Classes = SSS.Classes

-- Actions
local actions = Classes.Actions
local combatActions = actions.Combat

-- Definitions
local ActionDefinitions = ReplicatedStorage.Shared.Definitions.Actions
local CombatDefinitions = ActionDefinitions.Combat
local AttackDefinition = require(CombatDefinitions.AttackDefinition)
local BlockDefinition = require(CombatDefinitions.BlockDefinition)
local StopBlockDefinition = require(CombatDefinitions.StopBlockDefinition)

-- Remotes
local Remotes = ReplicatedStorage.Shared.Remotes
local characterAction = Remotes.CharacterAction

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)

-- Packages
local Signal = require(ReplicatedStorage.Packages.Signal)

function CombatController.new(character): CombatController
	local self = setmetatable({}, CombatController)
	
	self.Character = character
	self.State = character.State
	
	self.CharacterInstance = self.Character.Character
	self.Humanoid = self.CharacterInstance:FindFirstChildOfClass("Humanoid")
	self.RootPart = self.CharacterInstance:FindFirstChild("HumanoidRootPart")
	
	self.combo = 0
	self.maxed = false
	self.lastAttack = 0
	
	self.Actions = {
		Attack = require(combatActions.Attack),
		Block = require(combatActions.Block),
		StopBlock = require(combatActions.StopBlock),
	}
	
	-- Signals
	self.OnHit = Signal.new()
	
	self.OnHit:Connect(function(character: Model, damage: number, direction: Vector3, knockback: number, stunTime: number, maxed: boolean, unblockable: boolean)
		self:TakeHit(character, damage, direction, knockback, stunTime, maxed, unblockable)
	end)
	
	return self
end

function CombatController:CalculateCombo(payload: ComboPayload): number
	local attackDef = AttackDefinition -- TODO: Change this to work for multiple weapons/attacks
	
	local now = time()
	local timeSinceLastAttack = now - self.lastAttack
	
	if timeSinceLastAttack > attackDef.ReturnComboBuffer() then
		self.maxed = false
		
		if timeSinceLastAttack < attackDef.ReturnComboResetTime() then
			self.combo += 1
			
			if self.combo % attackDef.ReturnMaxCombo() == 0 then
				self.combo = 0
				self.maxed = true
				
				self.Character.Cooldown:Apply(attackDef.ReturnStateName() :: string, AttackDefinition.ReturnComboCooldown() :: number)
			end
		else
			if self.combo == 0 then
				self.combo += 1
			else
				self.combo = 1
			end
		end
		
		self.lastAttack = now
	end
end

function CombatController:TakeHit(target: Model, damage: number, direction: Vector3, knockback: number, stunTime: number, maxed: boolean, unblockable: boolean, minDotProduct: number)
	local targetCharacter = CharacterService:GetCharacterFromCharacter(target)
	local targetPlayer = Players:GetPlayerFromCharacter(target)
	
	-- Checks
	if not targetCharacter then
		warn("[COMBAT_CONTROLLER]: Target is not a character")
		return
	end
	
	local targetDirection = target.HumanoidRootPart.CFrame.LookVector
	
	if targetCharacter.State:GetState("Combat") == "Block" and not unblockable and direction:Dot(targetDirection) <= BlockDefinition.ReturnMinDotProduct() then
		if targetCharacter.IsNPC then
			targetCharacter.Animation:PlayThenHold("Block_Hit", "Block_Held", 0.1)
		else
			local data = {
				Held = true,
			}
			
			characterAction:FireClient(targetPlayer :: Player, "Block_Hit", data)
		end
		
		return
	end
	
	if targetCharacter.State:GetState("Status") == "Ragdolled" then
		return
	end
	
	if targetCharacter.State:GetState("Status") == "Invincible" then
		return
	end
	
	targetCharacter.Combat:TakeDamage(damage)
	targetCharacter.Combat:TryKnockback(direction, knockback)
	
	targetCharacter.Stun:TryStun(stunTime)
	
	if targetCharacter.IsNPC then
		targetCharacter.Animation:Play("Stun", 0.1)
	else
		local data = {
			Held = false,
		}
		
		characterAction:FireClient(targetPlayer :: Player, "Stun", data)
	end
	
	if maxed then
		targetCharacter.Ragdoll:TryRagdoll(stunTime * 2)
	end
	
	-- Client
	CollectionService:AddTag(targetCharacter.Character, "Tagged")
	
	task.delay(0.1, function()
		CollectionService:RemoveTag(targetCharacter.Character, "Tagged")
	end)
end

function CombatController:TakeDamage(damage: number)
	self.Humanoid:TakeDamage(damage)
end

function CombatController:TryKnockback(direction: Vector3, strength: number)
	local rootPart = self.RootPart
	
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(100000, 100000, 100000)
	bv.Velocity = direction * strength + Vector3.new(0, 1, 0) * strength
	bv.Parent = rootPart
	
	game.Debris:AddItem(bv, 0.2)
end

function CombatController:PlatformStandCharacter()
	local humanoid = self.CharacterInstance:FindFirstChildOfClass("Humanoid")
	humanoid.PlatformStand = not humanoid.PlatformStand
end

function CombatController:TryAttack(payload: AttackPayload)
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

function CombatController:TryBlock(payload: BlockPayload)
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

function CombatController:TryStopBlock(payload: StopBlockPayload)
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

type CombatController = typeof(CombatController) & {
	
}

return CombatController
