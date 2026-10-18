local StateMachine = {}

StateMachine.__index = StateMachine

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local validMovementStates = {
	"Idle",
	"Sprint",
	"StopSprint",
	"Slide",
}

local validTagStates = {
	"None",
	"Tagging",
}

local validStatusStates = {
	"NoStatus",
	"Invincible",
	"Stunned",
	"Ragdolled",
}

-- Packages
local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.Signal)

function StateMachine.new(): StateMachine
	local self = setmetatable({}, StateMachine)
	
	self.states = {
		Movement = "Idle",
		Tag = "None",
		Status = "NoStatus",
	}
	
	-- TODO: Rules section of state machine
	-- Key: [Action = {can = {Movement stuff, Combat stuff, Status stuff}}]
	-- Make sure each state has a unique string name
	self.rules = {
		Movement = {
			Idle = {can = {"Sprint", "StopSprint", "Attack", "Block", "Stunned", "Ragdolled"}},
			Sprint = {can = {"Idle", "Slide", "StopSprint", "Attack", "Block", "Stunned", "Ragdolled"}},
			StopSprint = {can = {"Idle", "Sprint", "Slide", "Tagging"}},
			Slide = {can = {"Idle", "Sprint"}},
		},
		Tag = {
			None = {can = {"Tagging"}},
			Tagging = {can = {"None"}},
		},
		Status = {
			NoStatus = {can = {"Invincible", "Stunned", "Ragdolled"}},
			Invincible = {can = {"NoStatus"}},
			Stunned = {can = {"NoStatus", "Invincible", "Ragdolled"}},
			Ragdolled = {can = {"NoStatus", "Invincible", "Stunned"}}
		}
	}
	
	-- Signals
	self.OnStateChange = Signal.new()
	self.OnActionChange = Signal.new()
	
	return self
end

function StateMachine:ReturnDomain(state: string): string
	if table.find(validMovementStates, state) then
		return "Movement"
	elseif table.find(validTagStates, state) then
		return "Tag"
	elseif table.find(validStatusStates, state) then
		return "Status"
	else
		warn("Error: State not found")
		return nil
	end
end

function StateMachine:Is(state: string)
	local domain = self:ReturnDomain(state)
	
	if not domain then
		warn("[STATE_MACHINE]: No domain found for the state: {state}")
		return false
	end
	
	if self.states[domain] == state then
		return true
	end
	
	return false
end

function StateMachine:BasicStateMachineValidation(state: string): boolean
	local domain = self:ReturnDomain(state)
	
	if not domain then
		warn("[STATE_MACHINE]: No domain found for the action: {action}")
		return false
	end
	
	if not self:CanTransition(domain, state) then
		return false
	end
	
	if self:GetState("Status") == "Stunned" and not((state == "Stunned") or (state == "Ragdolled")) then
		return false
	end
	
	if self:GetState("Status") == "Ragdolled" and not((state == "Stunned") or (state == "Ragdolled")) then
		return false
	end
	
	return true
end

function StateMachine:ReturnStates(): {}
	return self.states
end

function StateMachine:AddRule(domain: string, state: string, func: () -> ())
	
end

function StateMachine:GetStates(): {}
	return self.states
end

function StateMachine:GetState(domain: string): string
	return self.states[domain]
end

function StateMachine:CanTransition(domain: string, state: string): boolean
	if not self.rules[domain][self.states[domain]] then warn("Error: No state/domain found"); return false end
	
	local canSet = self.rules[domain][self.states[domain]].can
	
	for _, potentialState in canSet do
		if potentialState == state then
			return true
		end
	end
	
	return false
end

function StateMachine:SetState(domain: string, state: string): ()
	if self.states[domain] == nil then warn("Error: State not found") return end
	
	self.states[domain] = state
end

export type StateMachine = typeof(StateMachine) & {
	
}

return StateMachine
