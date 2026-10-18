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

function ClientTaskService.DisplayTasks(self: ClientTaskService, taskList: {})
	if not taskList then
		return
	end
	
	for i = 1, 3 do
		local taskItem = taskList[i]
		
		local taskName = taskItem[1]
		local taskData = taskItem[2]
		
		TaskGuiModule.DisplayTask(taskName, taskData.Rewards, i)
	end
end

function ClientTaskService.CompleteTask(self: ClientTaskService, taskItem: {})
	if not taskItem then
		return
	end
end

type ClientTaskService = typeof(ClientTaskService) & {
	
}

return ClientTaskService
