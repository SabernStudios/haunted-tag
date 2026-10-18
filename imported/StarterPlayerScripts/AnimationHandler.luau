local AnimationHandler = {}
AnimationHandler.__index = AnimationHandler

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Animations Folder
local Animations = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Definitions"):WaitForChild("Animations")
local AnimationDefinitions = require(Animations.AnimationDefinitions)

AnimationHandler.AnimationDefinitions = {}

local AnimationUtils = require(ReplicatedStorage.Shared.Modules.AnimationUtils)

function AnimationHandler.new(params: {
	player: Player,
	character: Model,
	animator: Animator,
	}): AnimationHandler
	
	local self = setmetatable({}, AnimationHandler)
	
	self.Player = params.player
	self.Character = params.character
	self.Animator = params.animator
	
	self.Tracks = {}
	self.CurrentTrack = nil
	
	-- "Runtime"
	self:LoadAnimations()
	
	return self
end

-- LoadAnimations should only be called once, but can be called more

function AnimationHandler:LoadAnimations()
	AnimationHandler.AnimationDefinitions = AnimationDefinitions.AppendAnimations()
	
	for name, animation in pairs(AnimationHandler.AnimationDefinitions) do
		local anim = Instance.new("Animation")
		anim.AnimationId = animation.Id

		local track = self.Animator:LoadAnimation(anim)
		track.Priority = animation.Priority
		track.Looped = animation.Looped
		
		self.Tracks[name] = track
	end
end

-- Primitive animation plays -> advanced animation plays
function AnimationHandler:PlayIntermediary(name: string, fadeTime: number)
	local track = self.Tracks[name]
	if not track then return end
	
	track:Play(fadeTime)
end

function AnimationHandler:Play(name: string, fadeTime: number)
	local track = self.Tracks[name]
	if not track then return end
	
	if self.CurrentTrack and AnimationUtils.GetIsHeld(self.CurrentTrack.Name) then
		self.CurrentTrack:Stop()
	end
	
	self.CurrentTrack = track
	track:Play(fadeTime)
end

function AnimationHandler:PlayThenHold(playName: string, holdName: string, fadeTime: number)
	local track = self.Tracks[playName]
	if not track then return end

	if self.CurrentTrack then
		self.CurrentTrack:Stop()
	end

	self.CurrentTrack = track
	track:Play(fadeTime)
	track:GetMarkerReachedSignal("Hold"):Wait()
	
	local trackHeld = self.Tracks[holdName]
	if not trackHeld then return end
	
	self.CurrentTrack = trackHeld
	trackHeld:Play(fadeTime)
end

function AnimationHandler:Stop()
	if self.CurrentTrack then
		self.CurrentTrack:Stop()
	end
end

function AnimationHandler:OnActionStarted(action: string, data: {}?)
	local identifier = action
	
	if action == "Attack" then
		identifier = AnimationUtils.ReturnAttackAnimationName(action, data)
	end
	
	if data.Held then
		local identifierHeld = AnimationUtils.ReturnHeldAnimation(action)
		self:PlayThenHold(identifier, identifierHeld, 0.1)
	else
		self:Play(identifier, 0.1)
	end
end

export type AnimationHandler = typeof(AnimationHandler) & {
	
}

return AnimationHandler
