-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Lobby
local lobby = workspace.Lobby
local lobbySpawnpointFolder = lobby.Spawnpoints
local lobbySpawnpoints = lobbySpawnpointFolder:GetChildren()

-- Map
-- TODO: Change it so that it checks the map with the current round's map, not the workspace's map
local map = nil
local mapSpawnpoints = nil

-- Classes
local Classes = SSS.Classes

local RoundClass = require(Classes.Round.RoundClass)
type RoundClass = RoundClass.RoundClass

local RoundStatsClass = require(Classes.Round.RoundStatsClass)
type RoundStatsClass = RoundStatsClass.RoundStatsClass

-- Map Classes
local MapClass = require(Classes.Round.MapClass)
local MapClasses = Classes.Round.MapClass
local HauntedHouseClass = require(MapClasses.HauntedHouseClass)

-- Mode Classes
local ModeClasses = Classes.Round.ModeClass
local ClassicClass = require(ModeClasses.ClassicClass)

local allMaps = {
	HauntedHouseClass,
	-- TODO: Add more maps
}

local allModes = {
	ClassicClass,
	-- TODO: Add more modes
}

-- Mode Classes
-- TODO: Make at least one mode class
local ModeClass = require(Classes.Round.ModeClass)

-- Constants
local MAP_SELECTION_TIME = 15
local MAP_SELECTION_TWEEN_TIME = 0.6
local MAP_SELECTED_READ_TIME = 2
local MODE_SELECTION_TIME = 15
local MODE_SELECTION_TWEEN_TIME = 0.6
local MODE_SELECTED_READ_TIME = 2

local LOAD_MAP_READ_TIME = 3
local ROUND_COUNTDOWN_TIME = 10
local TELEPORT_TIME = 2
local GHOST_SELECTION_TIME = 5
local GHOST_SELECTION_REACTION_TIME = 3
local COUNTDOWN_TIME = 4
local ROUND_TIME = 300
local ROUND_OVER_TIME = 3
local PODIUM_CAMERA_TWEEN_TIME = 1
local PODIUM_CAMERA_TWEEN_INFO = TweenInfo.new(PODIUM_CAMERA_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PODIUM_READ_TIME = 2
local END_SCREEN_TIME = 8
local PER_FRAME_END_SCREEN_TIME = 1.4
local PER_FRAME_END_SCREEN_WAIT = 0.4
local END_SCREEN_FRAME_TWEEN_INFO = TweenInfo.new(PER_FRAME_END_SCREEN_TIME-PER_FRAME_END_SCREEN_WAIT, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local COIN_COLLECTION_TIME = 2
local INTERMISSION_TIME = 60

local TELEPORT_TWEEN_INFO = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local COUNTDOWN_TWEEN_INFO = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local SPAWN_CFRAME_OFFSET = CFrame.new(0, 5, 0)

-- Variables
local currentRound: RoundClass = nil

local mapSelection = {nil, nil, nil}
local modeSelection = {nil, nil, nil}

-- Remotes
local remotes = ReplicatedStorage.Shared.Remotes

local roundEvent = remotes.RoundEvent

-- Custom Services
local CharacterService = require(SSS.Services.CharacterService)
local ChaseService = require(SSS.Services.ChaseService)
local CurrencyService = require(SSS.Services.CurrencyService)
local PodiumService = require(SSS.Services.PodiumService)
local PowerupService = require(SSS.Services.PowerupService)
local StatService = require(SSS.Services.StatService)
local TagService = require(SSS.Services.TagService)

local RoundService = {}

function RoundService.Init(self: RoundService)
	
end

function RoundService.OnEvent(self: RoundService, player: Player, eventName: string, payload: {})
	if not eventName then
		return
	end
	
	if eventName == "PlayerSelectedMap" then
		self:OnPlayerSelectedMap(player, eventName, payload)
	elseif eventName == "PlayerSelectedMode" then
		self:OnPlayerSelectedMode(player, eventName, payload)
	end
end

function RoundService.OnPlayerSelectedMap(self: RoundService, player: Player, eventName: string, payload: {})
	if not payload then
		return
	end
	
	local mapIndex = table.find(mapSelection, self:GetMapFromName(payload.MapName))
	
	if not player then
		return
	end
	
	if not mapIndex then
		return
	end
	
	if payload.MapName == "Placeholder" then
		return
	end
	
	if not self:GetIsPlayerValid(player) then
		return
	end
	
	if not self:GetIsMapIndexValid(mapIndex) then
		return
	end
	
	if self:GetIfPlayerVotedOnMap(player) then
		self:RemovePlayerMapVote(player)
	end
	
	self:AddPlayerMapVote(player, mapIndex)
end

function RoundService.OnPlayerSelectedMode(self: RoundService, player: Player, eventName: string, payload: {})
	if not payload then
		return
	end

	local modeIndex = table.find(modeSelection, self:GetModeFromName(payload.ModeName))

	if not player then
		return
	end

	if not modeIndex then
		return
	end

	if payload.ModeName == "Placeholder" then
		return
	end

	if not self:GetIsPlayerValid(player) then
		return
	end

	if not self:GetIsModeIndexValid(modeIndex) then
		return
	end

	if self:GetIfPlayerVotedOnMode(player) then
		self:RemovePlayerModeVote(player)
	end

	self:AddPlayerModeVote(player, modeIndex)
end

-- Preconditions: All valid players should be in the lobby and the round should be out of intermission

function RoundService.StartRound(self: RoundService)
	if currentRound ~= nil then
		currentRound:Destroy()
	end
	
	currentRound = RoundClass.new()
	
	for _, player in Players:GetChildren() do
		if not self:GetIsPlayerValid(player) then
			continue
		end
		
		currentRound:AddPlayer(player)
	end
	
	self:AddRoundStatTrackers()
	
	self:StartMapSelection()
	
	task.wait(MAP_SELECTION_TIME + MAP_SELECTION_TWEEN_TIME)
	
	self:StopMapSelection()
	
	task.wait(MAP_SELECTION_TWEEN_TIME + MAP_SELECTED_READ_TIME)
	
	self:StartModeSelection()
	
	task.wait(MODE_SELECTION_TIME + MODE_SELECTION_TWEEN_TIME)
	
	self:StopModeSelection()
	
	task.wait(MODE_SELECTION_TWEEN_TIME + MODE_SELECTED_READ_TIME)
	
	self:LoadMap()
	
	currentRound.PlayerAddingEnded = true
	
	map = currentRound.Map.MapInstance
	mapSpawnpointFolder = map.Spawnpoints
	mapSpawnpoints = map.Spawnpoints:GetChildren()

	PowerupService:Init(map.PowerupSpawns)
	
	task.wait(LOAD_MAP_READ_TIME)
	
	for _, player in currentRound:GetPlayers() do
		roundEvent:FireClient(player, "RoundStartingSoon", {EndTime = workspace:GetServerTimeNow() + ROUND_COUNTDOWN_TIME})
	end
	
	task.wait(ROUND_COUNTDOWN_TIME)
	
	self:SpawnValidPlayersInRound()
	
	self:SelectGhosts() -- Has built-in wait time
	
	task.wait(GHOST_SELECTION_REACTION_TIME)
	
	self:StartCountdown()
	
	task.wait(COUNTDOWN_TIME)
	
	self:StartRoundTimer()
	
	ChaseService:Activate()
	
	task.wait(ROUND_TIME)
	
	self:RoundOver()
	
	task.wait(ROUND_OVER_TIME)
	
	self:StartPodiumSequence()
	
	task.wait(PODIUM_READ_TIME)
	
	self:ShowEndScreen()
	
	task.wait(END_SCREEN_TIME + COIN_COLLECTION_TIME + 3.5)
	
	self:HideEndScreen()
	
	PodiumService:DeletePodium()
	
	self:SpawnValidPlayersInLobby()
	
	self:EndRound()
	
	self:StartIntermission()
	
	task.wait(INTERMISSION_TIME)
	
	self:StartRound()
end

function RoundService.EndRound(self: RoundService)
	for _, player in currentRound:GetPlayers() do
		roundEvent:FireClient(player, "RoundEnded", {}) -- Later, have it send through data on each player to display leaderboard for the round
	end
	
	currentRound:Destroy()
	
	map:Destroy()
	
	map = nil
	mapSpawnpointFolder = nil
	mapSpawnpoints = nil
	
	TagService:RemoveAllTaggers()
	
	ChaseService:Deactivate()
end

function RoundService.AddRoundStatTrackers(self: RoundService)
	for _, player in currentRound:GetPlayers() do
		local roundStats = RoundStatsClass.new(player)
		currentRound.RoundStatTrackers[player.UserId] = roundStats
	end
	
	StatService:SetCurrentRound(currentRound)
end

function RoundService.SelectRandomMaps(self: RoundService)
	local candidates = {}
	
	for _, map in allMaps do
		table.insert(candidates, map)
	end
	
	for i = 1, 3 do
		if #candidates == 0 then
			mapSelection[i] = MapClass.new("Placeholder", "Placeholder", nil, "")
			continue
		end
		
		local index = math.random(1, #candidates)
		mapSelection[i] = candidates[index].new()
		table.remove(candidates, math.random(1, #candidates))
	end
end

function RoundService.SelectRandomModes(self: RoundService)
	local candidates = {}

	for _, mode in allModes do
		table.insert(candidates, mode)
	end

	for i = 1, 3 do
		if #candidates == 0 then
			modeSelection[i] = ModeClass.new("Placeholder", "Placeholder", "")
			continue
		end

		local index = math.random(1, #candidates)
		modeSelection[i] = candidates[index].new()
		table.remove(candidates, math.random(1, #candidates))
	end
end

function RoundService.StartMapSelection(self: RoundService)
	local validPlayers = currentRound:GetPlayers()
	
	self:SelectRandomMaps()
	
	local lobotomizedMapClasses = {}
	
	for i = 1, 3 do
		table.insert(lobotomizedMapClasses, mapSelection[i]:GetCharacteristics())
	end
	
	for _, player in validPlayers do
		roundEvent:FireClient(player, "MapSelectionStarted", {EndTime = workspace:GetServerTimeNow() + MAP_SELECTION_TIME + MAP_SELECTION_TWEEN_TIME, SelectionTweenTime = MAP_SELECTION_TWEEN_TIME, MapSelection = lobotomizedMapClasses})
	end
end

function RoundService.StopMapSelection(self: RoundService)
	currentRound.Map = self:GetHighestVotedMap()
	
	for _, player in currentRound:GetPlayers() do
		roundEvent:FireClient(player, "MapSelectionEnded", {MapName = currentRound.Map.MapName, SelectionTweenTime = MAP_SELECTION_TWEEN_TIME})
	end
end

function RoundService.StartModeSelection(self: RoundService)
	local validPlayers = currentRound:GetPlayers()

	self:SelectRandomModes()

	local lobotomizedModeClasses = {}

	for i = 1, 3 do
		table.insert(lobotomizedModeClasses, modeSelection[i]:GetCharacteristics())
	end

	for _, player in validPlayers do
		roundEvent:FireClient(player, "ModeSelectionStarted", {EndTime = workspace:GetServerTimeNow() + MODE_SELECTION_TIME + MODE_SELECTION_TWEEN_TIME, SelectionTweenTime = MODE_SELECTION_TWEEN_TIME, ModeSelection = lobotomizedModeClasses})
	end
end

function RoundService.StopModeSelection(self: RoundService)
	currentRound.Mode = self:GetHighestVotedMode()

	for _, player in currentRound:GetPlayers() do
		roundEvent:FireClient(player, "ModeSelectionEnded", {ModeName = currentRound.Mode.ModeName, SelectionTweenTime = MODE_SELECTION_TWEEN_TIME})
	end
end

function RoundService.LoadMap(self: RoundService)
	local map = currentRound.Map.MapFolder:Clone()
	
	map.Parent = workspace
	
	currentRound.Map.MapInstance = map
	
	for _, player in currentRound:GetPlayers() do
		roundEvent:FireClient(player, "ServerLoadingMap", {MapName = currentRound.Map.MapName})
	end
end

function RoundService.SelectGhosts(self: RoundService)
	local validPlayers = currentRound:GetPlayers()
	
	for _, player in validPlayers do
		roundEvent:FireClient(player, "ServerSelectingGhosts", {EndTime = workspace:GetServerTimeNow() + GHOST_SELECTION_TIME})
	end
	
	task.wait(GHOST_SELECTION_TIME)
	
	TagService:SelectRoundTaggers(currentRound.Mode.NumberModeGhosts, validPlayers)
end

function RoundService.StartCountdown(self: RoundService)
	for _, player in currentRound:GetPlayers() do
		roundEvent:FireClient(player, "ServerStartingRoundCountdown", {TweenInfo = COUNTDOWN_TWEEN_INFO})
	end
end

function RoundService.StartRoundTimer(self: RoundService)
	for _, player in currentRound:GetPlayers() do
		roundEvent:FireClient(player, "ServerStartingRound", {EndTime = workspace:GetServerTimeNow() + ROUND_TIME})
	end
end

function RoundService.StartIntermission(self: RoundService)
	for _, player in currentRound:GetPlayers() do
		roundEvent:FireClient(player, "ServerStartingIntermission", {EndTime = workspace:GetServerTimeNow() + INTERMISSION_TIME})
	end
end

function RoundService.AddPlayerMapVote(self: RoundService, player: Player, mapIndex: number)
	if not player then
		return
	end
	
	local map = mapSelection[mapIndex]
	
	if not map then
		return
	end
	
	table.insert(map.MapVoters, player)
	
	for _, plr in currentRound:GetPlayers() do
		roundEvent:FireClient(plr, "PlayerSelectedMap", {Player = player, MapName = map.MapName})
	end
end

function RoundService.RemovePlayerMapVote(self: RoundService, player: Player)
	local foundMap = nil
	
	for _, map in mapSelection do
		if table.find(map.MapVoters, player) then
			table.remove(map.MapVoters, table.find(map.MapVoters, player))
			foundMap = map
			break
		end
	end
	
	if foundMap then
		for _, plr in currentRound:GetPlayers() do
			roundEvent:FireClient(plr, "PlayerUnselectedMap", {Player = player, MapName = foundMap.MapName})
		end
	end
end

function RoundService.AddPlayerModeVote(self: RoundService, player: Player, modeIndex: number)
	if not player then
		return
	end

	local mode = modeSelection[modeIndex]

	if not mode then
		return
	end

	table.insert(mode.ModeVoters, player)

	for _, plr in self:GetValidPlayers() do
		roundEvent:FireClient(plr, "PlayerSelectedMode", {Player = player, ModeName = mode.ModeName})
	end
end

function RoundService.RemovePlayerModeVote(self: RoundService, player: Player)
	local foundMode = nil

	for _, mode in modeSelection do
		if table.find(mode.ModeVoters, player) then
			table.remove(mode.ModeVoters, table.find(mode.ModeVoters, player))
			foundMode = mode
			break
		end
	end

	if foundMode then
		for _, plr in self:GetValidPlayers() do
			roundEvent:FireClient(plr, "PlayerUnselectedMode", {Player = player, ModeName = foundMode.ModeName})
		end
	end
end

function RoundService.RoundOver(self: RoundService)
	for _, player in currentRound:GetPlayers() do
		roundEvent:FireClient(player, "ServerRoundOver", {EndTime = workspace:GetServerTimeNow() + ROUND_OVER_TIME})
	end
end

function RoundService.StartPodiumSequence(self: RoundService)
	PodiumService:SetCurrentMap(map)
	
	PodiumService:SetPodium()

	PodiumService:AddPodium()
	
	for _, player in currentRound:GetPlayers() do
		roundEvent:FireClient(player, "PodiumCameraTween", {EndTime = workspace:GetServerTimeNow() + PODIUM_CAMERA_TWEEN_TIME, TweenInfo = PODIUM_CAMERA_TWEEN_INFO, CFrame = PodiumService:GetPodiumCameraPart().CFrame})
	end
	
	PodiumService:AddMysteries()

	PodiumService:RevealPlayers()
end

function RoundService.ShowEndScreen(self: RoundService)
	for _, player in currentRound:GetPlayers() do
		local userId = player.UserId
		
		local characterObject = CharacterService:GetCharacterFromPlayer(player)
		
		local masterList, total = CurrencyService:CalculateCoinTotal(currentRound.RoundStatTrackers[userId])
		
		characterObject.Currency:TryAddCoins(total)
		
		roundEvent:FireClient(player, "ShowEndScreen", {MASTER_LIST = masterList, TOTAL = total, END_SCREEN_FRAME_TWEEN_INFO = END_SCREEN_FRAME_TWEEN_INFO, PER_FRAME_END_SCREEN_TIME = PER_FRAME_END_SCREEN_TIME, COIN_COLLECTION_TIME = COIN_COLLECTION_TIME})
	end
end

function RoundService.HideEndScreen(self: RoundService)
	for _, player in currentRound:GetPlayers() do
		roundEvent:FireClient(player, "HideEndScreen", {})
	end
end

function RoundService.GetIsPlayerValid(self: RoundService, player: Player)
	-- TODO: Check if player is valid to play round
	if not currentRound then
		return true
	end
	
	if currentRound.PlayerAddedEnding == true then
		if not table.find(currentRound:GetPlayers(), player) then
			return false
		end
	end
	
	return true
end

function RoundService.GetValidPlayers(self: RoundService)
	local validPlayers = {}
	
	for _, player in Players:GetChildren() do
		if self:GetIsPlayerValid(player) then
			table.insert(validPlayers, player)
		end
	end
	
	return validPlayers
end

function RoundService.SpawnPlayerInLobby(self: RoundService, player: Player)
	if not player then
		return
	end
	
	local character = player.Character or player.CharacterAdded:Wait()
	
	if not character then
		return
	end
	
	local spawnpoints = lobbySpawnpoints
	local spawnpoint = spawnpoints[math.random(1, #spawnpoints)]
	
	character:PivotTo(spawnpoint.CFrame * SPAWN_CFRAME_OFFSET)
end

function RoundService.SpawnValidPlayersInLobby(self: RoundService)
	local validPlayers = currentRound:GetPlayers()

	for _, player in validPlayers do
		task.spawn(function()
			roundEvent:FireClient(player, "Teleporting", {TweenInfo = TELEPORT_TWEEN_INFO})
			task.wait(TELEPORT_TIME)
			self:SpawnPlayerInLobby(player)
		end)
	end

	task.wait(TELEPORT_TIME)

	for _, player in validPlayers do
		roundEvent:FireClient(player, "TeleportingEnded", {TweenInfo = TELEPORT_TWEEN_INFO})
	end
end

function RoundService.SpawnPlayerInRound(self: RoundService, player: Player)
	if not player then
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()

	if not character then
		return
	end

	local spawnpoints = mapSpawnpoints
	local spawnpoint = spawnpoints[math.random(1, #spawnpoints)]

	character:PivotTo(spawnpoint.CFrame * SPAWN_CFRAME_OFFSET)
end

function RoundService.SpawnValidPlayersInRound(self: RoundService)
	local validPlayers = currentRound:GetPlayers()
	
	for _, player in validPlayers do
		task.spawn(function()
			roundEvent:FireClient(player, "Teleporting", {TweenInfo = TELEPORT_TWEEN_INFO})
			task.wait(TELEPORT_TIME)
			self:SpawnPlayerInRound(player)
		end)
	end
	
	task.wait(TELEPORT_TIME)
	
	for _, player in validPlayers do
		roundEvent:FireClient(player, "TeleportingEnded", {TweenInfo = TELEPORT_TWEEN_INFO})
	end
end

function RoundService.GetIsMapIndexValid(self: RoundService, mapIndex: number)
	if mapIndex < 1 or mapIndex > 3 then
		return false
	end
	
	return true
end

function RoundService.GetIsModeIndexValid(self: RoundService, modeIndex: number)
	if modeIndex < 1 or modeIndex > 3 then
		return false
	end
	
	return true
end

function RoundService.GetMapFromName(self: RoundService, mapName: string)
	for _, map in mapSelection do
		if map.MapName == mapName then
			return map
		end
	end
end

function RoundService.GetModeFromName(self: RoundService, modeName: string)
	for _, mode in modeSelection do
		if mode.ModeName == modeName then
			return mode
		end
	end
end

function RoundService.GetIfPlayerVotedOnMap(self: RoundService, player: Player)
	for _, map in mapSelection do
		if table.find(map.MapVoters, player) then
			return true
		end
	end
end

function RoundService.GetIfPlayerVotedOnMode(self: RoundService, player: Player)
	for _, mode in modeSelection do
		if table.find(mode.ModeVoters, player) then
			return true
		end
	end
end

function RoundService.GetHighestVotedMap(self: RoundService)
	local highestVotedMap = nil
	local highestVoteCount = 0
	
	for _, map in mapSelection do
		if #map.MapVoters > highestVoteCount then
			highestVotedMap = map
			highestVoteCount = #map.MapVoters
		end
	end
	
	return highestVotedMap or mapSelection[1]
end

function RoundService.GetHighestVotedMode(self: RoundService)
	local highestVotedMode = nil
	local highestVoteCount = 0

	for _, mode in modeSelection do
		if #mode.ModeVoters > highestVoteCount then
			highestVotedMode = mode
			highestVoteCount = #mode.ModeVoters
		end
	end

	return highestVotedMode or modeSelection[1]
end

function RoundService.GetCurrentRound(self: RoundService)
	return currentRound
end

type RoundService = typeof(RoundService) & {
	
}

return RoundService
