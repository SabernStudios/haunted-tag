-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local player = Players.LocalPlayer

local currentTrack = nil

-- Modules
local MusicModule = require(ReplicatedStorage.Shared.Modules.MusicModule)

-- Runtime
while player do
	if not currentTrack then
		currentTrack = MusicModule.GetNextTrack():Clone()
		currentTrack.Parent = script
	end
	
	currentTrack:Play()
	currentTrack.Ended:Wait()
	
	currentTrack:Destroy()
	currentTrack = nil
end
