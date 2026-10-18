local XPController = {}
XPController.__index = XPController

function XPController.new(): XPController
	local self = setmetatable({}, XPController)
	
	return self
end

type XPController = typeof(XPController) & {
	
}

return XPController
