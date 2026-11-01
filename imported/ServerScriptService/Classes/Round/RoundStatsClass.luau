local RoundStatsClass = {}
RoundStatsClass.__index = RoundStatsClass

function RoundStatsClass.new(player: Player): RoundStatsClass
	local self = setmetatable({}, RoundStatsClass)
	
	self.Player = player
	
	self.PowerupsUsed = 0
	self.Tags = 0
	self.TimesTagged = 0
	self.TimeSurvived = 0
	self.TimeSpentInChase = 0
	
	return self
end

function RoundStatsClass:Destroy()
	self = nil
end

export type RoundStatsClass = typeof(RoundStatsClass) & {
	
}

return RoundStatsClass
