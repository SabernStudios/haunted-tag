-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remotes
local purchaseRemoteFunction = ReplicatedStorage.Shared.Remotes.Purchase

-- Custom Services
local ShopService = require(script.Parent)

--purchaseRemoteFunction.OnServerEvent:Connect(function(player: Player, category: string, itemName: string)
--	ShopService:OnPurchaseEvent(player, category, itemName)
--end)

purchaseRemoteFunction.OnServerInvoke = function(player: Player, category: string, itemName: string)
	return ShopService:OnPurchaseEvent(player, category, itemName)
end
