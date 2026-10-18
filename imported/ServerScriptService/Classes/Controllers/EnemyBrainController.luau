local EnemyBrainController = {}
EnemyBrainController.__index = EnemyBrainController

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- EnemyClasses
local EnemyClasses = ReplicatedStorage.Shared.Definitions.EnemyClasses

-- Modules
local PathfindingModule = require(ReplicatedStorage.Shared.Modules.PathfindingModule)

-- Custom Services
local AIService = require(SSS.Services.AIService)
local CharacterService = require(SSS.Services.CharacterService)

function EnemyBrainController.new(enemy, NPCData: {}): EnemyBrainController
	local self = setmetatable({}, EnemyBrainController)
	
	self.Enemy = enemy
	self.State = enemy.State
	
	self.CharacterInstance = enemy.Character
	self.Humanoid = self.CharacterInstance:FindFirstChildOfClass("Humanoid")
	self.RootPart = self.CharacterInstance:FindFirstChild("HumanoidRootPart")
	
	self.Target = nil
	self.TargetSkillLevel = 0 -- 0-1
	self.Enabled = true
	self.AccumulatedWaitTime = 0
	
	-- Attributes
	self.IsNPC = NPCData.IsNPC or false
	self.IsSmart = NPCData.IsSmart or false
	self.IsDummy = NPCData.IsDummy or false
	self.DummyType = NPCData.DummyType or "None"
	self.EnemyType = NPCData.EnemyType or "Dummy"
	self.EnemyFunctions = NPCData.EnemyFunctions or {}
	
	-- Pathfinding
	self.LastPathTime = 0
	self.AgentParams = NPCData.AgentParams or {}
	self.ActiveMovement = nil
	
	-- Definition-Specific Attributes
	self.Definition = require(EnemyClasses:FindFirstChild(self.EnemyType.."Definition"))
	
	-- Registration
	AIService:RegisterBrain(self :: EnemyBrainController)
	
	-- Network Ownership (I will NEVER forget the pain this caused me like 7 months ago)
	self.CharacterInstance.PrimaryPart:SetNetworkOwner(nil)
	
	return self
end

function EnemyBrainController:Update(deltaTime: number)
	-- Sanity Checks
	if not self.Enabled then return end
	
	self.AccumulatedWaitTime += deltaTime
	
	-- Wait time
	if self.AccumulatedWaitTime < self.Definition.ReturnUpdateTime() then return end
	self.AccumulatedWaitTime = 0
	
	-- Update
	if self.IsDummy then
		self:UpdateDummy()
	else
		if not self.Target then
			local targetChar = self.EnemyFunctions.GetNearestCharacterInRange(self.RootPart, self.Definition.ReturnRange()) -- Use .call instead of :call because of the way the function was injected
			self.Target = CharacterService:GetCharacterFromCharacter(targetChar :: Model)
		end
		
		if not self.IsSmart then
			self:UpdateStatic()
		else
			self:UpdateSmart()
		end
	end
end

-- Dummy Behavior
function EnemyBrainController:UpdateDummy(deltaTime: number)
	if not self.IsDummy or not self.DummyType then return end
	
	if self.DummyType == "None" then
		-- No behavior
	elseif self.DummyType == "Attack" then
		if self.State:Is("Attack") then return end
		
		self.Enemy.Combat:TryAttack()
	elseif self.DummyType == "Block" then
		if self.State:Is("Block") then return end
		
		self.Enemy.Combat:TryBlock()
	end
end

-- Smart Behavior (DDA Logic)
function EnemyBrainController:UpdateSmart(deltaTime: number)
	
end

function EnemyBrainController:UpdateStatic(deltaTime: number)
	if not self.Target then return end
	
	self:MoveEnemyAcrossWaypoints()
	
	if PathfindingModule.CalculateDistance(self.RootPart.Position :: Vector3, self.Target.Character:FindFirstChild("HumanoidRootPart").Position) < self.Definition.ReturnAttackRange()
		and not self.Target.State:Is("Ragdolled") then
		
		self.Enemy.Combat:TryAttack()
		
		if math.random(1, 2) == 1 then
			return
		end
	else
		local random1 = math.random(1,20)
		
		if random1 == 1 then
			local random2 = math.random(1,5)
			
			if random2 <= 2 then
				self.Enemy.Movement:TryDash({Direction = self.RootPart.CFrame.LookVector}) -- Dash forward
			elseif random2 == 3 then
				self.Enemy.Movement:TryDash({Direction = -self.RootPart.CFrame.RightVector}) -- Dash left
			elseif random2 == 4 then
				self.Enemy.Movement:TryDash({Direction = -self.RootPart.CFrame.LookVector}) -- Dash backward
			else
				self.Enemy.Movement:TryDash({Direction = self.RootPart.CFrame.RightVector}) -- Dash right
			end
		else
			self.Enemy.Movement:TrySprint()
			
			task.delay(self.Definition.ReturnSprintDuration(), function()
				self.Enemy.Movement:TryStopSprint()
			end)
		end
	end
	
	if self.Target.State:Is("Attack") then
		task.delay(self.Definition.ReturnReactionTime(), function()
			self.Enemy.Combat:TryBlock()
			task.delay(self.Definition.ReturnReactionTime(), function()
				self.Enemy.Combat:TryStopBlock()
			end)
		end)
	end
end

function EnemyBrainController:LockOnTarget()
	if not self.Target then return end
	
	local targetRootPart = self.Target.Character:FindFirstChild("HumanoidRootPart")
	if not targetRootPart then return end
	
	self.CharacterInstance:SetPrimaryPartCFrame(
		CFrame.new(self.CharacterInstance.PrimaryPart.CFrame.Position, Vector3.new(targetRootPart.Position.X, self.CharacterInstance.PrimaryPart.CFrame.Position.Y, targetRootPart.Position.Z))
	)
end

function EnemyBrainController:MoveEnemyAcrossWaypoints()
	if not self.Target then return end

	if self.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing
		or (self.Humanoid:GetState() == Enum.HumanoidStateType.Climbing and self.RootPart.AssemblyLinearVelocity.Magnitude < 0.2) then

		self.LastPathTime = time()

		local path = PathfindingModule.CalculatePath(self.RootPart.Position, self.Target.Character:FindFirstChild("HumanoidRootPart").Position, self.AgentParams)
		local waypoints = path:GetWaypoints()

		if self.ActiveMovement then
			coroutine.close(self.ActiveMovement)
			self.ActiveMovement = nil
		end

		self.ActiveMovement = coroutine.create(function()
			if path.Status == Enum.PathStatus.Success then
				for _, waypoint in waypoints do
					if (self.RootPart.Position - waypoint.Position ).Magnitude < 4 then
						continue
					end

					if waypoint.Action == Enum.PathWaypointAction.Jump and self.Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
						self.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end

					self.Humanoid:MoveTo(waypoint.Position)
					self.Humanoid.MoveToFinished:Wait()
						
					if self.Humanoid:GetState() == Enum.HumanoidStateType.Climbing then
						if self.RootPart.AssemblyLinearVelocity.Magnitude < 0.1 then
							self.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
						end
					end
				end
			end
		end)
			
		task.spawn(self.ActiveMovement)
	end
end

type EnemyBrainController = typeof(EnemyBrainController) & {
	
}

return EnemyBrainController
