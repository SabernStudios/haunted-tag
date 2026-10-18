-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Remotes
local ItemEvent = ReplicatedStorage.Shared.Remotes.ItemEvent

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)

local ItemController = {}

function ItemController.new(baseCharacter, data: {}?): ItemController
	local self = setmetatable({}, ItemController)
	
	self.Character = baseCharacter
	
	self.OwnedItems = {
		["Characters"] = {
			"Noobert"
		},
		["Accessories"] = {},
		["TagFX"] = {"Standard"},
		["Emotes"] = {},
	}
	
	if data then
		self.OwnedItems = data.OWNED_ITEMS
	end
	
	-- After having all data loaded, fire the client to update the owned character UI
	ItemEvent:FireClient(Players:GetPlayerFromCharacter(baseCharacter.Character), "UpdateOwned", {OWNED_ITEMS = self.OwnedItems})
	
	return self
end

type ItemController = typeof(ItemController) & {
	
}

return ItemController
