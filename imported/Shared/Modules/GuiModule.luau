-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Packages
local Packages = ReplicatedStorage.Packages

local StringUtils = require(Packages.StringUtils)

-- Constants
local GUI_BUTTON_HOVER_SCALE = 1.1
local GUI_BUTTON_HOVER_TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local GUI_BUTTON_CLICK_SCALE = 0.9
local GUI_BUTTON_CLICK_TWEEN_INFO = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local TRANSITION_TWEEN_INFO: TweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Variables
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

local transitionGui = playerGui:WaitForChild("TransitionGui")
local blackoutFrame = transitionGui:WaitForChild("BlackoutFrame")

local GuiModule = {}

function GuiModule.Init()
	
end

function GuiModule.UpdateViewportFrame(viewport: ViewportFrame, camera: Camera, models: {Model})
	-- Reseting Viewport State
	for _, thing in viewport:GetChildren() do
		if thing:IsA("Model") or thing:IsA("Camera") then
			thing:Destroy()
		end
	end
	
	local cameraClone = camera:Clone()
	local modelsClone = {}
	
	for _, model in models do
		table.insert(modelsClone, model:Clone())
	end
	
	cameraClone.Parent = viewport
	viewport.CurrentCamera = cameraClone
	
	for _, model in modelsClone do
		model.Parent = viewport
	end
end

function GuiModule.StartFrameFillTween(frame: Frame, endTime: number, endUdim2Position: UDim2, endUdim2Size: UDim2)
	local tween = TweenService:Create(frame, TweenInfo.new(endTime-time(), Enum.EasingStyle.Linear), {Position = endUdim2Position, Size = endUdim2Size})
	tween:Play()
	
	return tween
end

function GuiModule.ButtonHoverStart(button: GuiButton, hoverSize: UDim2)
	local tween = TweenService:Create(button, GUI_BUTTON_HOVER_TWEEN_INFO, {Size = hoverSize})
	tween:Play()
	
	return tween
end

function GuiModule.ButtonHoverEnd(button: GuiButton, normalSize: UDim2)
	local tween = TweenService:Create(button, GUI_BUTTON_HOVER_TWEEN_INFO, {Size = normalSize})
	tween:Play()

	return tween
end

function GuiModule.ButtonClickDown(button: GuiButton, clickSize: UDim2)
	local tween = TweenService:Create(button, GUI_BUTTON_HOVER_TWEEN_INFO, {Size = clickSize})
	tween:Play()
	
	local buttonClickCloneSound = ReplicatedStorage.Assets.SoundEffects["Button Click"]:Clone()
	buttonClickCloneSound.Parent = button
	buttonClickCloneSound:Play()
	
	task.delay(buttonClickCloneSound.TimeLength, function()
		buttonClickCloneSound:Destroy()
	end)

	return tween
end

function GuiModule.ButtonClickUp(button: GuiButton, normalSize: UDim2)
	local tween = TweenService:Create(button, GUI_BUTTON_HOVER_TWEEN_INFO, {Size = normalSize})
	tween:Play()

	return tween
end

function GuiModule.StartCountdown(textLabel: TextLabel, stringDisplay: string, endTime: number)
	for i = endTime - workspace:GetServerTimeNow(), 0, -1 do
		if workspace:GetServerTimeNow() > endTime then
			break
		end
		
		textLabel.Text = stringDisplay..math.floor(i)
		task.wait(1)
	end
end

function GuiModule.StartFormattedCountdown(textLabel: TextLabel, stringDisplay: string, endTime: number)
	for i = endTime - workspace:GetServerTimeNow(), 0, -1 do
		if workspace:GetServerTimeNow() > endTime then
			break
		end

		textLabel.Text = stringDisplay..StringUtils.FormatTime(math.floor(i))
		task.wait(1)
	end
end

function GuiModule.Transition(waitTime: number)
	local tween = TweenService:Create(blackoutFrame, TRANSITION_TWEEN_INFO, {Position = UDim2.new(0,0,0,0)})
	tween:Play()
	
	task.wait(waitTime)
	
	local tween2 = TweenService:Create(blackoutFrame, TRANSITION_TWEEN_INFO, {Position = UDim2.new(1,0,0,0)})
	tween2:Play()

	task.spawn(function()
		tween2.Completed:Wait()
		blackoutFrame.Position = UDim2.new(-1,0,0,0)
	end)
end

local function QuadraticBezier(t, p0: UDim2, p1: UDim2, p2: UDim2)
	local x = (1 - t)^2 * p0.X.Scale
		+ 2 * (1 - t) * t * p1.X.Scale
		+ t^2 * p2.X.Scale

	local y = (1 - t)^2 * p0.Y.Scale
		+ 2 * (1 - t) * t * p1.Y.Scale
		+ t^2 * p2.Y.Scale

	return UDim2.fromScale(x, y)
end


function GuiModule.BezierObject(
	guiObject: GuiObject,
	startPos: UDim2,
	endPos: UDim2,
	duration: number
)

	-- Find midpoint between start and end
	local midpoint = UDim2.fromScale(
		(startPos.X.Scale + endPos.X.Scale) / 2,
		(startPos.Y.Scale + endPos.Y.Scale) / 2
	)

	-- Random curve amount
	-- These are SCALE values, since the whole calculation uses Scale
	local randomOffset = UDim2.fromScale(
		math.random(-15, 15) / 100,
		math.random(-15, 0) / 100
	)

	local controlPoint = midpoint + randomOffset

	local elapsed = 0

	guiObject.Position = startPos

	while elapsed < duration do
		elapsed += task.wait(0.01)

		local t = math.clamp(elapsed / duration, 0, 1)

		local position = QuadraticBezier(
			t,
			startPos,
			controlPoint,
			endPos
		)

		guiObject.Position = position
	end

	guiObject.Position = endPos
end

function GuiModule.ConvertMultipliedUDim2(udim2: UDim2, multiplier: number)
	return UDim2.new(udim2.X.Scale*multiplier, udim2.X.Offset*multiplier, udim2.Y.Scale*multiplier, udim2.Y.Offset*multiplier)
end

function GuiModule.GetButtonHoverScale()
	return GUI_BUTTON_HOVER_SCALE
end

function GuiModule.GetButtonClickScale()
	return GUI_BUTTON_CLICK_SCALE
end

return GuiModule
