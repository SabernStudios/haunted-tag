local AttackDefinition = {}

local ATTACK_NAME = "Melee" -- TODO: get from attackDef

local STATE_NAME = "Attack"

local MAX_COMBO = 4
local COMBO_BUFFER = 0.35
local COMBO_RESET_TIME = 0.8
local COMBO_COOLDOWN = 1

local HITBOX_START = 0.1
local HITBOX_END = 0.35
local HITBOX_DURATION = HITBOX_END - HITBOX_START

local DAMAGE = 7
local DAMAGE_MAX_COMBO = 10

local KNOCKBACK = 3
local KNOCKBACK_MAX_COMBO = 25

local STUN_TIME = 1
local STUN_TIME_MAX_COMBO = 1.5

local UNBLOCKABLE = false

function AttackDefinition.ReturnAttackName()
	return ATTACK_NAME
end

function AttackDefinition.ReturnStateName()
	return STATE_NAME
end

function AttackDefinition.ReturnMaxCombo()
	return MAX_COMBO
end

function AttackDefinition.ReturnComboBuffer()
	return COMBO_BUFFER
end

function AttackDefinition.ReturnComboResetTime()
	return COMBO_RESET_TIME
end

function AttackDefinition.ReturnComboCooldown()
	return COMBO_COOLDOWN
end

function AttackDefinition.ReturnHitboxStart()
	return HITBOX_START
end

function AttackDefinition.ReturnHitboxEnd()
	return HITBOX_END
end

function AttackDefinition.ReturnHitboxDuration()
	return HITBOX_DURATION
end

function AttackDefinition.ReturnDamage()
	return DAMAGE
end

function AttackDefinition.ReturnDamageMaxCombo()
	return DAMAGE_MAX_COMBO
end

function AttackDefinition.ReturnKnockback()
	return KNOCKBACK
end

function AttackDefinition.ReturnKnockbackMaxCombo()
	return KNOCKBACK_MAX_COMBO
end

function AttackDefinition.ReturnStunTime()
	return STUN_TIME
end

function AttackDefinition.ReturnStunTimeMaxCombo()
	return STUN_TIME_MAX_COMBO
end

function AttackDefinition.ReturnUnblockable()
	return UNBLOCKABLE
end

return AttackDefinition
