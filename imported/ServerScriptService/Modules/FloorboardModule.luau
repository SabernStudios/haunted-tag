-- Services
local SSS = game:GetService("ServerScriptService")
local DS = game:GetService("Debris")

local activated = false

-- Custom Services
local Services = SSS.Services
local CharacterService = require(Services.CharacterService)

local FloorboardModule = {}

function FloorboardModule.GetCooldown()
	return 3
end

function FloorboardModule.Fling(activated, part, hit)
	if hit.Parent:FindFirstChild("Humanoid") and not activated then
		--hit.Parent.Humanoid.PlatformStand = true

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = (part.CFrame.LookVector * 100)
		bodyVelocity.MaxForce = Vector3.one * math.huge
		bodyVelocity.Parent = hit.Parent.HumanoidRootPart
		game.Debris:AddItem(bodyVelocity, 0.1)
		
		task.wait(0.3)
		
		--local character = CharacterService:GetCharacterFromCharacter(hit.Parent)
		--character.Ragdoll:TryRagdoll(0.25)

		local vineBoomClone = game:GetService("ReplicatedStorage").Assets.SoundEffects["vine-boom-sound-effect_KT89XIq"]:Clone()
		vineBoomClone.Volume = 0.25
		vineBoomClone.Parent = hit.Parent
		vineBoomClone:Play()

		DS:AddItem(vineBoomClone, 1)
	end
end

return FloorboardModule
