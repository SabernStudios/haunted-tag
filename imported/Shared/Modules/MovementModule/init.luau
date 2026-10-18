local MovementModule = {}

local DashUtils = require(script.DashUtils)

function MovementModule.ReturnIntendedDashDirection(humanoid: Humanoid)
	return DashUtils.ReturnDashDirection(humanoid :: Humanoid)
end

return MovementModule
