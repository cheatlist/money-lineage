local v2 = {}
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__1 = script.Parent.Parent
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local v4 = tick()
local l__TweenService__2 = game:GetService("TweenService")
function v2.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return
	end
	if p2.Backpack:FindFirstChild("BombbombCool") then
		return
	end
	if p1:FindFirstChild("Knocked")then
		return true
	end
	local l__HumanoidRootPart__5 = p1.HumanoidRootPart
	local l__Humanoid__6 = p1.Humanoid
	p4 = p1:FindFirstChild("ManaPistol", true)
	if p4 == nil then
		return
	end
	p1.Humanoid:LoadAnimation(script.Parent.Animation):Play()
	local v7 = Instance.new("Accessory")
	v7.Name = "BombbombCool"
	v7.Parent = p2.Backpack
	game:GetService("Debris"):AddItem(v7, 10)
	local v8 = Instance.new("Accessory")
	v8.Name = "Cooldown"
	v8.Parent = v7
	task.wait(0.3)
	local v9 = game.ServerStorage.Assets.ManaGrenade:Clone()
	local l__Value__10 = p2.Backpack.ManaColor.Value
	v9.Color = Color3.new(l__Value__10.r, l__Value__10.g, l__Value__10.b)
	if v9:FindFirstChild("Trail") then
		v9.Trail.Color = ColorSequence.new(Color3.new(l__Value__10.r, l__Value__10.g, l__Value__10.b))
	end
	v9.CFrame = p1.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
	local v11 = Instance.new("BodyVelocity")
	v11.MaxForce = Vector3.new(1000000, 1000000, 1000000)
	v11.Velocity = (p1.HumanoidRootPart.CFrame.lookVector + Vector3.new(0, 1, 0)) * 50
	v11.Parent = v9
	game.Debris:AddItem(v11, 0.1)
	v9.Parent = game.Workspace.Thrown
	v9:SetNetworkOwner(nil)
	v9.Touched:Connect(function(p5)
		if p5.Parent == game.Workspace.Thrown then
			return
		end
		if p5.Parent == p1 or p5.Parent.Parent == p1 or p5 == p1 then
			return
		end
		local v12 = game.ServerStorage.Assets.BombBlast:Clone()
		local l__Value__13 = p2.Backpack.ManaColor.Value
		v12.Color = Color3.new(l__Value__13.r, l__Value__13.g, l__Value__13.b)
		v12.SelectionSphere.Color3 = Color3.new(l__Value__13.r, l__Value__13.g, l__Value__13.b)
		v12.CFrame = v9.CFrame
		v9:Destroy()
		v12.Size = Vector3.new(0, 0, 0)
		v12.Parent = game.Workspace.Thrown
		v12.Sound:Play()
		l__TweenService__2:Create(v12, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Transparency = 1, 
			Size = Vector3.new(45, 45, 45)
		}):Play()
		l__TweenService__2:Create(v12.SelectionSphere, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		game.Debris:AddItem(v12, 2)
		for v14, v15 in pairs(game.Workspace.Live:GetChildren()) do
			if (v15.HumanoidRootPart.Position - v12.Position).magnitude <= 25 and v15 ~= p1 and not v15:FindFirstChild("Blocking") then
				local v16 = Instance.new("Accessory")
				v16.Name = "BULLSEYE"
				v16.Parent = v15
				game.Debris:AddItem(v16, 4)
				game.ServerStorage.Requests.TagHumanoid:Fire(p1, v15, {
					manaknockupself = true, 
					mana = true, 
					damage = 35, 
					manadisarm = true,
					move = "Mana Grenade"
				})
			end
		end
	end)
end
return v2
