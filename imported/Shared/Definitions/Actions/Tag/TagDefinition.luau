local TagDefinition = {}

local STATE_NAME = "Tagging"

local COMBO_BUFFER = 1
local COMBO_RESET_TIME = 0.8
local COMBO_COOLDOWN = 1

local HITBOX_START = 0.1
local HITBOX_END = 0.35
local HITBOX_DURATION = HITBOX_END - HITBOX_START

local STUN_TIME = 2.25

function TagDefinition.ReturnStateName()
	return STATE_NAME
end

function TagDefinition.ReturnComboBuffer()
	return COMBO_BUFFER
end

function TagDefinition.ReturnComboResetTime()
	return COMBO_RESET_TIME
end

function TagDefinition.ReturnComboCooldown()
	return COMBO_COOLDOWN
end

function TagDefinition.ReturnHitboxStart()
	return HITBOX_START
end

function TagDefinition.ReturnHitboxEnd()
	return HITBOX_END
end

function TagDefinition.ReturnHitboxDuration()
	return HITBOX_DURATION
end

function TagDefinition.ReturnStunTime()
	return STUN_TIME
end

return TagDefinition