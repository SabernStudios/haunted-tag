local HurtboxClass = {}
HurtboxClass.__index = HurtboxClass

-- Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Signal = require(ReplicatedStorage.Packages.Signal)

function HurtboxClass.new(params: {
	character: Model,
	rootPart: BasePart,
	rootCFrame: CFrame,
	size: Vector3,
	}): HurtboxClass
	
	local self = setmetatable({}, HurtboxClass)
	
	self.character = params.character
	self.rootPart = params.rootPart
	self.rootCFrame = params.rootCFrame
	self.size = params.size
	
	self:CreateHurtbox()
	
	return self
end

function HurtboxClass:CreateHurtbox()
	local hurtbox = Instance.new("Part")
	hurtbox.Name = "Hurtbox"
	hurtbox.Size = self.size
	hurtbox.CFrame = self.rootCFrame
	hurtbox.CanCollide = false
	hurtbox.Transparency = 1
	hurtbox.Parent = self.character
	
	-- Add tag for later combat identification
	CollectionService:AddTag(hurtbox, "Hurtbox")
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hurtbox
	weld.Part1 = self.rootPart
	weld.Parent = hurtbox
	
	self.hurtbox = hurtbox
end

export type HurtboxClass = typeof(HurtboxClass) & {
	
}

return HurtboxClass
