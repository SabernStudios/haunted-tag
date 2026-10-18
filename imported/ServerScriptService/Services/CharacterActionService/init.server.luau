local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local CharacterService = require(SSS.Services.CharacterService)

local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")

-- Remote Events
local OnCharacterAction = Remotes:WaitForChild("CharacterAction")

local CharacterAction = require(script.CharacterAction)

OnCharacterAction.OnServerEvent:Connect(function(player: Player, actionName: string, inputState: Enum.UserInputState, inputObject: InputObject, clientPayload: {})
	if inputState == Enum.UserInputState.Begin then
		CharacterAction.onAction(player, actionName, inputState, inputObject, clientPayload)
	elseif inputState == Enum.UserInputState.End then
		CharacterAction.onUnaction(player, actionName, inputState, inputObject, clientPayload)
	end
end)
