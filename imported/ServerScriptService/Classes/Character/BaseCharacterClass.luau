local BaseCharacterClass = {}

BaseCharacterClass.__index = BaseCharacterClass

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Replicated Storage
local Shared = ReplicatedStorage.Shared
local Classes = Shared.Classes
local Modules = Shared.Modules

-- Server
local SClasses = SSS.Classes
local Controllers = SClasses.Controllers

-- Base Character Controllers
local CooldownController = require(Controllers.CooldownController)
local CombatController = require(Controllers.CombatController)
local CurrencyController = require(Controllers.CurrencyController)
local InputController = require(Controllers.InputController)
local ItemController = require(Controllers.ItemController)
local MovementController = require(Controllers.MovementController)
local PowerupController = require(Controllers.PowerupController)
local RagdollController = require(Controllers.RagdollController)
local StateMachine = require(Controllers.StateMachine)
local StunController = require(Controllers.StunController)
local TagController = require(Controllers.TagController)
local TaskController = require(Controllers.TaskController)
local TimedStateController = require(Controllers.TimedStateController)
local WardrobeController = require(Controllers.WardrobeController)

-- Combat Classes
local HurtboxClass = require(SClasses.Hitbox.HurtboxClass)

-- Import Types
type StateMachine = typeof(StateMachine.new())
type InputController = typeof(InputController.new())
type MovementController = typeof(MovementController.new())
type CombatController = typeof(CombatController.new())
type StunController = typeof(StunController.new())
type RagdollController = typeof(RagdollController.new())
type CooldownController = typeof(CooldownController.new())
type TagController = typeof(TagController.new())
type CurrencyController = typeof(CurrencyController.new())

-- Modules
local MovementModule = Modules.MovementModule

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)

function BaseCharacterClass.new(params: {
	name: string,
	character: Model,
	controllerData: ControllerData?,
	}): BaseCharacterClass
	
	local self = setmetatable({}, BaseCharacterClass)
	
	-- Initializes character params, such as the character's name, level, etc.
	self.Name = params.name
	--self.Player = params.player
	self.Character = params.character
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.RootPart = self.Character:WaitForChild("HumanoidRootPart")
	
	-- Initializes class modules
	
	-- State Mutator
	self.State = StateMachine.new()
	
	-- Input Reader
	self.Input = InputController.new()
	
	-- State Readers/ Controllers
	self.TimedState = TimedStateController.new(self.State :: StateMachine, self.Input :: InputController)
	self.Cooldown = CooldownController.new(self :: BaseCharacterClass)
	
	-- Frill Stuff
	if params.controllerData ~= {} and params.controllerData ~= nil then
		self.Currency = CurrencyController.new(self :: BaseCharacterClass, params.controllerData.Currency)
		self.Item = ItemController.new(self :: BaseCharacterClass, params.controllerData.Item)
		self.Wardrobe = WardrobeController.new(self :: BaseCharacterClass, params.controllerData.Wardrobe)
		self.Task = TaskController.new(self :: BaseCharacterClass, params.controllerData.Task)
	else
		self.Currency = CurrencyController.new(self :: BaseCharacterClass)
		self.Item = ItemController.new(self :: BaseCharacterClass)
		self.Wardrobe = WardrobeController.new(self :: BaseCharacterClass)
		self.Task = TaskController.new(self :: BaseCharacterClass)
	end
	
	-- Meta Mutators
	self.Powerup = PowerupController.new(self :: BaseCharacterClass)
	
	self.Combat = CombatController.new(self :: BaseCharacterClass)
	self.Tag = TagController.new(self :: BaseCharacterClass)
	self.Movement = MovementController.new(self :: BaseCharacterClass)
	self.Ragdoll = RagdollController.new(self :: BaseCharacterClass)
	self.Stun = StunController.new(self :: BaseCharacterClass)
	
	-- Attributes
	self.Attributes = {
		WalkSpeed = self.Character.Humanoid.WalkSpeed,
		Health = self.Character.Humanoid.Health,
		MaxHealth = self.Character.Humanoid.MaxHealth,
	}
	
	-- Temporary Attributes
	self.Skill = 0.5
	
	-- Combat Initialization
	self.Hurtbox = HurtboxClass.new({
		character = self.Character,
		rootPart = self.RootPart,
		rootCFrame = self.RootPart.CFrame,
		size = Vector3.new(4, 5, 1.5)
	})
	
	-- Registration
	CharacterService:RegisterCharacter(self.Character, self :: BaseCharacterClass)
	
	return self
end

function BaseCharacterClass:GetControllerData()
	return {
		Currency = {COINS = self.Currency.Coins},
		Item = {OWNED_ITEMS = self.Item.OwnedItems},
		Wardrobe = {EQUIPPED = self.Wardrobe.Equipped},
		Task = {DAILY_TASKS = self.Task.DailyTasks}
	}
end

export type BaseCharacterClass = typeof(BaseCharacterClass.new) & {
	
}

type ControllerData = {
	Currency: any,
	Item: any,
	Wardrobe: any,
	Task: any
}

return BaseCharacterClass
