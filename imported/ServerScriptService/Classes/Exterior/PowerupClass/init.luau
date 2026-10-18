local PowerupClass = {}
PowerupClass.__index = PowerupClass

function PowerupClass.new(model: Model, originalModel: Model, name: string, powerupType: string, isAction: boolean): PowerupClass
	local self = setmetatable({}, PowerupClass)
	
	self.Model = model
	self.PowerupName = name
	self.PowerupType = powerupType
	self.OriginalModel = originalModel
	self.IsAction = isAction or false
	
	return self
end

function PowerupClass:Destroy()
	self.Model:Destroy()
	self = nil
end

type PowerupClass = typeof(PowerupClass) & {
	
}

return PowerupClass
