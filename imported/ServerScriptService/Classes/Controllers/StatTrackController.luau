local StatTrackController = {}
StatTrackController.__index = StatTrackController

function StatTrackController.new(): StatTrackController
	local self = setmetatable({}, StatTrackController)
	
	self.PowerupsUsed = 0
	self.Tags = 0
	self.TimesTagged = 0
	self.TimeSpentInChase = 0
	self.TimeSurvived = 0
	self.TimePlayed = 0
	
	return self
end

type StatTrackController = typeof(StatTrackController) & {
	
}

return StatTrackController
