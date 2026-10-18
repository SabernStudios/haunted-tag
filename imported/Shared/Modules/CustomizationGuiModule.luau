-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local player: Player = Players.LocalPlayer

local playerGui: PlayerGui = player:WaitForChild("PlayerGui")

local customizationGui: ScreenGui = playerGui:WaitForChild("CustomizationGui")

local inventoryFrame: Frame = customizationGui:WaitForChild("InventoryFrame")
local items: ScrollingFrame = inventoryFrame:WaitForChild("Items")

-- Assets
local shopAssets = ReplicatedStorage.Assets.Shop

local WardrobeItemFrame = ReplicatedStorage.Assets.UIPresets.Shop.WardrobeItemFrame

-- Modules
local ShopGuiModule = require(ReplicatedStorage.Shared.Modules.ShopGuiModule)

-- Custom Services
local GuiButtonService = require(ReplicatedStorage.Shared.Services.GuiButtonService)

local CustomizationGuiModule = {}

function CustomizationGuiModule.OpenCustomizationGui()
	customizationGui.Enabled = true
end

function CustomizationGuiModule.CloseCustomizationGui()
	customizationGui.Enabled = false
end

function CustomizationGuiModule.ResetItemList()
	for _, value in items:GetChildren() do
		if value:IsA("Frame") then
			value:Destroy()
		end
	end
end

function CustomizationGuiModule.AddItem(name: string, rarity: string, equipped: boolean, layout: string?, thumbnail: string?)
	local wardrobeItemFrameClone = WardrobeItemFrame:Clone()
	
	wardrobeItemFrameClone.Name = name
	wardrobeItemFrameClone.WardrobeItem.BottomFrame.Tag.Text = name
	
	local rarityColorTable = ShopGuiModule.GetRarityTable()

	wardrobeItemFrameClone.WardrobeItem.UIStroke.Color = rarityColorTable[rarity]
	wardrobeItemFrameClone.WardrobeItem.BottomFrame.BackgroundColor3 = rarityColorTable[rarity]

	wardrobeItemFrameClone.LayoutOrder = layout or 0
	
	if equipped then
		wardrobeItemFrameClone.WardrobeItem.EquipFrame.Equipped.Visible = true
		wardrobeItemFrameClone.LayoutOrder = 0
	end
	
	if thumbnail then
		wardrobeItemFrameClone.WardrobeItem.Thumbnail.Image = thumbnail
		wardrobeItemFrameClone.WardrobeItem.Thumbnail.Visible = true
	else
		for _, descendant in shopAssets:GetDescendants() do
			if descendant.Name == name and descendant:IsA("Model") then
				local descendantClone = descendant:Clone()
				descendantClone.Parent = wardrobeItemFrameClone.WardrobeItem.ThumbnailView
				local descendantCloneCFrame = descendantClone.Head.CFrame

				local camera = Instance.new("Camera")
				camera.CFrame = CFrame.lookAt(descendantCloneCFrame.Position + descendantCloneCFrame.LookVector * 2.5 + descendantCloneCFrame.RightVector * 1.5, descendantCloneCFrame.Position)
				camera.Parent = wardrobeItemFrameClone.WardrobeItem.ThumbnailView

				wardrobeItemFrameClone.WardrobeItem.ThumbnailView.CurrentCamera = camera

				wardrobeItemFrameClone.WardrobeItem.ThumbnailView.Visible = true
			end
		end
	end

	wardrobeItemFrameClone.Parent = items

	GuiButtonService:RegisterButton(wardrobeItemFrameClone.WardrobeItem, 1.025, 0.9)

	return wardrobeItemFrameClone
end

return CustomizationGuiModule
