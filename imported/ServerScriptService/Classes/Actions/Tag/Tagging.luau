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
local TagDefinition = require(ReplicatedStorage.Shared.Definitions.Actions.Tag.TagDefinition)

-- Classes
local Classes = SSS.Classes
local HitboxClass = require(Classes.Hitbox.HitboxClass)

-- Remotes
local Remotes = ReplicatedStorage.Shared.Remotes
local characterAction = Remotes.CharacterAction

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)

return function(payload: AttackPayload)
	local stateName = TagDefinition.ReturnStateName()

	local personalIgnoreList = {}
	table.insert(personalIgnoreList, payload.Character)

	local rootPart = payload.Character:FindFirstChild("HumanoidRootPart")

	task.delay(TagDefinition.ReturnHitboxStart(), function()
		local hitbox = HitboxClass.new({
			ignoreList = {payload.Character},
			mode = "Attached",
			offset = CFrame.new(0, 0, 0),
			parent = payload.Character["Right Arm"],
			size = Vector3.new(1.5,3,1.5)*6,
		})

		hitbox:Activate(TagDefinition.ReturnHitboxDuration() :: number)

		hitbox.OnHit:Connect(function(target: Model)
			if table.find(personalIgnoreList, target) then
				return
			end

			table.insert(personalIgnoreList, target)

			local stunTime = TagDefinition.ReturnStunTime()

			payload.Event:Fire(target, stunTime) -- TODO: get from attackDef and knockback from maxCombo
		end)
	end)
end