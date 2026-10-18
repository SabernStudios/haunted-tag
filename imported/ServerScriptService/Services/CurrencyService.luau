-- Constants

local KEY_DATA = {
	["Tags"] = {"Tags", 10},
	["TimeSpentInChase"] = {"Time In Chase", 1},
	["TimeSurvived"] = {"Time Survived", 0.5},
	["PowerupsUsed"] = {"Powerups Used", 3}
}

local CurrencyService = {}

function CurrencyService.CalculateCoinTotal(self: CurrencyService, roundStatsObject)
	local masterList = {}
	local total = 0
	
	for key, value in pairs(roundStatsObject) do
		if key == "Player" then
			continue
		end
		
		local currencyArray = KEY_DATA[key]
		
		if not currencyArray then
			continue
		end
		
		local displayName = currencyArray[1]
		local multiplier = currencyArray[2]
		local baseValue = roundStatsObject[key]
		
		table.insert(masterList, {displayName, multiplier, baseValue})
		
		total += roundStatsObject[key] * currencyArray[2]
	end
	
	return masterList, total
end

type CurrencyService = typeof(CurrencyService) & {
	
}

return CurrencyService
