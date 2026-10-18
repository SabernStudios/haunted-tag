-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Import Types
local types = ReplicatedStorage.Shared.Types
local CombatTypes = require(types.Combat.CombatTypes)

type AttackPayload = CombatTypes.AttackPayload
type ComboPayload = CombatTypes.ComboPayload

type ClientAttackPayload = CombatTypes.ClientAttackPayload

-- Definitions
local AttackDefinition = require(ReplicatedStorage.Shared.Definitions.Actions.Combat.AttackDefinition)

-- Classes
local Classes = SSS.Classes
local HitboxClass = require(Classes.Hitbox.HitboxClass)

-- Remotes
local Remotes = ReplicatedStorage.Shared.Remotes
local characterAction = Remotes.CharacterAction

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)

return function(payload: AttackPayload)
	local stateName = AttackDefinition.ReturnStateName()
	
	local personalIgnoreList = {}
	table.insert(personalIgnoreList, payload.Character)
	
	local rootPart = payload.Character:FindFirstChild("HumanoidRootPart")
	
	task.delay(AttackDefinition.ReturnHitboxStart(), function()
		local hitbox = HitboxClass.new({
			ignoreList = {payload.Character},
			mode = "Attached",
			offset = CFrame.new(0, 0, 0),
			parent = payload.Character["Right Arm"],
			size = Vector3.new(1.5,3,1.5)
		})
		
		hitbox:Activate(AttackDefinition.ReturnHitboxDuration() :: number)
		
		hitbox.OnHit:Connect(function(target: Model)
			if table.find(personalIgnoreList, target) then
				return
			end
			
			table.insert(personalIgnoreList, target)
			
			local damage = AttackDefinition.ReturnDamage()
			local knockback = AttackDefinition.ReturnKnockback()
			local stunTime = AttackDefinition.ReturnStunTime()
			
			if payload.Maxed then
				damage = AttackDefinition.ReturnDamageMaxCombo()
				knockback = AttackDefinition.ReturnKnockbackMaxCombo()
				stunTime = AttackDefinition.ReturnStunTimeMaxCombo()
			end
			
			payload.Event:Fire(target, damage, rootPart.CFrame.LookVector, knockback, stunTime, payload.Maxed, AttackDefinition.ReturnUnblockable()) -- TODO: get from attackDef and knockback from maxCombo
		end)
	end)
end
