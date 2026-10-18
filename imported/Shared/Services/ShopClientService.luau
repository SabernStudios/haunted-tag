-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local shopOpen = false
local sideViewOpen = false
local category = "Characters"

local ownedItems = {
	["Characters"] = {},
	["Accessories"] = {},
	["TagFX"] = {"Standard"},
	["Emotes"] = {},
}

-- Definitions
local CharacterDefinitions = require(ReplicatedStorage.Shared.Definitions.Shop.CharacterDefinitions)

-- Remotes
local purchaseRemoteFunction = ReplicatedStorage.Shared.Remotes.Purchase

-- Modules
local ShopGuiModule = require(ReplicatedStorage.Shared.Modules.ShopGuiModule)

local ShopClientService = {}

function ShopClientService.Init(self: ShopClientService)
	ShopGuiModule.MakeShopBackgroundInvisible()
	ShopGuiModule.SetShopGuiVisible()
	ShopGuiModule.ForceCloseSideView()
	
	local purchaseButton: TextButton = ShopGuiModule.GetPurchaseButton()
	
	if purchaseButton then
		purchaseButton.MouseButton1Down:Connect(function()
			ShopGuiModule.ShowPurchaseButtonPurchasing()
			
			local currentItem = ShopGuiModule.GetCurrentItemName()
			
			local category, itemName, success = purchaseRemoteFunction:InvokeServer(category, currentItem)
			
			task.wait(0.5)
			
			if success then
				ShopGuiModule.UpdatePurchaseButton()
				
				table.insert(ownedItems[category], itemName)
				
				local itemPrice
				
				if category == "Characters" then
					itemPrice = CharacterDefinitions[itemName].Price[1]
				end
				
				if itemPrice then
					ShopGuiModule.DecreaseCoins(itemPrice)
				end
				
				local buySuccessClone = ReplicatedStorage.Assets.SoundEffects.Buy:Clone()
				buySuccessClone.Parent = ReplicatedStorage
				
				buySuccessClone:Play()
				task.spawn(function()
					buySuccessClone.Ended:Wait()
					buySuccessClone:Destroy()
				end)
			else
				ShopGuiModule.RevertPurchaseButton()
				
				local buyFailClone = ReplicatedStorage.Assets.SoundEffects.BuyFailed:Clone()
				buyFailClone.Parent = ReplicatedStorage
				
				buyFailClone:Play()
				task.spawn(function()
					buyFailClone.Ended:Wait()
					buyFailClone:Destroy()
				end)
			end
		end)
	end
	
	self:AddItems()
end

function ShopClientService.OnItemEvent(self: ShopClientService, event: string, payload: {})
	if event == "UpdateOwned" then
		ownedItems = payload.OWNED_ITEMS
	elseif event == "UpdateCurrency" then
		ShopGuiModule.UpdateCoins(payload.COINS)
	end
end

function ShopClientService.UpdateShop(self: ShopClientService)
	
end

function ShopClientService.AddItems(self: ShopClientService)
	ShopGuiModule.ResetItemList()
	
	local itemList = {}
	
	local commons = {}
	local rares = {}
	local epics = {}
	local legendaries = {}
	
	if category == "Characters" then
		for name, value in CharacterDefinitions do
			if value.Rarity == "Common" then
				table.insert(commons, {name, value})
			elseif value.Rarity == "Rare" then
				table.insert(rares, {name, value})
			elseif value.Rarity == "Epic" then
				table.insert(epics, {name, value})
			elseif value.Rarity == "Legendary" then
				table.insert(legendaries, {name, value})
			end
		end
		
		local layout = 0
		
		local buttons = {}
		
		for _, value in commons do
			local button = ShopGuiModule.AddItem(value[1], value[2].Price[1], value[2].Rarity, layout)
			table.insert(buttons, button)
			layout += 1
		end
		for _, value in rares do
			local button = ShopGuiModule.AddItem(value[1], value[2].Price[1], value[2].Rarity, layout)
			table.insert(buttons, button)
			layout += 1
		end
		for _, value in epics do
			local button = ShopGuiModule.AddItem(value[1], value[2].Price[1], value[2].Rarity, layout)
			table.insert(buttons, button)
			layout += 1
		end
		for _, value in legendaries do
			local button = ShopGuiModule.AddItem(value[1], value[2].Price[1], value[2].Rarity, layout)
			table.insert(buttons, button)
			layout += 1
		end
		
		for _, button in buttons do
			button.ShopItem.MouseButton1Click:Connect(function()
				if not sideViewOpen then
					local definition = CharacterDefinitions[button.Name]
					ShopGuiModule.OpenSideView()
					ShopGuiModule.UpdateSideView(button.Name, definition.Price[1], definition.Description, table.find(ownedItems[category], button.Name), definition.FullArt)
					sideViewOpen = true
				else
					local definition = CharacterDefinitions[button.Name]
					ShopGuiModule.UpdateSideView(button.Name, definition.Price[1], definition.Description, table.find(ownedItems[category], button.Name), definition.FullArt)
				end
			end)
		end
	end
end

function ShopClientService.EquipItem(self: ShopClientService, category: string, itemName: string)
	if ownedItems[category] then
		if table.find(ownedItems[category], itemName) then
			return true
		end
	end
	
	return false
end

function ShopClientService.TryChangeShopVisibility(self: ShopClientService)
	if not shopOpen then
		self:OpenShop()
		shopOpen = true
	elseif shopOpen then
		self:CloseShop()
		shopOpen = false
	end
end

function ShopClientService.OpenShop(self: ShopClientService)
	ShopGuiModule.OpenShopGui()
end

function ShopClientService.CloseShop(self: ShopClientService)
	ShopGuiModule.CloseShopGui()
end

function ShopClientService.GetOwnedItems(self: ShopClientService)
	return ownedItems
end

type ShopClientService = typeof(ShopClientService) & {
	
}

return ShopClientService
