-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Definitions
local CharacterDefinitions = require(ReplicatedStorage.Shared.Definitions.Shop.CharacterDefinitions)

-- Variables
local lastSetEquipRequest = {

}

-- Assets
local shopAssets = ReplicatedStorage.Assets.Shop

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)

local CustomizationService = {}

function CustomizationService.OnSetEquipEvent(self: CustomizationService, player: Player, newEquip)
	if not lastSetEquipRequest[player] then
		lastSetEquipRequest[player] = os.time()
	else
		if os.time() - lastSetEquipRequest[player] < 0.25 then
			return
		end
	end
	
	lastSetEquipRequest[player] = os.time()
	
	local character = CharacterService:GetCharacterFromPlayer(player)

	local itemController = character.Item
	local wardrobeController = character.Wardrobe
	
	local equipped = wardrobeController.Equipped

	if not newEquip then
		warn("[ITEM_CONTROLLER]: No equip found.")
		return false
	end

	if not newEquip.Character or not newEquip.Skin or not newEquip.Accessories or not newEquip.TagFX or not newEquip.Emotes then
		warn("[ITEM_CONTROLLER]: Invalid equip found.")
		return false
	end

	-- Checks for each category
	if not table.find(itemController.OwnedItems.Characters, newEquip.Character) then
		warn("[ITEM_CONTROLLER]: Invalid character found.")
		return false
	end

	-- TODO: Add skin logic

	for _, accessory in newEquip.Accessories do
		if not table.find(itemController.OwnedItems.Accessories, accessory) then
			warn("[ITEM_CONTROLLER]: Invalid accessory found.")
			return false
		end
	end

	if not table.find(itemController.OwnedItems.TagFX, newEquip.TagFX) then
		warn("[ITEM_CONTROLLER]: Invalid tagFX found.")
		return false
	end

	for _, emote in newEquip.Emotes do
		if not table.find(itemController.OwnedItems.Emotes, emote) then
			warn("[ITEM_CONTROLLER]: Invalid emote found.")
			return false
		end
	end

	equipped = newEquip
	
	local savedCharPosition = player.Character.PrimaryPart.Position
	
	local newCharacter = self:CreateCharacterFromEquipped(equipped)
	
	player.Character = newCharacter
	newCharacter.Parent = workspace
	newCharacter.Name = player.Name
	player.Character:MoveTo(savedCharPosition)

	return true
end

function CustomizationService.CreateCharacterFromEquipped(self: CustomizationService, newEquipped: {}?)
	local newDummy
	local newerEquipped = newEquipped

	if newerEquipped.Skin == "" then
		for _, asset in shopAssets:GetDescendants() do
			if asset.Name == newerEquipped.Character and asset:IsA("Model") then
				newDummy = asset:Clone()
			end
		end
	else

	end

	return newDummy
end

type CustomizationService = typeof(CustomizationService) & {
	
}

return CustomizationService
