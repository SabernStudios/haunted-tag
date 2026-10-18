local CharacterService = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

CharacterService.Characters = {}

function CharacterService.RegisterCharacter(self: CharacterService, character: Model, baseCharacter: Object)
	CharacterService.Characters[character] = baseCharacter
end

function CharacterService.UnregisterCharacter(self: CharacterService, character: Model)
	CharacterService.Characters[character] = nil
end

function CharacterService.GetCharacterFromInstance(self: CharacterService, instance: Instance)
	local character = instance:FindFirstAncestorOfClass("Model")
	
	if character and character:FindFirstChild("Humanoid") then
		return CharacterService.Characters[Players:GetPlayerFromCharacter(character)]
	end
end

function CharacterService.GetCharacterFromCharacter(self: CharacterService, character: Model)
	return CharacterService.Characters[character]
end

function CharacterService.GetCharacterFromPlayer(self: CharacterService, player: Player)
	local character = player.Character or player.CharacterAdded:Wait()
	return CharacterService.Characters[character]
end

type CharacterService = typeof(CharacterService) & {
	
}

return CharacterService
