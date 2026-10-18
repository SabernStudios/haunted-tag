local PathfindingModule = {}

local PFS = game:GetService("PathfindingService")

function PathfindingModule.CalculatePath(startPosition: Vector3, endPosition: Vector3, agentParams: {})
	if not agentParams then
		agentParams = {}
	end

	local path = PFS:CreatePath(
		agentParams
	)
	path:ComputeAsync(startPosition, endPosition)

	return path
end

function PathfindingModule.FindMinimum(array: {})
	if #array == 0 then return end

	local currentMin = array[1]

	for index, value in array do
		if value[2] > currentMin[2] then
			currentMin = value
		end
	end

	return currentMin
end

function PathfindingModule.CalculateDistance(a: Vector3, b: Vector3)
	return (a - b).Magnitude
end

function PathfindingModule.CalculateRay(startPosition: Vector3, direction: Vector3, params: RaycastParams)
	local ray = workspace:Raycast(startPosition, direction, params)

	return ray
end

return PathfindingModule
