-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Constants
local validCategories = {
	"Playtime",
	"Powerup",
	"NoTags",
	"Currency",
	"Tags",
}

local difficultyOrder = {
	"Easy",
	"Medium",
	"Hard",
}

-- Variables

-- Definitions
local TaskDefinitions = require(ReplicatedStorage.Shared.Definitions.Tasks.TaskDefinitions)

-- Remotes
local taskEvent: RemoteEvent = ReplicatedStorage.Shared.Remotes.TaskEvent

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)

local TaskService = {}

function TaskService.Init(self: TaskService)

end

function TaskService.CreatePlayerTasks(self: TaskService, player: Player)
	local tasks = self:GenerateTasks()

	local character = CharacterService:GetCharacterFromPlayer(player)

	character.Task.DailyTasks = tasks
	
	taskEvent:FireClient(player, "DisplayTasks", {TASKS = character.Task.DailyTasks})
end

function TaskService.AddProgress(self: TaskService, player: Player, category: string, amount: number)
	local character = CharacterService:GetCharacterFromPlayer(player)
end

function TaskService.GenerateTasks(self: TaskService, oldTasks: {}?)
	local relativeCategoryWeights = {}
	
	if oldTasks then
		local oldTaskCategories = self:GetCategoriesInTaskList(oldTasks)

		for _, category in validCategories do
			local weight = 1

			if table.find(oldTaskCategories, category) then
				weight = 0.4
			end

			relativeCategoryWeights[category] = weight
		end
	else
		for _, category in validCategories do
			local weight = 1
			
			relativeCategoryWeights[category] = weight
		end
	end
	
	local taskList = {}
	
	-- First task is easy, second medium, third difficult
	
	for i = 1, 3 do
		local randomCategory = self:GetRandomCategory(relativeCategoryWeights)
		
		local task = self:GetRandomTask(randomCategory, difficultyOrder[i])
		
		table.insert(taskList, task)
	end
	
	return taskList
end

function TaskService.GetRandomCategory(self: TaskService, taskWeights)
	local totalWeight = 0
	for _, weight in taskWeights do
		totalWeight += weight
	end
	
	local randomWeight = math.random() * totalWeight
	local currentWeight = 0
	
	for category, weight in taskWeights do
		currentWeight += weight
		if randomWeight <= currentWeight then
			return category
		end
	end
	
	return "Playtime"
end

function TaskService.GetRandomTask(self: TaskService, category: string, difficulty: string)
	local tasks = self:GetTasksOfCategory(category)
	
	local validTasks = {}
	
	for _, task in tasks do
		local taskName = task[1]
		local taskData = task[2]
		if taskData.Difficulty == difficulty then
			table.insert(validTasks, {taskName, taskData})
		end
	end
	
	if #validTasks == 0 then
		validTasks = tasks
	end
	
	local task = validTasks[math.random(1, #validTasks)]
	
	return task
end

function TaskService.GetCategoriesInTaskList(self: TaskService, oldTasks)
	local categories = {}
	
	for _, task in oldTasks do
		table.insert(categories, task.Category)
	end
	
	return categories
end

function TaskService.GetTasksOfCategory(self: TaskService, category: string)
	local tasks = {}
	
	for taskName, task in pairs(TaskDefinitions) do
		if task.Category == category then
			table.insert(tasks, {taskName, task})
		end
	end
	
	return tasks
end

function TaskService.GetTasksOfDifficulty(self: TaskService, difficulty: string)
	local tasks = {}
	
	for _, task in TaskDefinitions do
		if task.Difficulty == difficulty then
			table.insert(tasks, task)
		end
	end
	
	return tasks
end

export type TaskService = typeof(TaskService) & {
	
}

return TaskService
