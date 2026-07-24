local TweenService = game:GetService("TweenService")
local HitDetection = require(game.ServerScriptService.Modules.HitDetection)
local function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
		return true
	end
	return false
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if not p2 then
		return
	end
	if not data then
		return
	end
	if data.Race.Value ~= "Dullahan" then
		return
	end
	canuse = false
	task.delay(10,function()
		canuse = true
	end)
	local PumpHead = p1:FindFirstChild("DullahanHead")
	p1.Humanoid:LoadAnimation(script.Animation):Play()
	task.wait(1)
	PumpHead.Transparency = 1
	for i,v in pairs(p1.Head:GetChildren()) do
		if v:IsA("Decal") then
			v.Transparency = 1
		end
	end
	task.delay(5,function()
		PumpHead.Transparency = 0
		for i,v in pairs(p1.Head:GetChildren()) do
			if v:IsA("Decal") then
				v.Transparency = 0
			end
		end
	end)
	local CloneHead = PumpHead:Clone()
	CloneHead.Massless = true
	CloneHead:ClearAllChildren()
	CloneHead.Transparency = 0
	CloneHead.CanCollide = true
	CloneHead.Parent = workspace.Thrown
	task.delay(3, CloneHead.Destroy, CloneHead)
	CloneHead.Touched:Connect(function(Part)
		if not Part.Parent then
			return
		end
		if CloneHead and CloneHead.Parent and Part ~= CloneHead and Part.Parent:FindFirstChild("Humanoid") and Part:IsA("BasePart") and tostring(Part.Parent) ~= tostring(p2) and Part.Parent ~= p1 then
			local WeldConstraint = Instance.new("WeldConstraint")
			WeldConstraint.Name = tostring(CloneHead).." --> "..tostring(Part)
			WeldConstraint.Part0 = CloneHead
			WeldConstraint.Part1 = Part
			WeldConstraint.Parent = CloneHead
		end
	end)
	p1.HumanoidRootPart.TakeOff:Play()
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.MaxForce = Vector3.new(math.huge,0,math.huge)
	BodyVelocity.Velocity = p1.HumanoidRootPart.CFrame.LookVector*35
	BodyVelocity.Parent = CloneHead
	game:GetService("Debris"):AddItem(BodyVelocity,0.25)
	task.wait(0.4)
	for i: number = 1,4 do
		CloneHead.Color = Color3.fromRGB(175,221,255)
		CloneHead.Material = Enum.Material.Neon
		task.wait(0.25)
		CloneHead.Color = Color3.fromRGB(163,162,165)
		CloneHead.Material = Enum.Material.Plastic
		task.wait(0.25)
	end
	local Explosion = game.ServerStorage.Assets.Explosion:Clone()
	Explosion.Ring.Color = Color3.fromRGB(232, 232, 0)
	Explosion.Ring.Material = Enum.Material.Neon
	Explosion.Ball.Color = Color3.fromRGB(255, 255, 0)
	Explosion.SmokeParticle.ParticleEmitter.Texture = "rbxassetid://596930864"
	Explosion.SmokeParticle.ParticleEmitter.Enabled = false
	Explosion:PivotTo(CloneHead.CFrame)
	Explosion.Ball.Size = Vector3.new(35,35,35)
	Explosion.Ring.Mesh.Scale = Vector3.new(3.5,3.5,3.5)
	Explosion.Parent = workspace.Thrown
	Explosion.SmokeParticle.ParticleEmitter:Emit(10)
	Explosion.Ball.Sound:Play()
	game:GetService("Debris"):AddItem(Explosion,3)
	TweenService:Create(Explosion.PrimaryPart.Mesh,TweenInfo.new(0.33,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Scale=Vector3.new(1,1,1)}):Play()
	TweenService:Create(Explosion.Ring.Mesh,TweenInfo.new(0.33,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Scale=Explosion.Ring.Mesh.Scale*10}):Play()
	TweenService:Create(Explosion.PrimaryPart,TweenInfo.new(0.6,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{Transparency=1}):Play()
	TweenService:Create(Explosion.Ring,TweenInfo.new(0.6,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{Transparency=1}):Play()
	HitDetection.magnitudeCheck(p1,CloneHead.Position,25,{
		mana = true,
		damage = 25,
		manaknockupself = true,
		bypassblock = true,
		manabreaker = true
	}, false, true);
	CloneHead:Destroy()
end)