local RagdollControllerUtils = {}

-- Helper: convert Motor6D to BallSocketConstraint
function RagdollControllerUtils.Motor6DToSocket(motor)
	local p0, p1 = motor.Part0, motor.Part1
	if not p0 or not p1 then return end

	local a0 = Instance.new("Attachment")
	a0.CFrame = motor.C0
	a0.Name = motor.Name .. "_A0"
	a0.Parent = p0

	local a1 = Instance.new("Attachment")
	a1.CFrame = motor.C1
	a1.Name = motor.Name .. "_A1"
	a1.Parent = p1

	local socket = Instance.new("BallSocketConstraint")
	socket.Attachment0 = a0
	socket.Attachment1 = a1
	socket.LimitsEnabled = true
	socket.TwistLimitsEnabled = true
	socket.Parent = p0

	motor.Enabled = false -- disable Motor6D instead of destroying
end

-- Save original joints
function RagdollControllerUtils.SaveJoints(char)
	local newJoints = {}
	
	for _, obj in ipairs(char:GetDescendants()) do
		if obj:IsA("Motor6D") then
			newJoints[obj.Name] = {
				Part0 = obj.Part0,
				Part1 = obj.Part1,
				C0 = obj.C0,
				C1 = obj.C1,
				Motor = obj
			}
		end
	end
	
	return newJoints
end

return RagdollControllerUtils
