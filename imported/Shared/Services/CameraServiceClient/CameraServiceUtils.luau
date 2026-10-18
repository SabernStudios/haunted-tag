local CameraServiceUtils = {}

local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local currentCamera = workspace.CurrentCamera

function CameraServiceUtils.renderStep(tag: string, priority: number, func: (dt: number) -> ())
	RS:BindToRenderStep(tag, priority, func)
end

function CameraServiceUtils.unbindFromRenderStep(tag: string)
	RS:UnbindFromRenderStep(tag)
end

function CameraServiceUtils.returnMouseDelta()
	return UIS:GetMouseDelta()
end

function CameraServiceUtils.lerp(a: number, b: number, t: number)
	return a + (b - a) * t
end

function CameraServiceUtils.updateCameraCFrame(newCFrame: CFrame)
	currentCamera.CFrame = newCFrame
end

return CameraServiceUtils
