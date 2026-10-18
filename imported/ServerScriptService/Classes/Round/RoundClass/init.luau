local RoundClass = {}
RoundClass.__index = RoundClass

function RoundClass.new(): RoundClass
	local self = setmetatable({}, RoundClass)
	
	self.PlayerAddingEnded = false
	self.RoundPlayers = {}
	self.RoundStatTrackers = {}
	self.Map = nil
	self.Mode = nil
	
	return self
end

function RoundClass:AddPlayer(player: Player)
	table.insert(self.RoundPlayers, player)
end

function RoundClass:RemovePlayer(player: Player)
	table.remove(self.RoundPlayers, table.find(self.RoundPlayers, player))
end

function RoundClass:GetPlayers()
	return self.RoundPlayers
end

function RoundClass:Destroy()
	self.Map:Destroy()
	self.Mode:Destroy()
	
	for _, tracker in self.RoundStatTrackers do
		tracker:Destroy()
	end
	
	self = nil
end

export type RoundClass = typeof(RoundClass) & {
	
}

return RoundClass
