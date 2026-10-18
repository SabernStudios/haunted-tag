-- Services
local Players = game:GetService("Players")

-- Constants
local STAT_NAMES = {
	"Tags",
	"TimesTagged",
	"TimeSurvived",
	"TimeSpentInChase",
}

-- Current Round
local currentRound = nil

local StatService = {}

function StatService.SetCurrentRound(self: StatService, round)
	currentRound = round
end

function StatService.IncrementPlayerStat(self: StatService, player: Player, statName: string, amount: number)
	if not currentRound then
		return
	end
	
	if not player then
		return
	end

	if not amount then
		return
	end

	if not self:GetIsStatNameValid(statName) then
		return
	end

	currentRound.RoundStatTrackers[player.UserId][statName] += amount
end

function StatService.GetIsStatNameValid(self: StatService, statName: string)
	if not table.find(STAT_NAMES, statName) then
		return false
	end

	return true
end

function StatService.GetHighestAmount(self: StatService, category: string, exclusionList: {}?)
	if not currentRound then
		return
	end
	
	if not self:GetIsStatNameValid(category) then
		return
	end
	
	if exclusionList then
		local highestAmountPlayer = nil
		local highestAmount = 0
		
		for userId, stat in pairs(currentRound.RoundStatTrackers) do
			if table.find(exclusionList, Players:GetPlayerByUserId(userId)) then
				continue
			end
			
			if stat[category] > highestAmount then
				highestAmountPlayer = Players:GetPlayerByUserId(userId)
				highestAmount = stat[category]
			end
		end
		
		if highestAmountPlayer == nil then
			local allUsers = {}
			
			for userId, stat in pairs(currentRound.RoundStatTrackers) do
				table.insert(allUsers, {userId, stat})
			end
			
			for userId, stat in pairs(currentRound.RoundStatTrackers) do
				if stat[category] > highestAmount then
					highestAmountPlayer = Players:GetPlayerByUserId(userId)
					highestAmount = stat[category]
				end
			end
			
			if highestAmountPlayer == nil then
				highestAmountPlayer = Players:GetPlayerByUserId(allUsers[1][1])
				highestAmount = allUsers[1][2][category]
			end
		end
		
		return highestAmountPlayer, highestAmount
	else
		local highestAmountPlayer = nil
		local highestAmount = 0

		for userId, stat in pairs(currentRound.RoundStatTrackers) do
			if stat[category] > highestAmount then
				highestAmountPlayer = Players:GetPlayerByUserId(userId)
				highestAmount = stat[category]
			end
		end
		
		if highestAmountPlayer == nil then
			local allUsers = {}

			for userId, stat in pairs(currentRound.RoundStatTrackers) do
				table.insert(allUsers, {userId, stat})
			end
			
			highestAmountPlayer = Players:GetPlayerByUserId(allUsers[1][1])
			highestAmount = allUsers[1][2][category]
		end

		return highestAmountPlayer, highestAmount
	end
end

function StatService.GetCurrentRound(self: StatService)
	return currentRound
end

type StatService = typeof(StatService) & {
	
}

return StatService
