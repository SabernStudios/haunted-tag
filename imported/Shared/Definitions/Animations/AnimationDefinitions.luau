local AnimationDefinitions = {}

local Animations = script.Parent

AnimationDefinitions.Animations = {}

function AnimationDefinitions.AppendAnimations()
	for _, moduleScript in Animations:GetChildren() do
		if moduleScript:IsA("ModuleScript") and moduleScript ~= script then
			local data = require(moduleScript)
			
			for name, animation in pairs(data) do
				AnimationDefinitions.Animations[name] = animation
			end
		end
	end
	
	return AnimationDefinitions.Animations
end

function AnimationDefinitions.ReturnPodiumAnimations()
	local animations = {}
	
	local podiumAnimationsData = require(Animations.PodiumAnimations)
	
	for name, animation in pairs(podiumAnimationsData) do
		animations[name] = animation
	end
	
	return animations
end

return AnimationDefinitions
