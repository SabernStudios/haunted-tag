-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Gui Stuff
local PlayerGui = Players.LocalPlayer.PlayerGui
local ActionGui = PlayerGui:WaitForChild("ActionGui")

local PowerupFrame = ActionGui:WaitForChild("PowerupFrame")
local PowerupCooldownFill = PowerupFrame:WaitForChild("CooldownFill")
local PowerupViewport = PowerupFrame:WaitForChild("ViewportFrame")
local PowerupText = PowerupFrame:WaitForChild("PowerupText")

-- Variables
local currentPowerupTween: Tween = nil

-- Constants
local POWERUP_VIEWPORT_LOOKVECTOR_CONSTANT = 3.5

local POWERUP_COOLDOWN_FILL_ORIGINAL_POSITION = PowerupCooldownFill.Position
local POWERUP_COOLDOWN_FILL_ORIGINAL_SIZE = PowerupCooldownFill.Size

-- Modules
local Modules = ReplicatedStorage.Shared.Modules

local GuiModule = require(Modules.GuiModule)

-- Packages
local Packages = ReplicatedStorage.Packages

local Signal = require(Packages.Signal)

-- Custom Services
local Services = ReplicatedStorage.Shared.Services

local CameraServiceClient = require(Services.CameraServiceClient)
local ClientTokenService = require(Services.ClientTokenService)

local PickupService = {}

function PickupService.Init(self: PickupService)
	
end

function PickupService.Pickup(self: PickupService, tag: string, payload: {})
	if tag == "Powerup" then
		if not payload then
			return
		end
		
		-- Update viewport
		local camera = Instance.new("Camera")
		local primaryPartCFrame = payload.PowerupModel.PrimaryPart.CFrame
		camera.CFrame = CFrame.lookAt((primaryPartCFrame).Position + primaryPartCFrame.LookVector * POWERUP_VIEWPORT_LOOKVECTOR_CONSTANT, primaryPartCFrame.Position)
		GuiModule.UpdateViewportFrame(PowerupViewport, camera, {payload.PowerupModel})
		
		-- Update cooldown
		ClientTokenService:SetActiveToken(tag, payload.EndTime)
		
		PowerupCooldownFill.Visible = true
		
		local originalUdim2Size = POWERUP_COOLDOWN_FILL_ORIGINAL_SIZE
		local originalUdim2Position = POWERUP_COOLDOWN_FILL_ORIGINAL_POSITION
		
		if currentPowerupTween then
			currentPowerupTween:Cancel()
			currentPowerupTween:Destroy()
			
			PowerupCooldownFill.Position = originalUdim2Position
			PowerupCooldownFill.Size = originalUdim2Size
		end
		
		local tween = GuiModule.StartFrameFillTween(PowerupCooldownFill, payload.EndTime, UDim2.fromScale(originalUdim2Position.X.Scale, -(originalUdim2Position.Y.Scale - originalUdim2Size.Y.Scale)), UDim2.fromScale(originalUdim2Size.X.Scale * 2, 0))
		
		PowerupText.Text = payload.PowerupName
		
		currentPowerupTween = tween
		
		local ghostNoiseClone = ReplicatedStorage.Assets.SoundEffects["ghost-ooo"]:Clone()
		ghostNoiseClone.Parent = ReplicatedStorage
		ghostNoiseClone:Play()
		ghostNoiseClone.Ended:Once(function()
			ghostNoiseClone:Destroy()
		end)
		
		local orangeParticleEmitterClone = ReplicatedStorage.Assets.ParticleEmitters.OrangeParticleEmitter:Clone()
		orangeParticleEmitterClone.Parent = workspace
		orangeParticleEmitterClone.Position = payload.SpawnerPart.Position
		orangeParticleEmitterClone.ParticleEmitter:Emit(30)
		
		task.delay(1, function()
			orangeParticleEmitterClone:Destroy()
		end)
		
		task.delay(payload.EndTime-time(), function()
			if ClientTokenService:GetActiveToken(tag) ~= payload.EndTime then
				return
			end
			
			GuiModule.UpdateViewportFrame(PowerupViewport, camera, {})
			PowerupCooldownFill.Visible = false
			PowerupCooldownFill.Position = originalUdim2Position
			PowerupCooldownFill.Size = originalUdim2Size
			PowerupText.Text = "No Powerup"
		end)
	end
end

type PickupService = typeof(PickupService) & {
	
}

return PickupService
