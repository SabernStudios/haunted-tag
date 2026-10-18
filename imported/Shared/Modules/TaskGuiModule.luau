-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player
local player = game:GetService("Players").LocalPlayer

-- PlayerGui
local playerGui = player:WaitForChild("PlayerGui")

local taskGui = playerGui:WaitForChild("TaskGui")
local taskFrame = taskGui:WaitForChild("TaskFrame")

-- UI Presets
local taskPreset = ReplicatedStorage.Assets.UIPresets.Task.Task

local TaskGuiModule = {}

function TaskGuiModule.ClearTasks()
	for _, child in taskFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

function TaskGuiModule.AddTask(taskName: string, rewards: {}, layoutOrder: number?)
	local taskPresetClone = taskPreset:Clone()
	
	taskPresetClone.Name = taskName
	taskPresetClone.TaskText = taskName
	taskPresetClone.LayoutOrder = layoutOrder or 0
	
	taskPresetClone.Parent = taskFrame
	
	return taskPresetClone
end

return TaskGuiModule
