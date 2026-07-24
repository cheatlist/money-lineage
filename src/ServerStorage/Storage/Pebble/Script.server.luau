local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Modules = ServerScriptService:WaitForChild("Modules")
local Requests = ServerStorage:WaitForChild("Requests")
local Assets = ServerStorage:WaitForChild("Assets")

local HitDetection = require(Modules:WaitForChild("HitDetection"))
local TagHumanoid = Requests:WaitForChild("TagHumanoid")
local Used = false

script.Parent.Activated:Connect(function()
	local Character = script.Parent.Parent
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	if not Humanoid then
		return
	end
	local Animator = Humanoid:FindFirstChildOfClass("Animator")
	if not Animator then
		return
	end
	local Player = Players:GetPlayerFromCharacter(Character)
	local Mouse = _G.MouseData(Player)
	if not Mouse then
		return
	end
	if Used then
		return
	end
	Used = true
	task.delay(10,function()
		Used = false
	end)
	local Pebble = Assets:FindFirstChild("Pebble"):Clone()
	Pebble.Position = Character.HumanoidRootPart.Position+CFrame.new(Character.HumanoidRootPart.Position,Mouse.Hit.p).LookVector*1
	Pebble.CFrame = CFrame.new(Pebble.Position,Mouse.Hit.Position)
	Pebble.Parent = workspace.Thrown
	Pebble:SetNetworkOwner(nil)
	Pebble.BodyVelocity.Velocity = Pebble.CFrame.LookVector*300
	Animator:LoadAnimation(script.Throw):Play()
	task.delay(5,Pebble.Destroy,Pebble)
	local TouchedConnection = nil
	TouchedConnection = Pebble.Touched:Connect(function(Part)
		if not Part.Parent then
			return
		end
		if Part:IsDescendantOf(workspace.Terrain) then
			return
		end
		if Part:IsDescendantOf(Character) or Part.Name == Character.Name or Part.Parent.Name == Character.Name then
			return
		end
		if Part.Name == Pebble.Name then
			return
		end
		local EnemyHumanoid = Part.Parent:FindFirstChild("Humanoid") or Part.Parent.Parent:FindFirstChild("Humanoid")
		if EnemyHumanoid and EnemyHumanoid.Parent.Name == Character.Name then
			return
		end
		TouchedConnection:Disconnect()
		Pebble.BodyVelocity:Destroy()
		Pebble.Anchored = true
		Pebble.Transparency = 1
		HitDetection.aoeCombatTag(Character,Pebble.Position,25)
		Debris:AddItem(Pebble,1)
		if EnemyHumanoid then
			TagHumanoid:Fire(Character,Part.Parent,{
				nostun = true,
				physical = true,
				dagger = true,
				nohitanim = true,
				damage = 0,
			})
			Part.Parent.HumanoidRootPart.BloodHit:Emit(math.random(5,10))
			Part.Parent.HumanoidRootPart.DaggerHit:Play()
		else
			Pebble.Hit:Play()
		end
	end)
end)