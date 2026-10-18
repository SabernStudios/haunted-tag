local CombatTypes = {}

export type ComboPayload = {
	AttackDef: string,
}

export type AttackPayload = {
	Character: Model,
	Combo: number,
	Maxed: boolean,
	AttackDef: string,
	Event: BindableEvent,
}

export type ClientAttackPayload = {
	AttackName: string,
	Combo: number,
	Held: boolean,
}

export type BlockPayload = {
	Humanoid: Humanoid,
	BlockSpeed: number,
}

export type ClientBlockPayload = {
	BlockName: string,
	Held: boolean,
}

export type StopBlockPayload = {
	Humanoid: Humanoid,
	WalkSpeed: number,
}

export type ClientStopBlockPayload = {
	StopBlockName: string,
}

return CombatTypes
