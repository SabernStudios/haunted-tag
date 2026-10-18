local HitboxClass = {}
HitboxClass.__index = HitboxClass

-- Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

-- Packages
local Signal = require(ReplicatedStorage.Packages.Signal)

function HitboxClass.new(params: {
	mode: HitboxMode,
	parent: BasePart,
	offset: CFrame,
	size: Vector3,
	ignoreList: {Model}?,
	}): HitboxClass
	
	local self = setmetatable({}, HitboxClass)
	
	self.Mode = params.mode or "Attached"
	self.Parent = params.parent
	self.Offset = params.offset or CFrame.new()
	self.CFrame = self.Parent.CFrame * self.Offset
	self.Size = params.size or Vector3.new(1, 1, 1)
	self.IgnoreList = params.ignoreList or {}
	self._Activated = false
	
	self.RunningThread = nil
	
	--self:CreateHitbox()
	self:DefineOverlapParams()
	
	-- Signals
	self.OnHit = Signal.new()
	
	return self
end

-- The function is used strictly inside of the constructor

function HitboxClass:DefineOverlapParams(): ()
	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = self.IgnoreList
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	
	self.OverlapParams = overlapParams
end

function HitboxClass:Update()
	self.CFrame = self.Parent.CFrame * self.Offset
end

function HitboxClass:Activate(duration: number?): ()
	self._Activated = true
	
	if not duration then
		HitboxClass:ActivateProlongedHitbox()
		return
	end
	
	task.delay(duration, function()
		self._Activated = false
		self.RunningThread:Disconnect()
		self.RunningThread = nil
		self:Destroy()
		return
	end)
	
	self.RunningThread = RunService.Heartbeat:Connect(function()
		if self.Mode == "Attached" then
			self:Update()
		end
		
		local hitboxParts = workspace:GetPartBoundsInBox(self.CFrame :: CFrame, self.Size :: Vector3, self.OverlapParams :: {})
		
		for _, part in hitboxParts do
			if CollectionService:HasTag(part, "Hurtbox") then
				self.OnHit:Fire(part.Parent :: Model)
				self.OverlapParams.FilterDescendantsInstances[#self.OverlapParams.FilterDescendantsInstances + 1] = part.Parent
			end
		end
	end)
end

function HitboxClass:ActivateProlongedHitbox(): ()
	print("Dawg :skull:, why didn't you specify a duration for the hitbox :skull:")
end

function HitboxClass:Destroy(): ()
	self = nil
	return nil
end

export type HitboxClass = typeof(HitboxClass) & {

}

export type HitboxMode = {
	"Attached" | "Unanchored" | "World"
}

return HitboxClass
