local CameraSway = {}

local CameraServiceUtils = require(script.Parent.Parent.CameraServiceUtils)

local renderStepTag = "CameraSway"

local camera = workspace.CurrentCamera

local SWAY_LIMIT = 3.5 -- try to set below 6 (in degrees)

local turn = 0

function CameraSway.activate(self: CameraSway)
	CameraServiceUtils:renderStep(renderStepTag, Enum.RenderPriority.Camera.Value, function(dt: number)
		CameraSway:sway(dt)
	end)
end

function CameraSway.sway(self: CameraSway, dt: number)
	local mouseDelta = CameraServiceUtils:returnMouseDelta()
	
	turn = CameraServiceUtils:lerp(turn, math.clamp(mouseDelta.X, -SWAY_LIMIT, SWAY_LIMIT), (SWAY_LIMIT * dt))
	
	camera.CFrame *= CFrame.Angles(0, 0, math.rad(turn))
end

function CameraSway.deactivate(self: CameraSway)
	CameraServiceUtils:unbindFromRenderStep(renderStepTag)
end

type CameraSway = typeof(CameraSway) & {
	
}

return CameraSway
