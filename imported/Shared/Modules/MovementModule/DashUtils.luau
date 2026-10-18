local DashUtils = {}

-- Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraServiceClient = require(ReplicatedStorage.Shared.Services.CameraServiceClient)

function DashUtils.ReturnDashDirection(humanoid: Humanoid): Vector3
	if humanoid.MoveDirection == Vector3.new(0, 0, 0) then
		return CameraServiceClient.ReturnCameraCFrame().LookVector
	end
	
	return humanoid.MoveDirection
end

return DashUtils
