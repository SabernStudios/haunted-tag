local CameraServiceClient = {}

local player = game:GetService("Players").LocalPlayer

local CameraServiceUtils = require(script.CameraServiceUtils)

local camera = workspace.CurrentCamera

local cameraModes = script.CameraModes
local cameraSway = require(cameraModes.CameraSway)

local cameraType = require(cameraModes.CameraSway)

function CameraServiceClient.init(self: CameraServiceClient)
	cameraType:activate()
end

function CameraServiceClient.ReturnCameraCFrame(self: CameraServiceClient): CFrame
	return camera.CFrame
end

function CameraServiceClient.setCameraMode(self: CameraServiceClient, newCameraType: ModuleScript)
	cameraType:deactivate()
	cameraType = require(newCameraType)
	cameraType:activate()
end

function CameraServiceClient.TemporaryFOVBoost(self: CameraServiceClient, duration: number, boost: number)
	if boost <= 0 or boost >= 90 then
		warn("Boost must be greater than 0 and less than 90")
		return
	end
	
	local startFOV = camera.FieldOfView
	local endFOV = startFOV + boost
	
	local startTime = time()
	
	while time() - startTime < 0.25 do
		camera.FieldOfView = CameraServiceUtils.lerp(startFOV, endFOV, (time() - startTime) / 0.25)
		task.wait()
	end
	
	while time() - startTime < duration + 0.25 do
		camera.FieldOfView = CameraServiceUtils.lerp(endFOV, startFOV, (time() - startTime) / duration)
		task.wait()
	end
end

type CameraServiceClient = typeof (CameraServiceClient) & {
	
}

return CameraServiceClient
