local ModeClass = {}
ModeClass.__index = ModeClass

function ModeClass.new(modeName: string, modeDescription: string, imageId: string, modeGhosts: number): ModeClass
	local self = setmetatable({}, ModeClass)

	self.ModeVoters = {}
	self.ModeName = modeName or "Placeholder"
	self.ModeDescription = modeDescription or "No description provided."
	self.ImageId = imageId
	
	self.NumberModeGhosts = modeGhosts or 1

	return self
end

function ModeClass:GetCharacteristics()
	return {ModeName = self.ModeName, ModeDescription = self.ModeDescription, ImageId = self.ImageId}
end

function ModeClass:Destroy()
	self = nil
end

type ModeClass = typeof(ModeClass) & {

}

return ModeClass
