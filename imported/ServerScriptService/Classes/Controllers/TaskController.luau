local TaskController = {}
TaskController.__index = TaskController

function TaskController.new(baseCharacter, data: {}?): TaskController
	local self = setmetatable({}, {__index = TaskController})
	
	self.DailyTasks = {
		
	}
	
	if data then
		self.DailyTasks = data.DAILY_TASKS
	else
		-- After having all data loaded, fire the client to update the owned character UI
		
	end
	
	return self
end

type TaskController = typeof(TaskController) & {
	
}

return TaskController
