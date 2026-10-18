-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ANTI_CHEAT_DISTANCE = 20

local GHOST_SPEED_FACTOR = 1.25

local taggers = {}

-- Custom Services
local Services = SSS.Services
local CharacterService = require(Services.CharacterService)
local StatService = require(Services.StatService)

local TagService = {}

function TagService:UpdateTaggers()
	for _, tagger in taggers do
		local taggerCharacter = tagger.Character or tagger.CharacterAdded:Wait()
		
		local taggerBaseCharacter = CharacterService:GetCharacterFromCharacter(taggerCharacter)
		taggerBaseCharacter.Movement.SprintSpeed = taggerBaseCharacter.Movement.BaseSprintSpeed*GHOST_SPEED_FACTOR
		taggerBaseCharacter.Movement.CorrectedSprintSpeed = taggerBaseCharacter.Movement.BaseSprintSpeed*GHOST_SPEED_FACTOR
		
		if taggerBaseCharacter.State:GetState("Movement") == "Sprint" then
			taggerCharacter.Humanoid.WalkSpeed = taggerBaseCharacter.Movement.BaseSprintSpeed*GHOST_SPEED_FACTOR
		end
		
		for _, item in taggerCharacter:GetDescendants() do
			if item:IsA("BasePart") and (item.Name ~= "HumanoidRootPart" and item.Name ~= "Hurtbox") then
				item.Transparency = 0.5
			end
		end
		
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.5
		highlight.Parent = taggerCharacter
	end
	
	for _, player in Players:GetPlayers() do
		if not table.find(taggers, player) then
			local playerCharacter = player.Character or player.CharacterAdded:Wait()
			local playerBaseCharacter = CharacterService:GetCharacterFromCharacter(playerCharacter)
			playerBaseCharacter.Movement.SprintSpeed = playerBaseCharacter.Movement.CorrectedSprintSpeed
			playerBaseCharacter.Movement.CorrectedSprintSpeed = playerBaseCharacter.Movement.BaseSprintSpeed
			
			if playerBaseCharacter.State:GetState("Movement") == "Sprint" then
				playerCharacter.Humanoid.WalkSpeed = playerBaseCharacter.Movement.CorrectedSprintSpeed
			end
		
			for _, item in playerCharacter:GetDescendants() do
				if item:IsA("BasePart") and (item.Name ~= "HumanoidRootPart" and item.Name ~= "Hurtbox") then
					item.Transparency = 0
				end
			end
			
			if playerCharacter:FindFirstChild("Highlight") then
				playerCharacter:FindFirstChild("Highlight"):Destroy()
			end
		end
	end
end

--@ Precondition: Previous taggers should already be removed
function TagService:SelectRoundTaggers(taggerAmount: number, taggerPool: {})
	-- Sanity Checks
	if taggerAmount > #taggerPool then
		return
	end
	
	-- Select random players
	local candidates = table.clone(taggerPool)
	
	for i = 1, taggerAmount do
		local index = math.random(1, #candidates)
		local candidate = candidates[index]
		
		table.insert(taggers, candidate)
		table.remove(candidates, index)
	end
	
	TagService:UpdateTaggers()
	
	-- Return taggers
	return taggers
end

function TagService:TagPlayer(tagger: Player, target: Player)
	-- Variable Instatiation
	local taggerCharacter = tagger.Character or tagger.CharacterAdded:Wait()
	local targetCharacter = target.Character or target.CharacterAdded:Wait()
	
	-- Check if the target has already been tagged
	if taggers[target] then
		return
	end
	
	-- Check distance
	if (taggerCharacter.PrimaryPart.Position - targetCharacter.PrimaryPart.Position).Magnitude > ANTI_CHEAT_DISTANCE then
		return
	end
	
	-- Tag the player
	local taggerIndex = table.find(taggers, tagger)
	table.remove(taggers, taggerIndex)
	table.insert(taggers, target)
	
	TagService:UpdateTaggers()
	
	-- Update stats
	StatService:IncrementPlayerStat(tagger, "Tags", 1)
	StatService:IncrementPlayerStat(target, "TimesTagged", 1)
	
	---- Notify the players
	--ReplicatedStorage.Events.Tagged:FireClient(tagger, target)
	--ReplicatedStorage.Events.Tagged:FireClient(target, tagger)
end

function TagService:RemoveTagger(player: Player)
	table.remove(taggers, table.find(taggers, player))
end

function TagService:RemoveAllTaggers(player: Player)
	taggers = {}
	self:UpdateTaggers()
end

function TagService:GetTaggers(): {}
	return taggers
end

function TagService:GetIsTagger(player: Player): boolean
	return table.find(taggers, player) ~= nil
end

type TagService = typeof(TagService) & {
	
}

return TagService
