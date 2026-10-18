local RoundStatsClass = {}
RoundStatsClass.__index = RoundStatsClass

function RoundStatsClass.new(player: Player): RoundStatsClass
	local self = setmetatable({}, RoundStatsClass)
	
	self.Player = player
	
	self.PowerupsUsed = 3
	self.Tags = 10
	self.TimesTagged = 2
	self.TimeSurvived = 150
	self.TimeSpentInChase = 80
	
	return self
end

function RoundStatsClass:Destroy()
	self = nil
end

export type RoundStatsClass = typeof(RoundStatsClass) & {
	
}

return RoundStatsClass
