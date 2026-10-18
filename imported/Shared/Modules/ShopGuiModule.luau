-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Constants
local SHOP_GUI_POSITION_OPEN: UDim2 = UDim2.fromScale(0.28,0.162)
local SHOP_GUI_POSITION_CLOSED: UDim2 = UDim2.fromScale(0.28,1.5)

local SHOP_ITEM_NAME_POSITION_OPEN: UDim2 = UDim2.fromScale(0,0)
local SHOP_ITEM_NAME_SIZE_OPEN: UDim2 = UDim2.fromScale(0.405,0.132)
local SHOP_ITEM_FRAME_POSITION_OPEN: UDim2 = UDim2.fromScale(0,0.131)
local SHOP_ITEM_FRAME_SIZE_OPEN: UDim2 = UDim2.fromScale(0.4,0.868)

local SHOP_ITEM_NAME_POSITION_CLOSED: UDim2 = UDim2.fromScale(0,0)
local SHOP_ITEM_NAME_SIZE_CLOSED: UDim2 = UDim2.fromScale(0, 0.132)
local SHOP_ITEM_FRAME_POSITION_CLOSED: UDim2 = UDim2.fromScale(0,0.131)
local SHOP_ITEM_FRAME_SIZE_CLOSED: UDim2 = UDim2.fromScale(0,0.868)

local SHOP_CATEGORIES_POSITION_OPEN: UDim2 = UDim2.fromScale(0.402,0)
local SHOP_CATEGORIES_SIZE_OPEN: UDim2 = UDim2.fromScale(0.597,0.061)
local SHOP_ITEMLISTFRAME_POSITION_OPEN: UDim2 = UDim2.fromScale(0.402,0.061)
local SHOP_ITEMLISTFRAME_SIZE_OPEN: UDim2 = UDim2.fromScale(0.597,0.939)

local SHOP_CATEGORIES_POSITION_CLOSED: UDim2 = UDim2.fromScale(0,0)
local SHOP_CATEGORIES_SIZE_CLOSED: UDim2 = UDim2.fromScale(1,0.061)
local SHOP_ITEMLISTFRAME_POSITION_CLOSED: UDim2 = UDim2.fromScale(0, 0.061)
local SHOP_ITEMLISTFRAME_SIZE_CLOSED: UDim2 = UDim2.fromScale(1, 0.939)

local SHOP_OPEN_TWEEN_INFO: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SHOP_CLOSE_TWEEN_INFO: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local SHOP_OPEN_CAMERA_TWEEN_INFO: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SHOP_CLOSE_CAMERA_TWEEN_INFO: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local SHOP_SIDE_VIEW_TWEEN_INFO: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local COIN_DECREASE_TWEEN_INFO: TweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local rarityColorTable = {
	["Common"] = Color3.new(0.639216, 0.639216, 0.639216),
	["Rare"] = Color3.new(0.101961, 0.352941, 0.815686),
	["Epic"] = Color3.new(0.372549, 0.0392157, 0.647059),
	["Legendary"] = Color3.new(0.862745, 0.360784, 0),
}

-- Variables
local player = Players.LocalPlayer

local playerGui: PlayerGui = player:WaitForChild("PlayerGui")

local shopGui: ScreenGui = playerGui:WaitForChild("ShopGui")
local shopGuiBackground: Frame = shopGui:WaitForChild("Background")

local shopItemFrame: Frame = shopGuiBackground:WaitForChild("ItemFrame")
local shopItemName: Frame = shopGuiBackground:WaitForChild("ItemName")

local shopCategories: Frame = shopGuiBackground:WaitForChild("Categories")
local itemListFrame: Frame = shopGuiBackground:WaitForChild("ItemListFrame")
local items: ScrollingFrame = itemListFrame:WaitForChild("Items")

local items: ScrollingFrame = itemListFrame:WaitForChild("Items")

local currencyGui: ScreenGui = playerGui:WaitForChild("CurrencyGui")

local coinFrame: Frame = currencyGui:WaitForChild("CoinFrame")
local coinDisplayText: Frame = coinFrame:WaitForChild("Display")

-- Shop Assets
local shopAssets = ReplicatedStorage.Assets.Shop

-- UI Presets
local UIPresets = ReplicatedStorage.Assets.UIPresets

local itemFrame = UIPresets.Shop.ShopItemFrame

local ShopGuiModule = {}

-- Custom Services
local GuiButtonService = require(ReplicatedStorage.Shared.Services.GuiButtonService)

function ShopGuiModule.MakeShopBackgroundInvisible()
	shopGuiBackground.Position = SHOP_GUI_POSITION_CLOSED
end

function ShopGuiModule.ForceCloseSideView()
	shopItemName.Position = SHOP_ITEM_NAME_POSITION_CLOSED
	shopItemName.Size = SHOP_ITEM_NAME_SIZE_CLOSED
	shopItemFrame.Position = SHOP_ITEM_FRAME_POSITION_CLOSED
	shopItemFrame.Size = SHOP_ITEM_FRAME_SIZE_CLOSED
	shopCategories.Position = SHOP_CATEGORIES_POSITION_CLOSED
	shopCategories.Size = SHOP_CATEGORIES_SIZE_CLOSED
	itemListFrame.Position = SHOP_ITEMLISTFRAME_POSITION_CLOSED
	itemListFrame.Size = SHOP_ITEMLISTFRAME_SIZE_CLOSED
	
	shopItemFrame.Description.UIStroke.Thickness = 0
	shopItemFrame.Purchase.UIStroke.Thickness = 0
	shopItemFrame.Owned.UIStroke.Thickness = 0
end

function ShopGuiModule.SetShopGuiVisible()
	shopGui.Enabled = true
end

function ShopGuiModule.OpenShopGui()
	local tween = TweenService:Create(shopGuiBackground, SHOP_OPEN_TWEEN_INFO, {Position = SHOP_GUI_POSITION_OPEN})
	local cameraTween = TweenService:Create(game.Lighting.DepthOfField, SHOP_OPEN_CAMERA_TWEEN_INFO, {FarIntensity = 1})
	tween:Play()
	cameraTween:Play()
end

function ShopGuiModule.CloseShopGui()
	local tween = TweenService:Create(shopGuiBackground, SHOP_CLOSE_TWEEN_INFO, {Position = SHOP_GUI_POSITION_CLOSED})
	local cameraTween = TweenService:Create(game.Lighting.DepthOfField, SHOP_CLOSE_CAMERA_TWEEN_INFO, {FarIntensity = 0})
	tween:Play()
	cameraTween:Play()
end

function ShopGuiModule.OpenSideView()
	local tweenItemName = TweenService:Create(shopItemName, SHOP_SIDE_VIEW_TWEEN_INFO, {Position = SHOP_ITEM_NAME_POSITION_OPEN, Size = SHOP_ITEM_NAME_SIZE_OPEN})
	local tweenItemFrame = TweenService:Create(shopItemFrame, SHOP_SIDE_VIEW_TWEEN_INFO, {Position = SHOP_ITEM_FRAME_POSITION_OPEN, Size = SHOP_ITEM_FRAME_SIZE_OPEN})
	local tweenCategories = TweenService:Create(shopCategories, SHOP_SIDE_VIEW_TWEEN_INFO, {Position = SHOP_CATEGORIES_POSITION_OPEN, Size = SHOP_CATEGORIES_SIZE_OPEN})
	local tweenItemListFrame = TweenService:Create(itemListFrame, SHOP_SIDE_VIEW_TWEEN_INFO, {Position = SHOP_ITEMLISTFRAME_POSITION_OPEN, Size = SHOP_ITEMLISTFRAME_SIZE_OPEN})
	
	shopItemFrame.Description.UIStroke.Thickness = 6
	shopItemFrame.Purchase.UIStroke.Thickness = 6
	shopItemFrame.Owned.UIStroke.Thickness = 6
	
	tweenItemName:Play()
	tweenItemFrame:Play()
	tweenCategories:Play()
	tweenItemListFrame:Play()
end

function ShopGuiModule.CloseSideView()
	local tweenItemName = TweenService:Create(shopItemName, SHOP_SIDE_VIEW_TWEEN_INFO, {Position = SHOP_ITEM_NAME_POSITION_CLOSED, Size = SHOP_ITEM_NAME_SIZE_CLOSED})
	local tweenItemFrame = TweenService:Create(shopItemFrame, SHOP_SIDE_VIEW_TWEEN_INFO, {Position = SHOP_ITEM_FRAME_POSITION_CLOSED, Size = SHOP_ITEM_FRAME_SIZE_CLOSED})
	local tweenCategories = TweenService:Create(shopCategories, SHOP_SIDE_VIEW_TWEEN_INFO, {Position = SHOP_CATEGORIES_POSITION_CLOSED, Size = SHOP_CATEGORIES_SIZE_CLOSED})
	local tweenItemListFrame = TweenService:Create(itemListFrame, SHOP_SIDE_VIEW_TWEEN_INFO, {Position = SHOP_ITEMLISTFRAME_POSITION_CLOSED, Size = SHOP_ITEMLISTFRAME_SIZE_CLOSED})
	
	shopItemFrame.Description.UIStroke.Thickness = 0
	shopItemFrame.Purchase.UIStroke.Thickness = 0
	shopItemFrame.Owned.UIStroke.Thickness = 0

	tweenItemName:Play()
	tweenItemFrame:Play()
	tweenCategories:Play()
	tweenItemListFrame:Play()
end

function ShopGuiModule.UpdateSideView(name: string, price: number, description: string, owned: boolean, fullArt: string)
	shopItemName.Tag.Text = name
	
	shopItemFrame.Purchase.Price.Text = price
	
	shopItemFrame.Description.Text = description
	
	if owned then
		shopItemFrame.Purchase.Visible = false
		shopItemFrame.Owned.Visible = true
	else
		shopItemFrame.Purchase.Visible = true
		shopItemFrame.Owned.Visible = false
		
		ShopGuiModule.RevertPurchaseButton()
	end
	
	shopItemFrame.ItemImage.Image = fullArt
end

function ShopGuiModule.ResetItemList()
	for _, value in items:GetChildren() do
		if value:IsA("Frame") then
			value:Destroy()
		end
	end
end

function ShopGuiModule.AddItem(name: string, price: number, rarity: string, layout: number?, thumbnail: string?): Frame
	local shopItemFrameClone: Frame = itemFrame:Clone()
	
	shopItemFrameClone.Name = name
	shopItemFrameClone.ShopItem.BottomFrame.Tag.Text = name
	
	shopItemFrameClone.ShopItem.BottomFrame.Price.Text = price
	
	shopItemFrameClone.ShopItem.UIStroke.Color = rarityColorTable[rarity]
	shopItemFrameClone.ShopItem.BottomFrame.BackgroundColor3 = rarityColorTable[rarity]
	
	shopItemFrameClone.LayoutOrder = layout or 0
	
	if thumbnail then
		shopItemFrameClone.ShopItem.Thumbnail.Image = thumbnail
		shopItemFrameClone.ShopItem.Thumbnail.Visible = true
	else
		for _, descendant in shopAssets:GetDescendants() do
			if descendant.Name == name and descendant:IsA("Model") then
				local descendantClone = descendant:Clone()
				descendantClone.Parent = shopItemFrameClone.ShopItem.ThumbnailView
				local descendantCloneCFrame = descendantClone.Head.CFrame
				
				local camera = Instance.new("Camera")
				camera.CFrame = CFrame.lookAt(descendantCloneCFrame.Position + descendantCloneCFrame.LookVector * 2.5 + descendantCloneCFrame.RightVector * 1.5, descendantCloneCFrame.Position)
				camera.Parent = shopItemFrameClone.ShopItem.ThumbnailView
				
				shopItemFrameClone.ShopItem.ThumbnailView.CurrentCamera = camera
				
				shopItemFrameClone.ShopItem.ThumbnailView.Visible = true
			end
		end
	end
	
	shopItemFrameClone.Parent = items
	
	GuiButtonService:RegisterButton(shopItemFrameClone.ShopItem, 1.025, 0.9)
	
	return shopItemFrameClone
end

function ShopGuiModule.UpdateCoins(amount: number)
	coinDisplayText.Text = amount
end

function ShopGuiModule.DecreaseCoins(amount: number)
	local intValue = Instance.new("IntValue")
	
	intValue.Changed:Connect(function()
		coinDisplayText.Text = intValue.Value
	end)
	
	local tween = TweenService:Create(intValue, COIN_DECREASE_TWEEN_INFO, {Value = tonumber(coinDisplayText.Text) - amount})
	tween:Play()
	
	task.spawn(function()
		tween.Completed:Wait()
		intValue:Destroy()
	end)
end

function ShopGuiModule.ShowPurchaseButtonPurchasing()
	shopItemFrame.Purchase.Text = "Purchasing..."
	shopItemFrame.Purchase.Price.Visible = false
	shopItemFrame.Purchase.PurchaseText.Visible = false
	shopItemFrame.Purchase.Icon.Visible = false
end

function ShopGuiModule.RevertPurchaseButton()
	shopItemFrame.Purchase.Text = ""
	shopItemFrame.Purchase.Price.Visible = true
	shopItemFrame.Purchase.PurchaseText.Visible = true
	shopItemFrame.Purchase.Icon.Visible = true
end

function ShopGuiModule.UpdatePurchaseButton()
	shopItemFrame.Purchase.Visible = false
	shopItemFrame.Owned.Visible = true
end

function ShopGuiModule.UpdateOwnedButton()
	shopItemFrame.Purchase.Visible = true
	shopItemFrame.Owned.Visible = false
end

function ShopGuiModule.GetCurrentItemName()
	return shopItemName.Tag.Text
end

function ShopGuiModule.GetPurchaseButton()
	return shopItemFrame.Purchase
end

function ShopGuiModule.GetRarityTable()
	return rarityColorTable
end

return ShopGuiModule
