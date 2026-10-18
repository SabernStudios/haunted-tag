--/ To give a brief introduction to this controller, it is basically meant to replace the client-side animations performed after sending a remote signal to the server.

local AnimationController = {}
AnimationController.__index = AnimationController

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Definitions
local AnimationDefinitions = require(ReplicatedStorage.Shared.Definitions.Animations.AnimationDefinitions)

AnimationController.AnimationDefinitions = {}

-- Modules
local AnimationUtils = require(ReplicatedStorage.Shared.Modules.AnimationUtils)

function AnimationController.new(character)
	local self = setmetatable({}, AnimationController)
	
	local self = setmetatable({}, AnimationController)

	self.Character = character
	self.Humanoid = character.Character.Humanoid
	self.Animator = self.Humanoid:WaitForChild("Animator")

	self.Tracks = {}
	self.CurrentTrack = nil

	-- "Runtime"
	self:LoadAnimations()

	return self
end

-- LoadAnimations should only be called once, but can be called more

function AnimationController:LoadAnimations()
	AnimationController.AnimationDefinitions = AnimationDefinitions.AppendAnimations()

	for name, animation in pairs(AnimationController.AnimationDefinitions) do
		local anim = Instance.new("Animation")
		anim.AnimationId = animation.Id

		local track = self.Animator:LoadAnimation(anim)
		track.Priority = animation.Priority
		track.Looped = animation.Looped

		self.Tracks[name] = track
	end
end

function AnimationController:Play(name: string, fadeTime: number)
	local track = self.Tracks[name]
	if not track then return end

	if self.CurrentTrack then
		self.CurrentTrack:Stop()
	end

	self.CurrentTrack = track
	track:Play(fadeTime)
end

function AnimationController:PlayThenHold(playName: string, holdName: string, fadeTime: number)
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

function AnimationController:Stop()
	if self.CurrentTrack then
		self.CurrentTrack:Stop()
	end
end

function AnimationController:OnActionStarted(action: string, data: {}?)
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

type AnimationController = typeof(AnimationController) & {
	
}

return AnimationController
