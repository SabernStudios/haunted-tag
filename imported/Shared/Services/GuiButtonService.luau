-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player
local player = Players.LocalPlayer

-- PlayerGui
local playerGui = player:WaitForChild("PlayerGui")

-- Modules
local Modules = ReplicatedStorage.Shared.Modules

local GuiModule = require(Modules.GuiModule)

local GuiButtonService = {}

function GuiButtonService.Init(self: GuiButtonService)
	for _, guiButton in playerGui:GetDescendants() do
		if guiButton:IsA("GuiButton") then
			-- Scale stuff
			local normalPosition = guiButton.Position
			local normalSize = guiButton.Size
			--local hoverPositionScale = (1 - ((GuiModule.GetButtonHoverScale() - 1)/2))
			--local hoverPosition = UDim2.new(normalPosition.X.Scale * hoverPositionScale, normalPosition.X.Offset * hoverPositionScale, normalPosition.Y.Scale * hoverPositionScale, normalPosition.Y.Offset * hoverPositionScale)
			local hoverSize = GuiModule.ConvertMultipliedUDim2(guiButton.Size, GuiModule.GetButtonHoverScale())
			--local clickPositionScale = (1 - ((GuiModule.GetButtonClickScale() - 1)/2))
			--local clickPosition = UDim2.new(normalPosition.X.Scale * clickPositionScale, normalPosition.X.Offset * clickPositionScale, normalPosition.Y.Scale * clickPositionScale, normalPosition.Y.Offset * clickPositionScale)
			local clickSize = GuiModule.ConvertMultipliedUDim2(guiButton.Size, GuiModule.GetButtonClickScale())
			
			-- Events
			guiButton.MouseEnter:Connect(function()
				GuiModule.ButtonHoverStart(guiButton, hoverSize)
			end)
			guiButton.MouseLeave:Connect(function()
				GuiModule.ButtonHoverEnd(guiButton, normalSize)
			end)
			guiButton.MouseButton1Down:Connect(function()
				GuiModule.ButtonClickDown(guiButton, clickSize)
			end)
			guiButton.MouseButton1Up:Connect(function()
				GuiModule.ButtonClickUp(guiButton, normalSize)
			end)
		end
	end
end

function GuiButtonService.RegisterButton(self: GuiButtonService, guiButton: GuiButton, hoverScale: number?, clickScale: number?)
	-- Scale stuff
	local normalPosition = guiButton.Position
	local normalSize = guiButton.Size
	--local hoverPositionScale = (1 - ((GuiModule.GetButtonHoverScale() - 1)/2))
	--local hoverPosition = UDim2.new(normalPosition.X.Scale * hoverPositionScale, normalPosition.X.Offset * hoverPositionScale, normalPosition.Y.Scale * hoverPositionScale, normalPosition.Y.Offset * hoverPositionScale)
	local hoverSize
	if hoverScale then
		hoverSize = GuiModule.ConvertMultipliedUDim2(guiButton.Size, hoverScale)
	else
		hoverSize = GuiModule.ConvertMultipliedUDim2(guiButton.Size, GuiModule.GetButtonHoverScale())
	end
	 
	--local clickPositionScale = (1 - ((GuiModule.GetButtonClickScale() - 1)/2))
	--local clickPosition = UDim2.new(normalPosition.X.Scale * clickPositionScale, normalPosition.X.Offset * clickPositionScale, normalPosition.Y.Scale * clickPositionScale, normalPosition.Y.Offset * clickPositionScale)
	local clickSize
	if clickScale then
		clickSize = GuiModule.ConvertMultipliedUDim2(guiButton.Size, clickScale)
	else
		clickSize = GuiModule.ConvertMultipliedUDim2(guiButton.Size, GuiModule.GetButtonClickScale())
	end
	-- Events
	guiButton.MouseEnter:Connect(function()
		GuiModule.ButtonHoverStart(guiButton, hoverSize)
	end)
	guiButton.MouseLeave:Connect(function()
		GuiModule.ButtonHoverEnd(guiButton, normalSize)
	end)
	guiButton.MouseButton1Down:Connect(function()
		GuiModule.ButtonClickDown(guiButton, clickSize)
	end)
	guiButton.MouseButton1Up:Connect(function()
		GuiModule.ButtonClickUp(guiButton, normalSize)
	end)
end

type GuiButtonService = typeof (GuiButtonService) & {
	
}

return GuiButtonService
