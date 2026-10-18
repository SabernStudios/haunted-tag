-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Classes
local PowerupClass = require(script.Parent)

-- Assets
local Assets = ReplicatedStorage.Assets
local Invisible = Assets.Powerups.Invisible

local InvisibleClass = {}
InvisibleClass.__index = InvisibleClass
setmetatable(InvisibleClass, {__index = PowerupClass})

function InvisibleClass.new(): InvisibleClass
	local isAction = false

	local self = PowerupClass.new(Invisible:Clone() :: Model, Invisible :: Model, "Invisible", "Invisible", isAction)
	setmetatable(self, InvisibleClass)

	self.Duration = 5

	return self
end

function InvisibleClass:Activate(baseCharacter, token)
	task.spawn(function()
		for _, item in baseCharacter.Character:GetDescendants() do
			if item:IsA("BasePart") and (item.Name ~= "HumanoidRootPart" and item.Name ~= "Hurtbox") then
				item.Transparency = 0.95
			end
		end

		task.wait(self.Duration)

		if baseCharacter.Powerup.ActiveToken[self.PowerupType] ~= token then
			return
		end

		for _, item in baseCharacter.Character:GetDescendants() do
			if item:IsA("BasePart") and (item.Name ~= "HumanoidRootPart" and item.Name ~= "Hurtbox") then
				item.Transparency = 0
			end
		end

		self:Destroy()
	end)
end

type InvisibleClass = typeof(InvisibleClass) & {

}

return InvisibleClass