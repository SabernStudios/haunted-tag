local MapClass = {}
MapClass.__index = MapClass

function MapClass.new(mapName: string, mapDescription: string, mapFolder: Folder, imageId: string): MapClass
	local self = setmetatable({}, MapClass)
	
	self.MapVoters = {}
	self.MapName = mapName or "Placeholder"
	self.MapDescription = mapDescription or "No description provided."
	self.MapFolder = mapFolder
	self.ImageId = imageId
	
	self.MapInstance = nil
	
	return self
end

function MapClass:GetCharacteristics()
	return {MapName = self.MapName, MapDescription = self.MapDescription, MapFolder = self.MapFolder, ImageId = self.ImageId}
end

function MapClass:Destroy()
	self.MapInstance:Destroy()
	self = nil
end

type MapClass = typeof(MapClass) & {
	
}

return MapClass
