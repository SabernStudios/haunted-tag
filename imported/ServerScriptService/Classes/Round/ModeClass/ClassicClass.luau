-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Classes
local ModeClass = require(script.Parent)

local ClassicClass = {}
ClassicClass.__index = ClassicClass
setmetatable(ClassicClass, {__index = ModeClass})

function ClassicClass.new(): ClassicClass
	local modeName = "Classic"
	local modeDescription = "Vanilla ahhh gameplay."
	local imageId = ReplicatedStorage.Assets.Decals.UI.Modes.Classic.Texture
	
	local modeGhosts = 1
	
	local self = ModeClass.new(modeName, modeDescription, imageId, modeGhosts)
	setmetatable(self, ClassicClass)
	
	return self
end

type ClassicClass = typeof(ClassicClass) & {
	
}

return ClassicClass
