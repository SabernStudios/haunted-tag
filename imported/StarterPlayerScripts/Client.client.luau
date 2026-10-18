local CAS = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFile = ReplicatedStorage:WaitForChild("Shared")

local classes = sharedFile:WaitForChild("Classes")
local modules = sharedFile:WaitForChild("Modules")
local services = sharedFile:WaitForChild("Services")

local characterAction = sharedFile:WaitForChild("Remotes"):WaitForChild("CharacterAction")
local itemEvent = sharedFile:WaitForChild("Remotes"):WaitForChild("ItemEvent")
local pickup = sharedFile:WaitForChild("Remotes"):WaitForChild("Pickup")
local progressionEvent = sharedFile:WaitForChild("Remotes"):WaitForChild("ProgressionEvent")
local roundEvent = sharedFile:WaitForChild("Remotes"):WaitForChild("RoundEvent")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local starterGui = game:GetService("StarterGui")

local lastMovementKey = nil
local activeKeys = {W = false, A = false, S = false, D = false}

local MovementModule = require(modules.MovementModule)

local AnimationHandler = require(script.Parent.AnimationHandler)
local HighlightManager = require(script.Parent.HighlightManager)

-- CharacterScripts
local RunAnimSanitization = game:GetService("StarterPlayer").StarterCharacterScripts.RunAnimSanitization

-- Custom Services
local CameraServiceClient = require(services:WaitForChild("CameraServiceClient"))
local ClientRoundEventService = require(services:WaitForChild("ClientRoundEventService"))
local ClientTaskService = require(services:WaitForChild("ClientTaskService"))
local CustomizationService = require(services:WaitForChild("ClientCustomizationService"))
local GuiButtonService = require(services:WaitForChild("GuiButtonService"))
local PickupService = require(services:WaitForChild("PickupService"))
local ShopClientService = require(services:WaitForChild("ShopClientService"))

local clientAnimationHandler = AnimationHandler.new({
	player = player,
	character = character,
	animator = humanoid:WaitForChild("Animator"),
})

local function onAction(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
	if actionName == "Dash" then
		local payload = {
			RootPart = rootPart,
			Humanoid = humanoid,
			Direction = MovementModule.ReturnIntendedDashDirection(humanoid),
		}
		characterAction:FireServer(actionName, inputState, inputObject.KeyCode, payload)
	elseif actionName == "Slide" then
		local payload = {
			RootPart = rootPart,
			Humanoid = humanoid,
			Direction = MovementModule.ReturnIntendedDashDirection(humanoid),
		}
		characterAction:FireServer(actionName, inputState, inputObject.KeyCode, payload)
	elseif actionName == "W" or actionName == "A" or actionName == "S" or actionName == "D" then
		if inputState == Enum.UserInputState.Begin then
			lastMovementKey = actionName
			activeKeys[actionName] = true
		elseif inputState == Enum.UserInputState.End then
			activeKeys[actionName] = false
		end
		
		characterAction:FireServer(actionName, inputState, inputObject.KeyCode)
	elseif actionName == "Sprint" then
		local payload = {
			Humanoid = humanoid,
		}
		characterAction:FireServer(actionName, inputState, inputObject.KeyCode, payload)
	elseif actionName == "Powerup" then
		characterAction:FireServer(actionName, inputState, inputObject.KeyCode)
	elseif actionName == "Tagging" then
		characterAction:FireServer(actionName, inputState, inputObject.KeyCode)
	elseif actionName == "Attack" then
		characterAction:FireServer(actionName, inputState, inputObject.KeyCode)
	elseif actionName == "Block" then
		characterAction:FireServer(actionName, inputState, inputObject.KeyCode)
	end
end

local function disableReset()
	while true do
		local success, err = pcall(function()
			starterGui:SetCore("ResetButtonCallback", false)
		end)

		if success then
			print("Reset disabled")
			break
		end

		warn("ResetButtonCallback not ready:", err)
		task.wait(0.1)
	end
end

local function init()
	-- Bind inputs
	CAS:BindAction("Slide", onAction, true, Enum.KeyCode.Q)
	CAS:SetPosition("Slide", UDim2.new(0, 0, 0.3, 0))
	CAS:SetTitle("Slide", "Slide")
	CAS:BindActionAtPriority("W", onAction, false, Enum.ContextActionPriority.Low.Value, Enum.KeyCode.W)
	CAS:BindActionAtPriority("A", onAction, false, Enum.ContextActionPriority.Low.Value, Enum.KeyCode.A)
	CAS:BindActionAtPriority("S", onAction, false, Enum.ContextActionPriority.Low.Value, Enum.KeyCode.S)
	CAS:BindActionAtPriority("D", onAction, false, Enum.ContextActionPriority.Low.Value, Enum.KeyCode.D)
	CAS:BindAction("Sprint", onAction, true, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift)
	CAS:SetPosition("Sprint", UDim2.new(0, 0, 0.5, 0))
	CAS:SetTitle("Sprint", "Sprint")
	
	CAS:BindAction("Powerup", onAction, false, Enum.KeyCode.E)
	
	-- Bind mouse inputs
	CAS:BindAction("Tagging", onAction, true, Enum.UserInputType.MouseButton1)
	CAS:SetPosition("Tagging", UDim2.new(0, 0, 0.7, 0))
	CAS:SetTitle("Tagging", "Tagging")
	--CAS:BindAction("Block", onAction, false, Enum.KeyCode.F)
	
	local success, fail = pcall(function()
		starterGui:SetCoreGuiEnabled(
			Enum.CoreGuiType.PlayerList,
			false
		)
	end)
	
	task.spawn(disableReset)
	
	GuiButtonService:Init()
	ShopClientService:Init()
end

-- Runtime

init()

-- Events
characterAction.OnClientEvent:Connect(function(action: string, data: {}?)
	clientAnimationHandler:OnActionStarted(action :: string, data :: {}?)
end)

itemEvent.OnClientEvent:Connect(function(event: string, payload: {})
	ShopClientService:OnItemEvent(event, payload)
	CustomizationService:OnItemEvent(event, payload)
end)

pickup.OnClientEvent:Connect(function(tag: string, payload: {})
	PickupService:Pickup(tag :: string, payload :: {})
end)

progressionEvent.OnClientEvent:Connect(function(tag: string, payload: {})
	ClientTaskService:OnEvent(tag, payload)
end)

CollectionService:GetInstanceAddedSignal("Tagged"):Connect(function(model: Instance)
	HighlightManager.AddFadingHighlight(model, 0.5)
end)

roundEvent.OnClientEvent:Connect(function(eventName: string, payload: {})
	ClientRoundEventService:OnEvent(eventName, payload)
end)

-- Character Death
player.CharacterAdded:Connect(function()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	
	clientAnimationHandler = AnimationHandler.new({
		player = player,
		character = character,
		animator = humanoid:WaitForChild("Animator"),
	})
	
	local runAnimationSanitizationClone = RunAnimSanitization:Clone()
	runAnimationSanitizationClone.Parent = character
end)

