-- Services
local CAS = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Player
local player = Players.LocalPlayer

-- PlayerGui
local playerGui = player:WaitForChild("PlayerGui")

local currencyGui = playerGui:WaitForChild("CurrencyGui")
local coinFrame = currencyGui:WaitForChild("CoinFrame")
local coinIcon = coinFrame:WaitForChild("Icon")
local coinDisplayText = coinFrame:WaitForChild("Display")

local endScreenGui = playerGui:WaitForChild("EndScreenGui")
local endScreenBackground = endScreenGui:WaitForChild("Background")
local endScreenGridFrame = endScreenBackground:WaitForChild("GridFrame")
local endScreenFakeGridFrame = endScreenBackground:WaitForChild("FakeGridFrame")
local endScreenTotalFrame = endScreenBackground:WaitForChild("TotalFrame")
local endScreenTotalValueText = endScreenTotalFrame:WaitForChild("Value")

local mapSelectionGui = playerGui:WaitForChild("MapSelectionGui")
local mapSelectionGuiStartFolder = mapSelectionGui:WaitForChild("Start")
local mapSelectionGuiEndFolder = mapSelectionGui:WaitForChild("End")
local mapSelectionGuiFolder = mapSelectionGui:WaitForChild("MapSelection")

local modeSelectionGui = playerGui:WaitForChild("ModeSelectionGui")
local modeSelectionGuiStartFolder = modeSelectionGui:WaitForChild("Start")
local modeSelectionGuiEndFolder = modeSelectionGui:WaitForChild("End")
local modeSelectionGuiFolder = modeSelectionGui:WaitForChild("ModeSelection")

local roundGui = playerGui:WaitForChild("RoundGui")
local roundBackground = roundGui:WaitForChild("RoundBackground")
local timerText = roundBackground:WaitForChild("TimerText")

local transitionGui = playerGui:WaitForChild("TransitionGui")
local blackoutFrame = transitionGui:WaitForChild("BlackoutFrame")

local countdownGui = playerGui:WaitForChild("CountdownGui")
local countdownStartFolder = countdownGui:WaitForChild("Start")
local countdownEndFolder = countdownGui:WaitForChild("End")

-- UI Presets
local UIPresets = ReplicatedStorage.Assets.UIPresets

local MapModeTemplate = UIPresets["MapModeSelect"]["MapModeTemplate"]
local PlayerPin = UIPresets["MapModeSelect"]["PlayerPin"]
local PlayerPinViewport = UIPresets["MapModeSelect"]["PlayerPinViewport"]
local EndScreenTemplate = UIPresets["EndScreen"]["TemplateFrame"]
local CoinTemplate = UIPresets["Icons"]["CoinIcon"]

local CountdownPreset = UIPresets.CountdownPresets.CountdownPreset

-- Sound Effects
local SoundEffects = ReplicatedStorage.Assets.SoundEffects

local ClockTick = SoundEffects["clock tick"]

-- Modules
local Modules = ReplicatedStorage.Shared.Modules

local GuiModule = require(Modules.GuiModule)

-- Remotes
local roundEvent = ReplicatedStorage.Shared.Remotes.RoundEvent

-- Custom Services
local Services = ReplicatedStorage.Shared.Services

local ClientCustomizationService = require(Services.ClientCustomizationService)
local GuiButtonService = require(Services.GuiButtonService)

local ClientRoundEventService = {}

function ClientRoundEventService.OnEvent(self: ClientRoundEventService, eventName: string, payload: {})
	if eventName == "RoundTimerChanged" then
		self:OnRoundTimerChanged(payload)
	elseif eventName == "MapSelectionStarted" then
		self:OnMapSelectionStarted(payload)
	elseif eventName == "MapSelectionEnded" then
		self:OnMapSelectionEnded(payload)
	elseif eventName == "PlayerSelectedMap" then
		self:OnPlayerSelectedMap(payload)
	elseif eventName == "PlayerUnselectedMap" then
		self:OnPlayerUnselectedMap(payload)
	elseif eventName == "ModeSelectionStarted" then
		self:OnModeSelectionStarted(payload)
	elseif eventName == "ModeSelectionEnded" then
		self:OnModeSelectionEnded(payload)
	elseif eventName == "PlayerSelectedMode" then
		self:OnPlayerSelectedMode(payload)
	elseif eventName == "PlayerUnselectedMode" then
		self:OnPlayerUnselectedMode(payload)
	elseif eventName == "ServerLoadingMap" then
		self:OnServerLoadingMap(payload)
	elseif eventName == "RoundStartingSoon" then
		self:OnRoundStartingSoon(payload)
	elseif eventName == "Teleporting" then
		self:OnTeleporting(payload)
	elseif eventName == "TeleportingEnded" then
		self:OnTeleportingEnded(payload)
	elseif eventName == "ServerSelectingGhosts" then
		self:OnServerSelectingGhosts(payload)
	elseif eventName == "ServerStartingRoundCountdown" then
		self:OnServerStartingRoundCountdown(payload)
	elseif eventName == "ServerStartingRound" then
		self:OnServerStartingRound(payload)
	elseif eventName == "ServerRoundOver" then
		self:OnServerRoundOver(payload)
	elseif eventName == "PodiumCameraTween" then
		self:OnPodiumCameraTween(payload)
	elseif eventName == "ShowEndScreen" then
		self:OnShowEndScreen(payload)
	elseif eventName == "HideEndScreen" then
		self:OnHideEndScreen(payload)
	elseif eventName == "ServerStartingIntermission" then
		self:OnServerStartingIntermission(payload)
	end
end

function ClientRoundEventService.OnMapSelectionStarted(self: ClientRoundEventService, payload: {})
	-- Ensure previous map selection is cleared (Might check this if there's a future memory leak because the GUI BUTTONS never unregister)
	ClientCustomizationService:SetInRound(true)

	if ClientCustomizationService:GetCustomizationOpen() then
		ClientCustomizationService:CloseCharacterCustomization()
	end
	
	for _, child in mapSelectionGuiFolder:GetChildren() do
		if child:IsA("ImageLabel") then
			child:Destroy()
		end
	end
	
	if not payload then
		return
	end
	
	for i = 1, 3 do
		local characteristics = payload.MapSelection[i]
		
		local mapTemplate = MapModeTemplate:Clone()
		GuiButtonService:RegisterButton(mapTemplate :: GuiButton)
		mapTemplate.Parent = mapSelectionGuiFolder
		mapTemplate.Name = characteristics["MapName"]
		mapTemplate.TextLabel.Text = characteristics["MapName"]
		mapTemplate.Image = characteristics["ImageId"]
		mapTemplate.Position = mapSelectionGuiStartFolder[tostring(i)].Position
		mapTemplate.Size = mapSelectionGuiStartFolder[tostring(i)].Size
		mapTemplate.Rotation = mapSelectionGuiStartFolder[tostring(i)].Rotation
		
		local tween = TweenService:Create(mapTemplate, TweenInfo.new(payload.SelectionTweenTime, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = mapSelectionGuiEndFolder[tostring(i)].Position})
		tween:Play()
		
		mapTemplate.MouseButton1Click:Connect(function()
			roundEvent:FireServer("PlayerSelectedMap", {MapName = mapTemplate.Name})
		end)
	end
	
	GuiModule.StartCountdown(timerText, "Map Selection: ", payload.EndTime)
end

function ClientRoundEventService.OnModeSelectionStarted(self: ClientRoundEventService, payload: {})
	-- Ensure previous map selection is cleared (Might check this if there's a future memory leak because the GUI BUTTONS never unregister)
	for _, child in modeSelectionGuiFolder:GetChildren() do
		if child:IsA("ImageLabel") then
			child:Destroy()
		end
	end

	if not payload then
		return
	end

	for i = 1, 3 do
		local characteristics = payload.ModeSelection[i]

		local modeTemplate = MapModeTemplate:Clone()
		GuiButtonService:RegisterButton(modeTemplate :: GuiButton)
		modeTemplate.Parent = modeSelectionGuiFolder
		modeTemplate.Name = characteristics["ModeName"]
		modeTemplate.TextLabel.Text = characteristics["ModeName"]
		modeTemplate.Image = characteristics["ImageId"]
		modeTemplate.Position = modeSelectionGuiStartFolder[tostring(i)].Position
		modeTemplate.Size = modeSelectionGuiStartFolder[tostring(i)].Size
		modeTemplate.Rotation = modeSelectionGuiStartFolder[tostring(i)].Rotation

		local tween = TweenService:Create(modeTemplate, TweenInfo.new(payload.SelectionTweenTime, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = modeSelectionGuiEndFolder[tostring(i)].Position})
		tween:Play()

		modeTemplate.MouseButton1Click:Connect(function()
			roundEvent:FireServer("PlayerSelectedMode", {ModeName = modeTemplate.Name})
		end)
	end

	GuiModule.StartCountdown(timerText, "Mode Selection: ", payload.EndTime)
end

function ClientRoundEventService.OnMapSelectionEnded(self: ClientRoundEventService, payload: {})
	timerText.Text = "Map Selected: " .. payload.MapName
	
	for i, child in mapSelectionGuiFolder:GetChildren() do
		if child:IsA("ImageButton") then
			local tween = TweenService:Create(child, TweenInfo.new(payload.SelectionTweenTime, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = mapSelectionGuiStartFolder[tostring(i)].Position})
			tween:Play()
		end
	end
	
	task.wait(payload.SelectionTweenTime)
	
	for _, child in mapSelectionGuiFolder:GetChildren() do
		if child:IsA("ImageButton") then
			child:Destroy()
		end
	end
end

function ClientRoundEventService.OnModeSelectionEnded(self: ClientRoundEventService, payload: {})
	timerText.Text = "Mode Selected: " .. payload.ModeName

	for i, child in modeSelectionGuiFolder:GetChildren() do
		if child:IsA("ImageButton") then
			local tween = TweenService:Create(child, TweenInfo.new(payload.SelectionTweenTime, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = modeSelectionGuiStartFolder[tostring(i)].Position})
			tween:Play()
		end
	end

	task.wait(payload.SelectionTweenTime)

	for _, child in modeSelectionGuiFolder:GetChildren() do
		if child:IsA("ImageButton") then
			child:Destroy()
		end
	end
end

function ClientRoundEventService.OnPlayerSelectedMap(self: ClientRoundEventService, payload: {})
	local player = payload.Player
	local mapName = payload.MapName
	
	local image, isReady = Players:GetUserThumbnailAsync(
		player.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size352x352
	)
	
	local playerSelectedMap = mapSelectionGuiFolder[mapName]
	
	if not playerSelectedMap then
		return
	end
	
	local playerPinClone = PlayerPinViewport:Clone()
	playerPinClone.Parent = playerSelectedMap
	
	-- Viewport Stuff
	local camera = Instance.new("Camera")
	camera.Parent = playerPinClone
	playerPinClone.CurrentCamera = camera
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = playerPinClone
	local character = player.Character or player.CharacterAdded:Wait()
	if not character.Archivable then
		character.Archivable = true
	end
	local characterClone = character:Clone()

	local humanoid = characterClone:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		warn("No Humanoid found")
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	-- Stop anything already playing
	for _, track in animator:GetPlayingAnimationTracks() do
		track:Stop(0)
	end
	
	characterClone.Parent = worldModel
	camera.CFrame = CFrame.new(characterClone:GetPivot().Position + characterClone.PrimaryPart.CFrame.LookVector * 2, characterClone:GetPivot().Position)
	character.Archivable = false
	
	--playerPinClone.Image = image
	playerPinClone.Name = player.Name
	playerPinClone.Visible = true
	playerPinClone.Position = UDim2.new(math.random(0,80)/100, 0, math.random(0,80)/100, 0)
	playerPinClone.Rotation = math.random(-15, 15)
end

function ClientRoundEventService.OnPlayerSelectedMode(self: ClientRoundEventService, payload: {})
	local player = payload.Player
	local modeName = payload.ModeName

	local image, isReady = Players:GetUserThumbnailAsync(
		player.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size352x352
	)

	local playerSelectedMode = modeSelectionGuiFolder[modeName]

	if not playerSelectedMode then
		return
	end

	local playerPinClone = PlayerPinViewport:Clone()
	playerPinClone.Parent = playerSelectedMode

	-- Viewport Stuff
	local camera = Instance.new("Camera")
	camera.Parent = playerPinClone
	playerPinClone.CurrentCamera = camera
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = playerPinClone
	local character = player.Character or player.CharacterAdded:Wait()
	if not character.Archivable then
		character.Archivable = true
	end
	local characterClone = character:Clone()

	local humanoid = characterClone:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		warn("No Humanoid found")
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	-- Stop anything already playing
	for _, track in animator:GetPlayingAnimationTracks() do
		track:Stop(0)
	end

	characterClone.Parent = worldModel
	camera.CFrame = CFrame.new(characterClone:GetPivot().Position + characterClone.PrimaryPart.CFrame.LookVector * 2, characterClone:GetPivot().Position)
	character.Archivable = false

	--playerPinClone.Image = image
	playerPinClone.Name = player.Name
	playerPinClone.Visible = true
	playerPinClone.Position = UDim2.new(math.random(0,80)/100, 0, math.random(0,80)/100, 0)
	playerPinClone.Rotation = math.random(-15, 15)
end

function ClientRoundEventService.OnPlayerUnselectedMap(self: ClientRoundEventService, payload: {})
	local player = payload.Player
	local mapName = payload.MapName

	local playerSelectedMap = mapSelectionGuiFolder[mapName]
	
	if not playerSelectedMap then
		return
	end
	
	local playerPin = playerSelectedMap:FindFirstChild(player.Name)
	
	if not playerPin then
		return
	end
	
	playerPin:Destroy()
end

function ClientRoundEventService.OnPlayerUnselectedMode(self: ClientRoundEventService, payload: {})
	local player = payload.Player
	local modeName = payload.ModeName

	local playerSelectedMode = modeSelectionGuiFolder[modeName]

	if not playerSelectedMode then
		return
	end

	local playerPin = playerSelectedMode:FindFirstChild(player.Name)

	if not playerPin then
		return
	end

	playerPin:Destroy()
end

function ClientRoundEventService.OnServerLoadingMap(self: ClientRoundEventService, payload: {})
	timerText.Text = "Now Loading: " .. payload.MapName
end

function ClientRoundEventService.OnRoundStartingSoon(self: ClientRoundEventService, payload: {})
	if not payload then
		return
	end
	
	if not payload.EndTime then
		return
	end
	
	GuiModule.StartCountdown(timerText, "Round Starting in: ", payload.EndTime)
end

function ClientRoundEventService.OnTeleporting(self: ClientRoundEventService, payload: {})
	local tween = TweenService:Create(blackoutFrame, payload.TweenInfo, {Position = UDim2.new(0,0,0,0)})
	tween:Play()
	
	self:DisableMovement()
end

function ClientRoundEventService.OnTeleportingEnded(self: ClientRoundEventService, payload: {})
	local tween = TweenService:Create(blackoutFrame, payload.TweenInfo, {Position = UDim2.new(1,0,0,0)})
	tween:Play()
	
	tween.Completed:Wait()
	
	blackoutFrame.Position = UDim2.new(-1,0,0,0)
end

function ClientRoundEventService.OnServerSelectingGhosts(self: ClientRoundEventService, payload: {})
	GuiModule.StartCountdown(timerText, "Selecting Ghosts In: ", payload.EndTime)
end

function ClientRoundEventService.OnServerStartingRoundCountdown(self: ClientRoundEventService, payload: {})
	for _, object in countdownGui:GetChildren() do
		if object:IsA("TextLabel") then
			object:Destroy()
		end
	end
	
	countdownGui.Enabled = true
	
	for i = 3, 1, -1 do
		local countdownPresetClone = CountdownPreset:Clone()
		countdownPresetClone.Parent = countdownGui
		countdownPresetClone.Text = i
		countdownPresetClone.Visible = true
		countdownPresetClone.TextColor3 = countdownStartFolder[i].TextColor3
		countdownPresetClone.BackgroundColor3 = countdownStartFolder[i].BackgroundColor3
		countdownPresetClone.Position = countdownStartFolder[i].Position
		countdownPresetClone.Size = countdownStartFolder[i].Size
		countdownPresetClone.Rotation = countdownStartFolder[i].Rotation
		
		local tween = TweenService:Create(countdownPresetClone, payload.TweenInfo, {Position = countdownEndFolder[i].Position, Size = countdownEndFolder[i].Size, Rotation = countdownEndFolder[i].Rotation})
		tween:Play()
		
		local clockTickClone = ClockTick:Clone()
		clockTickClone.Parent = ReplicatedStorage
		clockTickClone:Play()
		
		task.delay(clockTickClone.TimeLength, function()
			clockTickClone:Destroy()
		end)
		
		task.wait(1)
	end
	
	countdownGui.Enabled = false
end

function ClientRoundEventService.OnServerStartingRound(self: ClientRoundEventService, payload: {})
	self:EnableMovement()
	
	GuiModule.StartFormattedCountdown(timerText, "", payload.EndTime)
end

function ClientRoundEventService.OnServerRoundOver(self: ClientRoundEventService, payload: {})
	timerText.Text = "Round Over!"
end

function ClientRoundEventService.OnPodiumCameraTween(self: ClientRoundEventService, payload: {})
	timerText.Text = "Round Over!"
	
	local currentCamera = workspace.CurrentCamera
	
	currentCamera.CameraType = Enum.CameraType.Scriptable
	
	local tween = TweenService:Create(currentCamera, payload.TweenInfo, {CFrame = payload.CFrame})
	tween:Play()
end

function ClientRoundEventService.OnShowEndScreen(self: ClientRoundEventService, payload: {})
	local masterList = payload.MASTER_LIST
	local total = payload.TOTAL
	
	for i, value in masterList do
		local endScreenTemplateClone = EndScreenTemplate:Clone()
		
		endScreenTemplateClone.StatName.Text = value[1]
		endScreenTemplateClone.Multiplier.Text = value[2]
		endScreenTemplateClone.BaseValue.Text = value[3]
		endScreenTemplateClone.Value.Text = value[2] * value[3]
		
		endScreenTemplateClone.LayoutOrder = i
		endScreenTemplateClone.Name = i
		endScreenTemplateClone.Parent = endScreenGridFrame
	end
	
	local intValue = Instance.new("IntValue")
	intValue.Value = 0
	
	endScreenGui.Enabled = true
	
	local moneyTween = TweenService:Create(intValue, TweenInfo.new(payload.PER_FRAME_END_SCREEN_TIME*#endScreenGridFrame:GetChildren(), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Value = payload.TOTAL})
	
	intValue.Changed:Connect(function()
		endScreenTotalValueText.Text = intValue.Value
	end)
	
	for i = 1, (#endScreenGridFrame:GetChildren()-1) do
		local frame = endScreenGridFrame[i]
		frame.Parent = endScreenFakeGridFrame
		
		local tween = TweenService:Create(frame, payload.END_SCREEN_FRAME_TWEEN_INFO, {Position = endScreenTotalFrame.Position})
		tween:Play()
		
		task.wait(payload.PER_FRAME_END_SCREEN_TIME)
		
		frame:Destroy()
		
		if i == 1 then
			moneyTween:Play()
		end
	end
	
	moneyTween.Completed:Wait()
	
	intValue:Destroy()
	
	task.wait(1)
	
	local newIntValue = Instance.new("IntValue")
	newIntValue.Value = tonumber(coinDisplayText.Text)
	
	local newIntValue2 = Instance.new("IntValue")
	newIntValue2.Value = payload.TOTAL
	
	local moneyTween2 = TweenService:Create(newIntValue, TweenInfo.new(payload.COIN_COLLECTION_TIME+1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Value = newIntValue.Value + payload.TOTAL})
	local moneyTween3 = TweenService:Create(newIntValue2, TweenInfo.new(payload.COIN_COLLECTION_TIME+1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Value = 0})
	
	newIntValue.Changed:Connect(function()
		coinDisplayText.Text = newIntValue.Value
	end)
	
	newIntValue2.Changed:Connect(function()
		endScreenTotalValueText.Text = newIntValue2.Value
	end)
	
	for i = 1, 100 do
		task.spawn(function()
			local coinTemplateClone = CoinTemplate:Clone()
			coinTemplateClone.Parent = endScreenGui
				
			GuiModule.BezierObject(coinTemplateClone, UDim2.new(0.563, 0, 0.842, 0), UDim2.new(0.911, 0, 0.022, 0), payload.COIN_COLLECTION_TIME)
				
			coinTemplateClone:Destroy()
		end)
		
		task.wait()
		
		if i == 1 then
			moneyTween2:Play()
			moneyTween3:Play()
		end
	end
	
	moneyTween2.Completed:Wait()
	
	newIntValue:Destroy()
	newIntValue2:Destroy()
	
	--for i = 0, 100 do
	--	task.wait(0.05)
	--end
end

function ClientRoundEventService.OnHideEndScreen(self: ClientRoundEventService, payload: {})
	endScreenGui.Enabled = false
end

function ClientRoundEventService.OnServerStartingIntermission(self: ClientRoundEventService, payload: {})
	self:EnableMovement()
	ClientCustomizationService:SetInRound(false)
	
	workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	
	
	GuiModule.StartCountdown(timerText, "Intermission: ", payload.EndTime)
end

-- The ONE function that has to look like this, sorry :sob:
function ClientRoundEventService.BlockMovement()
	return Enum.ContextActionResult.Sink
end

function ClientRoundEventService.DisableMovement(self: ClientRoundEventService)
	CAS:BindAction("DisableMovement", self.BlockMovement, false, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.D, Enum.KeyCode.S, Enum.KeyCode.Space)
end

function ClientRoundEventService.EnableMovement(self: ClientRoundEventService)
	CAS:UnbindAction("DisableMovement")
end

type ClientRoundEventService = typeof(ClientRoundEventService) & {
	
}

return ClientRoundEventService
