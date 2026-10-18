local CombatModule = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Definitions
local ActionDefinitions = ReplicatedStorage.Shared.Definitions.Actions

--function CombatModule.ReturnDefinitionFromAction(action: string): ModuleScript
--	local actionDef = ActionDefinitions[action.."Definition"]
	
--	if not actionDef then
--		warn("[COMBAT_MODULE]: No action definition found for the action: {action}")
--		return
--	end
	
--	return actionDef
--end

return CombatModule
