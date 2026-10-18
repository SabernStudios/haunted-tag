local AnimationUtils = {}

AnimationUtils.HeldExceptions = {
	Block_Hit = "Block_Held",
}

-- Specific animation identifiers

function AnimationUtils.ReturnAttackAnimationName(action: string, data: {}): string
	return action .. "_" .. data.AttackName .. "_" .. tostring(data.Combo)
end

-- Animation modes

function AnimationUtils.GetIsHeld(trackName: string)
	if string.find(trackName, "_Held") then
		return true
	else
		return false
	end
end

function AnimationUtils.ReturnHeldAnimation(action: string)
	for key, heldAction in pairs(AnimationUtils.HeldExceptions) do
		if action == key then
			return heldAction
		end
	end
	
	return action .. "_Held"
end

return AnimationUtils