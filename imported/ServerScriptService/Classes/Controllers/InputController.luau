local InputController = {}
InputController.__index = InputController

function InputController.new(): InputController
	local self = setmetatable({}, InputController)
	
	self.HeldKeys = {
		-- Just putting placeholders for important keys I might want to check
		LeftShift = false,
		W = false,
		A = false,
		S = false,
		D = false,
	}
	
	return self
end

function InputController:ProcessInput(inputState: Enum.UserInputState, enum: Enum)
	if not inputState or not enum then return end
	
	if inputState == Enum.UserInputState.Begin then
		self.HeldKeys[enum.Name] = true
	elseif inputState == Enum.UserInputState.End then
		self.HeldKeys[enum.Name] = false
	end
end

function InputController:GetIsHoldingKeys(keys: {}): boolean
	local isHolding = true
	
	for _, key in keys do
		if not self.HeldKeys[key.Name] then
			isHolding = false
		end
	end
	
	return isHolding
end

type InputController = typeof(InputController) & {
	
}

return InputController
