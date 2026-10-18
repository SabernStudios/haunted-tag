local TimedStateController = {}
TimedStateController.__index = TimedStateController

local StateMachine = require(script.Parent.StateMachine)
type StateMachine = typeof(StateMachine)

function TimedStateController.new(stateMachine: StateMachine, inputController)
	local self = setmetatable({}, TimedStateController)
	
	self.State = stateMachine
	self.Input = inputController
	
	self.ActiveTokenMovement = nil
	self.ActiveTokenTag = nil
	self.ActiveTokenStatus = nil
	
	return self
end

function TimedStateController:ApplyOverride(stateName: string, duration: number, fallbackState: string?)
	local domain = self.State:ReturnDomain(stateName)

	if not domain then
		warn("[TIMED_STATE_CONTROLLER]: No domain found for the state: {stateName}")
		return
	end

	self.State:SetState(domain :: string, stateName :: string)

	task.delay(duration, function()
		if self.State:Is(stateName :: string) then
			if domain == "Movement" then
				self.State:SetState(domain :: string, fallbackState :: string or "Idle")
			elseif domain == "Combat" then
				self.State:SetState(domain :: string, fallbackState :: string or "None")
			elseif domain == "Status" then
				self.State:SetState(domain :: string, fallbackState :: string or "NoStatus")
			end
		end
	end)
end

function TimedStateController:Apply(stateName: string, duration: number, fallbackState: string?, functionCall: () -> ()?)
	local domain = self.State:ReturnDomain(stateName)
			
	if not domain then
		warn("[TIMED_STATE_CONTROLLER]: No domain found for the state: {stateName}")
		return
	end
	
	local token = tostring(time())
	
	if domain == "Movement" then
		self.ActiveTokenMovement = token
	elseif domain == "Tag" then
		self.ActiveTokenTag = token
	elseif domain == "Status" then
		self.ActiveTokenStatus = token
	end
	
	self.State:SetState(domain :: string, stateName :: string)
	
	task.delay(duration, function()
		if domain == "Movement" then
			if self.ActiveTokenMovement ~= token then return end
		elseif domain == "Tag" then
			if self.ActiveTokenTag ~= token then return end
		elseif domain == "Status" then
			if self.ActiveTokenStatus ~= token then return end
		end

		if self.State:Is(stateName :: string) then
			if domain == "Movement" then
				self.State:SetState(domain :: string, fallbackState :: string or "Idle")
			elseif domain == "Combat" then
				self.State:SetState(domain :: string, fallbackState :: string or "None")
			elseif domain == "Status" then
				self.State:SetState(domain :: string, fallbackState :: string or "NoStatus")
			end
		end
	end)
end

function TimedStateController:Cancel()
	self.ActiveToken = nil
end

return TimedStateController
