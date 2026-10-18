-- Services
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

-- Constants
local MYSTERY_CHARACTER_CFRAME = CFrame.new(0, -1.75, 0)

local CLONE_SCALE = 1.5

local totalRevealTwistTime = 0.75
local revealTweenInfo = TweenInfo.new(totalRevealTwistTime/2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

-- Variables
local typewriterSound = ReplicatedStorage.Assets.SoundEffects.typewriter
local revealSound = ReplicatedStorage.Assets.SoundEffects.RevealSound

local map = nil
local podium = nil

local mapPodiumFolder = nil

local forSureSuperlatives = {
	["Most Tags"] = "Tags",
	["Longest In Chase"] = "TimeSpentInChase"
}

local superlatives = {
	["Longest Survived"] = "TimeSurvived",
}

-- Custom Services
local StatService = require(SSS.Services.StatService)

local PodiumService = {}

function PodiumService.Init(self: PodiumService)
	
end

function PodiumService.SetPodium(self: PodiumService)
	podium = ReplicatedStorage.Assets.Podiums.Podium
end

function PodiumService.AddPodium(self: PodiumService)
	mapPodiumFolder = map.Podium
	local podiumClone = podium:Clone()
	podiumClone.Parent = mapPodiumFolder
	podiumClone.PrimaryPart:PivotTo(mapPodiumFolder.PodiumSpawn.CFrame)
	
	podium = podiumClone
end

function PodiumService.DeletePodium(self: PodiumService)
	if podium == nil then
		return
	end
	
	podium:Destroy()
	podium = nil
end

function PodiumService.AddMysteries(self: PodiumService)
	local validPodiums = {}

	for _, podiumModel in ipairs(podium:GetChildren()) do
		if not podiumModel:IsA("Model") then
			continue
		end

		local spawnPart = podiumModel:FindFirstChild("SpawnPart")

		if not spawnPart or not spawnPart:IsA("BasePart") then
			warn(
				"Podium is missing a BasePart named SpawnPart:",
				podiumModel:GetFullName()
			)

			continue
		end

		table.insert(validPodiums, podiumModel)
	end

	-- Use names such as Podium1, Podium2, and Podium3.
	table.sort(validPodiums, function(firstPodium, secondPodium)
		return firstPodium.Name < secondPodium.Name
	end)

	if #validPodiums == 0 then
		warn("No valid podium models were found")
		return
	end
	
	for _, podiumModel in ipairs(validPodiums) do
		local spawnPart = podiumModel:FindFirstChild("SpawnPart")
		local mysteryClone = ReplicatedStorage.Assets.NPCs.MysteryCharacter:Clone()
		
		mysteryClone.Parent = podiumModel
		mysteryClone.HumanoidRootPart.Anchored = true
		mysteryClone:PivotTo(spawnPart.CFrame * MYSTERY_CHARACTER_CFRAME)
		
		mysteryClone:ScaleTo(CLONE_SCALE)
	end
end

function PodiumService.RevealPlayers(self: PodiumService)
	----------------------------------------------------------------
	-- Select the round's superlatives
	----------------------------------------------------------------

	local chosenSuperlatives = table.clone(forSureSuperlatives)
	local optionalSuperlatives = {}

	for superlativeName, statName in pairs(superlatives) do
		if chosenSuperlatives[superlativeName] == nil then
			table.insert(optionalSuperlatives, {
				Name = superlativeName,
				Stat = statName,
			})
		end
	end

	-- Add one random optional superlative.
	if #optionalSuperlatives > 0 then
		local chosenOptional = optionalSuperlatives[math.random(1, #optionalSuperlatives)]

		chosenSuperlatives[chosenOptional.Name] =
			chosenOptional.Stat
	end

	local chosenAwards = {}

	for superlativeName, statName in pairs(chosenSuperlatives) do
		table.insert(chosenAwards, {
			Name = superlativeName,
			Stat = statName,
		})
	end

	----------------------------------------------------------------
	-- Find valid podiums
	----------------------------------------------------------------

	local validPodiums = {}

	for _, podiumModel in ipairs(podium:GetChildren()) do
		if not podiumModel:IsA("Model") then
			continue
		end

		local spawnPart = podiumModel:FindFirstChild("SpawnPart")

		if not spawnPart or not spawnPart:IsA("BasePart") then
			warn(
				"Podium is missing a BasePart named SpawnPart:",
				podiumModel:GetFullName()
			)

			continue
		end

		table.insert(validPodiums, podiumModel)
	end

	-- Use names such as Podium1, Podium2, and Podium3.
	table.sort(validPodiums, function(firstPodium, secondPodium)
		return firstPodium.Name < secondPodium.Name
	end)

	if #validPodiums == 0 then
		warn("No valid podium models were found")
		return
	end

	----------------------------------------------------------------
	-- Clear previous podium characters
	----------------------------------------------------------------

	for _, podiumModel in ipairs(validPodiums) do
		for _, child in ipairs(podiumModel:GetChildren()) do
			if child:GetAttribute("IsPodiumCharacter") then
				child:Destroy()
			end
		end
	end

	----------------------------------------------------------------
	-- Prepare available animations
	----------------------------------------------------------------

	local animationDefinitions = require(
		ReplicatedStorage.Shared.Definitions.Animations.AnimationDefinitions
	).ReturnPodiumAnimations()

	local candidateAnimations = {}

	for animationName, animationContents in pairs(animationDefinitions) do
		table.insert(candidateAnimations, {
			Name = animationName,
			Contents = animationContents,
		})
	end

	if #candidateAnimations == 0 then
		warn("No podium animation definitions were found")
	end

	----------------------------------------------------------------
	-- Create the podium winners
	----------------------------------------------------------------

	local chosenPlayers = {}
	local podiumIndex = 1

	for _, award in ipairs(chosenAwards) do
		local podiumModel: Model = validPodiums[podiumIndex]

		if not podiumModel then
			break
		end

		local player, highestAmount = StatService:GetHighestAmount(
			award.Stat,
			chosenPlayers
		)

		if not player then
			warn(
				"No eligible player found for superlative:",
				award.Name
			)

			continue
		end

		table.insert(chosenPlayers, player)

		local character =
			player.Character or player.CharacterAdded:Wait()

		if not character or not character.Parent then
			warn("Character unavailable for:", player.Name)
			continue
		end

		----------------------------------------------------------------
		-- Clone the player's character
		----------------------------------------------------------------

		local previousArchivable = character.Archivable
		character.Archivable = true

		local characterClone = character:Clone()

		character.Archivable = previousArchivable

		if not characterClone then
			warn("Failed to clone character for:", player.Name)
			continue
		end

		characterClone.Name =
			player.Name .. "_PodiumCharacter"

		characterClone:SetAttribute(
			"IsPodiumCharacter",
			true
		)

		characterClone:SetAttribute(
			"Superlative",
			award.Name
		)

		characterClone:SetAttribute(
			"PlayerUserId",
			player.UserId
		)

		----------------------------------------------------------------
		-- Clean up the display character
		----------------------------------------------------------------

		for _, item in ipairs(characterClone:GetDescendants()) do
			if item:IsA("Script")
				or item:IsA("LocalScript")
			then
				item:Destroy()

			elseif item:IsA("Highlight") then
				item:Destroy()

			elseif item:IsA("BasePart") then
				item.Anchored = false
				item.CanCollide = false
				item.CanTouch = false
				item.CanQuery = false
				item.Massless = true
				
				item.Transparency = 0

				if item.Name == "HumanoidRootPart"
					or item.Name == "Hurtbox"
				then
					item.Transparency = 1
				end
			end
		end

		local humanoid =
			characterClone:FindFirstChildOfClass("Humanoid")

		local rootPart =
			characterClone:FindFirstChild("HumanoidRootPart")

		if not humanoid or not rootPart then
			warn(
				"Podium clone is missing Humanoid or HumanoidRootPart:",
				player.Name
			)

			characterClone:Destroy()
			continue
		end

		humanoid.AutoRotate = false

		humanoid.DisplayDistanceType =
			Enum.HumanoidDisplayDistanceType.None

		humanoid.HealthDisplayType =
			Enum.HumanoidHealthDisplayType.AlwaysOff

		humanoid.BreakJointsOnDeath = false

		----------------------------------------------------------------
		-- Remove the Animator copied from the live character
		----------------------------------------------------------------

		local copiedAnimator =
			humanoid:FindFirstChildOfClass("Animator")

		if copiedAnimator then
			copiedAnimator:Destroy()
		end
		
		----------------------------------------------------------------
		-- Parent and position the clone before loading animations
		----------------------------------------------------------------

		characterClone.Parent = podiumModel
		
		for _, part in characterClone:GetChildren() do
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
			
			if part:IsA("Accessory") then
				for _, child in part:GetChildren() do
					if child:IsA("BasePart") then
						child.Transparency = 1
					end
				end
			end
		end

		characterClone:PivotTo(
			podiumModel.SpawnPart.CFrame
		)

		characterClone:ScaleTo(CLONE_SCALE)

		characterClone.HumanoidRootPart.Anchored = true

		-- Only anchor the root. The Motor6Ds can still animate.
		--rootPart.Anchored = true

		----------------------------------------------------------------
		-- Create a fresh server-owned Animator
		----------------------------------------------------------------

		local animator = Instance.new("Animator")
		animator.Parent = humanoid

		-- Let Roblox register the new Animator beneath Workspace.
		task.wait()

		----------------------------------------------------------------
		-- Select and play a unique animation
		----------------------------------------------------------------

		if #candidateAnimations == 0 then
			warn(
				"No unused podium animation available for:",
				player.Name
			)

			podiumIndex += 1
			continue
		end

		local animationIndex =
			math.random(1, #candidateAnimations)

		local chosenAnimation = table.remove(
			candidateAnimations,
			animationIndex
		)

		local animationContents =
			chosenAnimation.Contents

		local animationId =
			tostring(animationContents.Id)

		if not string.find(
			animationId,
			"rbxassetid://",
			1,
			true
			) then
			animationId =
				"rbxassetid://" .. animationId
		end

		local animation = Instance.new("Animation")
		animation.Name = chosenAnimation.Name
		animation.AnimationId = animationId
		animation.Parent = characterClone

		----------------------------------------------------------------
		-- Preload the animation
		----------------------------------------------------------------

		local preloadSuccess, preloadError = pcall(function()
			ContentProvider:PreloadAsync({ animation })
		end)

		if not preloadSuccess then
			warn(
				"Failed to preload podium animation:",
				chosenAnimation.Name,
				animationId,
				preloadError
			)
		end

		----------------------------------------------------------------
		-- Load the animation track
		----------------------------------------------------------------

		local loadSuccess, result = pcall(function()
			return animator:LoadAnimation(animation)
		end)

		if not loadSuccess then
			warn(
				"Failed to load podium animation:",
				chosenAnimation.Name,
				animationId,
				result
			)

			podiumIndex += 1
			continue
		end

		local animationTrack: AnimationTrack = result

		----------------------------------------------------------------
		-- Configure priority
		----------------------------------------------------------------

		local priority = animationContents.Priority

		if typeof(priority) == "string" then
			priority = Enum.AnimationPriority[priority]
		end

		if typeof(priority) ~= "EnumItem" then
			priority = Enum.AnimationPriority.Action4
		end

		animationTrack.Priority = priority

		-- Pose animations should normally loop.
		animationTrack.Looped =
			animationContents.Looped ~= false

		----------------------------------------------------------------
		-- Play the animation
		----------------------------------------------------------------

		animationTrack:Play(0.1, 1, 1)

		characterClone:PivotTo(characterClone:GetPivot() * animationContents.Offset * CFrame.Angles(0, math.rad(180), 0))
		
		-- Show Superlative First
		local typewriterSoundClone = typewriterSound:Clone()
		typewriterSoundClone.Parent = podiumModel
		
		local mostText = podiumModel.SpawnPart.BillboardGui.Frame.Most
		
		local fullSuperlative = award.Name .. "•" .. tostring(highestAmount)
		
		for i = 1, #fullSuperlative, 1 do
			mostText.Text = string.sub(fullSuperlative, 1, i)
			typewriterSoundClone:Play()
			task.wait(0.1)
		end
		
		typewriterSoundClone:Destroy()
		
		task.wait(1)
		
		local revealSoundClone = revealSound:Clone()
		revealSoundClone.Parent = podiumModel
		revealSoundClone.PlaybackSpeed = 1 + 0.5 * (podiumIndex - 1)
		
		local mysteryCharacter = podiumModel:FindFirstChild("MysteryCharacter")

		if mysteryCharacter then
			mysteryCharacter:Destroy()
		end
		
		for _, part in characterClone:GetChildren() do
			if part:IsA("BasePart") and not (part.Name == "Hurtbox" or part.Name == "HumanoidRootPart") then
				part.Transparency = 0
			end
			
			if part:IsA("Accessory") then
				for _, child in part:GetChildren() do
					if child:IsA("BasePart") then
						child.Transparency = 0
					end
				end
			end
		end
		
		mostText.Text = string.format("%s\n%s", fullSuperlative, player.Name)
		
		task.spawn(function()
			local tween = TweenService:Create(characterClone.HumanoidRootPart, revealTweenInfo, {CFrame = characterClone.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(180), 0)})
			tween:Play()
		end)
		
		local orangeParticleEmitterClone = ReplicatedStorage.Assets.ParticleEmitters.OrangeParticleEmitter:Clone()
		orangeParticleEmitterClone.Parent = characterClone
		orangeParticleEmitterClone.Position = characterClone.HumanoidRootPart.Position
		
		task.spawn(function()
			orangeParticleEmitterClone.ParticleEmitter.Enabled = true
			task.wait(0.5)
			orangeParticleEmitterClone.ParticleEmitter.Enabled = false
		end)
		
		task.spawn(function()
			revealSoundClone:Play()
			revealSoundClone.Ended:Wait()
			revealSoundClone:Destroy()
		end)

		podiumIndex += 1
	end
end

function PodiumService.SetCurrentMap(self: PodiumService, mapFolder)
	map = mapFolder
end

function PodiumService.GetPodiumSpawnPart(self: PodiumService)
	return mapPodiumFolder.PodiumSpawn
end

function PodiumService.GetPodiumCameraPart(self: PodiumService)
	return mapPodiumFolder.PodiumCameraPart
end

type PodiumService = typeof(PodiumService) & {
	
}

return PodiumService
