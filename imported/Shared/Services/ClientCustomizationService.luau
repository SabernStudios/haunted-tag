-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

-- Constants
local TRANSITION_WAIT_TIME: number = 0.5

-- Variables
local player = Players.LocalPlayer

local camera = workspace.CurrentCamera

local wardrobe = workspace.Wardrobe

local dummy

local rigFolder = wardrobe.Rig

local category = "Characters"

local equipped = {
	Character = "Noobert",
	Skin = "",
	Accessories = {},
	TagFX = "Standard",
	Emotes = {},
}

local inRound = false

-- PlayerGui
local playerGui = player:WaitForChild("PlayerGui")

local customizationGui = playerGui:WaitForChild("CustomizationGui")

local dragDetectionFrame = customizationGui:WaitForChild("DragDetectionFrame")

local oldEquipped = {}

-- Assets
local shopAssets = ReplicatedStorage.Assets.Shop

local characters = shopAssets.Characters

local customizationOpen: boolean = false

-- Definitions
local CharacterDefinitions = require(ReplicatedStorage.Shared.Definitions.Shop.CharacterDefinitions)

-- Remotes
local SetEquipped = ReplicatedStorage.Shared.Remotes.SetEquipped

-- Modules
local GuiModule = require(ReplicatedStorage.Shared.Modules.GuiModule)
local CustomizationGuiModule = require(ReplicatedStorage.Shared.Modules.CustomizationGuiModule)

-- Custom Services
local ShopClientService = require(ReplicatedStorage.Shared.Services.ShopClientService)

local ClientCustomizationService = {}

function ClientCustomizationService.OnItemEvent(self: ClientCustomizationService, event: string, payload: {})
	if event == "UpdateWorn" then
		self:SetEquipped(payload.EQUIPPED)
	end
end

function ClientCustomizationService.UpdateCharacterCustomization(self: ClientCustomizationService)
	if customizationOpen == false then
		self:OpenCharacterCustomization()
	else
		self:CloseCharacterCustomization()
	end
	
	customizationOpen = not customizationOpen
end

function ClientCustomizationService.OpenCharacterCustomization(self: ClientCustomizationService)
	if inRound then
		return
	end
	
	oldEquipped = equipped
	
	self:TeleportToCharacterCustomization()
	
	self:UpdateDummy()
	
	self:LoadOwnedItems()
	CustomizationGuiModule.OpenCustomizationGui()
end

function ClientCustomizationService.CloseCharacterCustomization(self: ClientCustomizationService)
	self:RevertPlayerCamera()
	
	local success = SetEquipped:InvokeServer(equipped)
	
	if success then
		workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
		CustomizationGuiModule.CloseCustomizationGui()
	end
end

function ClientCustomizationService.TeleportToCharacterCustomization(self: ClientCustomizationService)
	camera.CameraType = Enum.CameraType.Scriptable
	GuiModule.Transition(0.5)
	camera.CFrame = wardrobe.WardrobeCameraPart.CFrame
end

function ClientCustomizationService.RevertPlayerCamera(self: ClientCustomizationService)
	GuiModule.Transition(0.5)
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = player.Character.Humanoid
end

function ClientCustomizationService.LoadOwnedItems(self: ClientCustomizationService)
	CustomizationGuiModule.ResetItemList()
	
	local itemList = {}

	local commons = {}
	local rares = {}
	local epics = {}
	local legendaries = {}
	
	local ownedItems = ShopClientService:GetOwnedItems()

	if category == "Characters" then
		local ownedCharacters = ownedItems.Characters
		
		for _, characterName in ownedCharacters do
			local definition = CharacterDefinitions[characterName]
			
			if definition.Rarity == "Common" then
				table.insert(commons, {characterName, definition})
			elseif definition.Rarity == "Rare" then
				table.insert(rares, {characterName, definition})
			elseif definition.Rarity == "Epic" then
				table.insert(epics, {characterName, definition})
			elseif definition.Rarity == "Legendary" then
				table.insert(legendaries, {characterName, definition})
			end
		end

		local layout = 1

		local buttons = {}

		for _, value in commons do
			local button = CustomizationGuiModule.AddItem(value[1], value[2].Rarity, value[1] == equipped.Character, layout)
			table.insert(buttons, button)
			layout += 1
		end
		for _, value in rares do
			local button = CustomizationGuiModule.AddItem(value[1], value[2].Rarity, value[1] == equipped.Character, layout)
			table.insert(buttons, button)
			layout += 1
		end
		for _, value in epics do
			local button = CustomizationGuiModule.AddItem(value[1], value[2].Rarity, value[1] == equipped.Character, layout)
			table.insert(buttons, button)
			layout += 1
		end
		for _, value in legendaries do
			local button = CustomizationGuiModule.AddItem(value[1], value[2].Rarity, value[1] == equipped.Character, layout)
			table.insert(buttons, button)
			layout += 1
		end

		for _, button in buttons do
			button.WardrobeItem.MouseButton1Click:Connect(function()
				-- TODO: If button pressed, equip logic goes here
				if category == "Characters" then
					local previousCharacterName = equipped.Character
					local characterName = button.Name
					
					if characterName ~= equipped.Character then
						local success = ShopClientService:EquipItem("Characters", characterName)
						
						if success then
							equipped.Character = characterName
						else
							characterName = previousCharacterName
						end
					end
					
					local previousButton
					local newButton
					
					for _, button in buttons do
						if button.Name == previousCharacterName then
							previousButton = button
						end
						if button.Name == characterName then
							newButton = button
						end
					end
					
					previousButton.WardrobeItem.EquipFrame.Equipped.Visible = false
					newButton.WardrobeItem.EquipFrame.Equipped.Visible = true
				end
				
				self:UpdateDummy()
			end)
		end
	end
end

function ClientCustomizationService.UpdateDummy(self: ClientCustomizationService)
	if rigFolder:FindFirstChildWhichIsA("Model") then
		rigFolder:FindFirstChildWhichIsA("Model"):Destroy()
	end
	
	local newDummy = self:CreateCharacterFromEquipped()
	
	if not newDummy then
		warn("[CUSTOMIZATION_SERVICE]: No asset found for this character.")
		return
	end
	
	newDummy.Parent = rigFolder
	
	self:SetDummy(newDummy)
	
	newDummy.HumanoidRootPart.CFrame = wardrobe.RigSpot.CFrame
end

function ClientCustomizationService.CreateCharacterFromEquipped(self: ClientCustomizationService, newEquipped: {}?)
	local newDummy
	local newerEquipped = newEquipped or equipped
	
	if newerEquipped.Skin == "" then
		for _, asset in shopAssets:GetDescendants() do
			if asset.Name == newerEquipped.Character and asset:IsA("Model") then
				newDummy = asset:Clone()
			end
		end
	else

	end
	
	newDummy.HumanoidRootPart.Anchored = true
	
	return newDummy
end
	
function ClientCustomizationService.SetDummy(self: ClientCustomizationService, newDummy : Model)
	dummy = newDummy
end

function ClientCustomizationService.SetEquipped(self: ClientCustomizationService, equippedPayload)
	equipped = equippedPayload
end

function ClientCustomizationService.SetInRound(self: ClientCustomizationService, newValue: boolean)
	inRound = newValue
end

function ClientCustomizationService.GetCustomizationOpen(self: ClientCustomizationService)
	return customizationOpen
end

function ClientCustomizationService.GetDummy(self: ClientCustomizationService)
	return dummy
end

type ClientCustomizationService = typeof(ClientCustomizationService) & {
	
}

return ClientCustomizationService
