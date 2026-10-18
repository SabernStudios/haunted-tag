-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Remotes
local ItemEvent = ReplicatedStorage.Shared.Remotes.ItemEvent

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)

local CurrencyController = {}
CurrencyController.__index = CurrencyController

function CurrencyController.new(baseCharacter, data: {}?): CurrencyController
	local self = setmetatable({}, CurrencyController)
	
	self.Coins = 25000
	
	if data then
		self.Coins = data.COINS
	end
	
	-- After having all data loaded, fire the client to update the owned currency UI
	ItemEvent:FireClient(Players:GetPlayerFromCharacter(baseCharacter.Character), "UpdateCurrency", {COINS = self.Coins})
	
	return self
end

function CurrencyController:TryAddCoins(amount: number)
	self.Coins += amount
end

export type CurrencyController = typeof(CurrencyController) & {
	
}

return CurrencyController
