-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- MusicPlaylist
local MusicPlaylist = ReplicatedStorage.Assets.MusicPlaylist

local MusicModule = {}

function MusicModule.GetNextTrack()
	local tracks = MusicPlaylist:GetChildren()
	
	local randomTrackIndex = math.random(1, #tracks)
	local randomTrack = tracks[randomTrackIndex]
	
	return randomTrack
end

return MusicModule
