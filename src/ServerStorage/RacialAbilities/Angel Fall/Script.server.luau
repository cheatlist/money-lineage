local TweenService: TweenService = game:GetService("TweenService")
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local function ActionCheck(Parent)
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		return true
	end
	if Parent:FindFirstChild("SpellBlocking") then
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
	return false
end
local canuse: boolean = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if p1:FindFirstChild("NOLDROP")then
		return
	end
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1:FindFirstChild'HumanoidRootPart'
	if not HumanoidRootPart then
		return warn("Angel Fall no HRP")
	end
	
	local playerdata = game.ServerStorage.PlayerData:FindFirstChild(p1.Name)
	
	game.ReplicatedStorage.Requests.ConfusedDay:FireClient(p2)
	
	local toRemove = {
		"NoFall",
		"Stun",
		"AngelForm",
	}
	
	for i,v in pairs(p1:GetChildren()) do
		if table.find(toRemove,v.Name) then
			v:Destroy()
		end
	end

	for i,v in pairs(p1:GetDescendants()) do
		if v.Name == 'Transparency' then
			v:Destroy();
		end
	end
	
	
	local v2: Accessory = Instance.new("Accessory")
	v2.Name = "NoFall"
	v2.Parent = p1
	game.Debris:AddItem(v2,4)
	p1.Humanoid:UnequipTools()
	HumanoidRootPart.STRIKE:Play()
	task.wait(1/30)
	local RCP: RaycastParams = RaycastParams.new()
	RCP.IgnoreWater = false
	RCP.FilterType = Enum.RaycastFilterType.Whitelist
	RCP.FilterDescendantsInstances = { workspace.Map, workspace.Thrown }
	local direction: Vector3 = Vector3.new(0,-3000,0)
	local Hit: RaycastResult = workspace:Raycast(HumanoidRootPart.Position, direction, RCP)
	if not Hit or not Hit.Position then
		return
	end
	local v3: Accessory = Instance.new("Accessory")
	v3.Name = "TPSafe"
	v3.Parent = p1
	game.Debris:AddItem(v3,2)
	local v1: Accessory = Instance.new("Accessory")
	v1.Name = "Action"
	v1.Parent = p1
	game.Debris:AddItem(v1,2)
	local v2: Accessory = Instance.new("Accessory")
	v2.Name = "HeavyAttack"
	v2.Parent = p1
	game.Debris:AddItem(v2,2)
	
	local Descendants = p1:GetDescendants()
	for i = 1,#Descendants do
		local v = Descendants[i]
		if v:IsA("BasePart") and v.Name~="Hilt" and v.Name ~= "LeftHilt" and v.Parent.Name ~= "RuneArmLeft" and v.Parent.Name ~= "RuneArmRight" and v.Name ~= "Back" and v.Name ~= "HumanoidRootPart"and v.Name ~= "AngelForm" then
			v.Transparency = 0
		end
	end
	
	wait()
	task.spawn(function()
		for num = 1,15 do
			p1:SetPrimaryPartCFrame(CFrame.new(Hit.Position)+Vector3.new(0,5,0))
			p1.HumanoidRootPart.Velocity = Vector3.new()
			p1.PrimaryPart.Velocity = Vector3.new()
			task.wait(1/30)
		end
	end)
	u3.magnitudeCheck(p1,HumanoidRootPart.Position,32,{
		mana = true,
		manastop = true,
		damage = 36,
		manaknockupself = true,
		manabreaker = true,
		physical = true,
		noparry = true,
		aoe = true,
	},false,true)
	local dropanimation = p1.Humanoid:LoadAnimation(script.Parent.Anim)
	dropanimation:Play()
	local ring = game.ReplicatedStorage.Assets.LightningDrop:Clone()
	ring.BrickColor = BrickColor.new'White'
	if playerdata.Race.Value == "Phoenix" then
		ring.BrickColor = BrickColor.new'Cool yellow'
	end
	ring.STRIKE:Destroy()
	ring.Position = Hit.Position
	if playerdata.Race.Value == "Phoenix" then
		ring.PointLight.Color = Color3.new(1, 1, 0.498039)
	end
	local PL: PointLight = game.ReplicatedStorage.Assets.ElectricLight:Clone()
	PL.Color = Color3.new(1,1,1)
	if playerdata.Race.Value == "Phoenix" then
		PL.Color = Color3.new(1, 1, 0.498039)
	end
	PL.Parent = ring
	ring.Parent = workspace.Thrown
	task.spawn(function()
		local tween = game.TweenService:Create(ring,TweenInfo.new(0.375),{
			Size = Vector3.new(65,20,20),
			Transparency = 1,
		})
		tween:Play()
		tween.Completed:Wait()
		ring.Transparency = 1
		game.Debris:AddItem(ring,2.8)
	end)
	wait(1.25)
	dropanimation:Stop()
	ring.PointLight.Enabled = false
	p1:FindFirstChild("SeraphFly"):Destroy()
	
	script.Parent:Destroy()
end)