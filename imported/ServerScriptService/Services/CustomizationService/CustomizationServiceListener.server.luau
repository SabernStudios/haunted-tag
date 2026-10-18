-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remotes
local setEquipRemoteFunction = ReplicatedStorage.Shared.Remotes.SetEquipped

-- Custom Services
local CustomizationService = require(script.Parent)

--purchaseRemoteFunction.OnServerEvent:Connect(function(player: Player, category: string, itemName: string)
--	ShopService:OnPurchaseEvent(player, category, itemName)
--end)

setEquipRemoteFunction.OnServerInvoke = function(player: Player, newEquip)
	return CustomizationService:OnSetEquipEvent(player, newEquip)
end
