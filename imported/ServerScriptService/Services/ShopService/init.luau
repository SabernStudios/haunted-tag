-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Definitions
local CharacterDefinitions = require(ReplicatedStorage.Shared.Definitions.Shop.CharacterDefinitions)

-- Variables
local lastPurchaseRequest = {
	
}

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)

local ShopService = {}

function ShopService.OnPurchaseEvent(self: ShopService, player: Player, category: string, itemName: string)
	if not lastPurchaseRequest[player] then
		lastPurchaseRequest[player] = os.time()
	else
		if os.time() - lastPurchaseRequest[player] < 0.25 then
			return category, itemName, nil
		end
	end
	
	lastPurchaseRequest[player] = os.time()
	
	local character = CharacterService:GetCharacterFromPlayer(player)
	
	local currencyController = character.Currency
	local itemController = character.Item
	
	local ownedItemsTable = itemController.OwnedItems[category]
	
	if table.find(ownedItemsTable, itemName) then
		return category, itemName, nil
	end
	
	if category == "Characters" then
		if not CharacterDefinitions[itemName] then
			warn("SHOP_SERVICE: No character found in CharacterDefinitions")
			return
		end
		
		local definition = CharacterDefinitions[itemName]
		
		if currencyController.Coins >= definition.Price[1] then
			currencyController:TryAddCoins(-definition.Price[1])
			table.insert(ownedItemsTable, itemName)
			
			return category, itemName, "Success"
		else
			return category, itemName, nil
		end
	else
		warn("SHOP_SERVICE: Invalid category")
	end
end

type ShopService = typeof(ShopService) & {
	
}

return ShopService
