-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local TaskGuiModule = require(ReplicatedStorage.Shared.Modules.TaskGuiModule)

local ClientTaskService = {}

function ClientTaskService.Init(self: ClientTaskService)
	
end

function ClientTaskService.OnEvent(self: ClientTaskService, tag: string, payload: {})
	if tag == "DisplayTasks" then
		self:DisplayTasks(payload.TASKS)
	elseif tag == "CompleteTask" then
		self:CompleteTask(payload.TASK)
	end
end

function ClientTaskService.DisplayTasks(taskList: {})
	if not taskList then
		return
	end
	
	for i = 1, 3 do
		local task = taskList[i]
		
		local taskName = task[1]
		local taskData = task[2]
		
		TaskGuiModule.DisplayTask(taskName, taskData.Rewards, i)
	end
end

function ClientTaskService.CompleteTask(task: {})
	if not task then
		return
	end
end

type ClientTaskService = typeof(ClientTaskService) & {
	
}

return ClientTaskService
