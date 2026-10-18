-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Classes
local MapClass = require(script.Parent)

local HauntedHouseClass = {}
HauntedHouseClass.__index = HauntedHouseClass
setmetatable(HauntedHouseClass, {__index = MapClass})

function HauntedHouseClass.new(): HauntedHouseClass
	local mapName = "Haunted House"
	local mapDescription = "A spooky house with a few secrets. Beware of the traps that might slip you up."
	local mapFolder = ReplicatedStorage.Assets.Maps.HauntedHouseMap
	local imageId = ReplicatedStorage.Assets.Decals.UI.Maps.HauntedHouseDecal.Texture
	
	local self = MapClass.new(mapName, mapDescription, mapFolder, imageId)
	setmetatable(self, HauntedHouseClass)
	
	return self
end

type HauntedHouseClass = typeof(HauntedHouseClass) & {
	
}

return HauntedHouseClass
