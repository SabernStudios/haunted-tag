-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Remotes
local ItemEvent = ReplicatedStorage.Shared.Remotes.ItemEvent

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)

local WardrobeController = {}
WardrobeController.__index = WardrobeController

function WardrobeController.new(baseCharacter, data: {}?): WardrobeController
	local self = setmetatable({}, WardrobeController)
	
	self.Equipped = {
		Character = "Noobert",
		Skin = "",
		Accessories = {},
		TagFX = "Standard",
		Emotes = {},
	}
	
	if data then
		self.Equipped = data.EQUIPPED
	else
		-- After having all data loaded, fire the client to update the owned character UI
		ItemEvent:FireClient(Players:GetPlayerFromCharacter(baseCharacter.Character), "UpdateWorn", {EQUIPPED = self.Equipped})
	end
	
	return self
end

type WardrobeController = typeof(WardrobeController) & {
	
}

return WardrobeController
