local CharacterAction = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local CharacterService = require(SSS.Services.CharacterService)

local Packages = ReplicatedStorage.Packages
local Modules = ReplicatedStorage.Shared.Modules

local ParameterUtils = require(Packages.ParameterUtils)

local MovementModule = Modules.MovementModule

function CharacterAction.onAction(player: Player, actionName: string, inputState: Enum.UserInputState, inputObject: InputObject, clientPayload: {})
	local characterInstance = player.Character or player.CharacterAdded:Wait()
	local character = CharacterService.Characters[characterInstance]
	if not character then return end
	
	if actionName == "Dash" then
		character.Movement:TryDash(clientPayload)
	elseif actionName == "W" or actionName == "A" or actionName == "S" or actionName == "D" then
		
	elseif actionName == "Sprint" then
		character.Movement:TrySprint(clientPayload)
	elseif actionName == "Slide" then
		character.Movement:TrySlide(clientPayload)
	elseif actionName == "Powerup" then
		character.Powerup:TryActivatePowerup()
	elseif actionName == "Tagging" then
		character.Tag:TryTag(clientPayload)
	elseif actionName == "Attack" then
		character.Combat:TryAttack("Attack")
	elseif actionName == "Block" then
		character.Combat:TryBlock("Block", clientPayload)
	end
end

function CharacterAction.onUnaction(player: Player, actionName: string, inputState: Enum.UserInputState, inputObject: InputObject, clientPayload: {})
	local characterInstance = player.Character or player.CharacterAdded:Wait()
	local character = CharacterService.Characters[characterInstance]
	if not character then return end

	if actionName == "Dash" then
		
	elseif actionName == "W" or actionName == "A" or actionName == "S" or actionName == "D" then
		
	elseif actionName == "Sprint" then
		character.Movement:TryStopSprint(clientPayload)
	elseif actionName == "Block" then
		character.Combat:TryStopBlock(clientPayload)
	end
end

return CharacterAction
