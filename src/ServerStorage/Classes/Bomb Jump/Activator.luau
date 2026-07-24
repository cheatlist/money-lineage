local v2 = {}
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__1 = script.Parent.Parent
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","HeavyAttack","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local v4 = tick()
local u2 = true
local l__TweenService__3 = game:GetService("TweenService")
function v2.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return
	end
	if p2.Backpack:FindFirstChild("BombCool") then
		return
	end
	if p1:FindFirstChild("Knocked")then
		return true
	end
	if p1.Cooldowns:FindFirstChild("Bomb Jump") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Bomb Jump"
	CD.Value = 20
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 20)
	u2 = false
	local l__Humanoid__5 = p1.Humanoid
	p4 = p1:FindFirstChild("ManaPistol", true)
	if p4 == nil then
		return
	end
	local v6 = p1.Humanoid:LoadAnimation(script.Parent.Animation)
	v6:Play()
	v6:AdjustSpeed(1.5)
	local v7 = Instance.new("Accessory")
	v7.Name = "BombCool"
	v7.Parent = p2.Backpack
	game:GetService("Debris"):AddItem(v7, 15)
	local v8 = Instance.new("Accessory")
	v8.Name = "Cooldown"
	v8.Parent = v7
	wait(0.1)
	local v9 = game.ServerStorage.Assets.BombBlast:Clone()
	local l__Value__10 = p2.Backpack.ManaColor.Value
	v9.Color = Color3.new(l__Value__10.r, l__Value__10.g, l__Value__10.b)
	v9.SelectionSphere.Color3 = Color3.new(l__Value__10.r, l__Value__10.g, l__Value__10.b)
	v9.CFrame = p1.HumanoidRootPart.CFrame
	v9.Size = Vector3.new(0, 0, 0)
	v9.Parent = game.Workspace.Thrown
	v9.Sound:Play()
	l__TweenService__3:Create(v9, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),{
		Transparency = 1, 
		Size = Vector3.new(27, 27, 27)
	}):Play()
	l__TweenService__3:Create(v9.SelectionSphere, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	game.Debris:AddItem(v9, 2)
	local v11 = Instance.new("BodyVelocity")
	v11.Name = "GrappleVelocity"
	game.CollectionService:AddTag(v11, "AllowedBM")
	v11.Parent = p1.HumanoidRootPart
	v11.MaxForce = Vector3.new(1000000, 1000000, 1000000)
	v11.Velocity = Vector3.new(0, 60, 0) + p1.HumanoidRootPart.CFrame.lookVector * 100
	game.Debris:AddItem(v11, 0.3)
	local v12 = Instance.new("Accessory")
	v12.Name = "NoFall"
	v12.Parent = p2.Backpack
	game.Debris:AddItem(v12, 1)
	for v13, v14 in pairs(game.Workspace.Live:GetChildren()) do
		if (v14.HumanoidRootPart.Position - p1.HumanoidRootPart.Position).magnitude <= 18 and v14 ~= p1 and not v14:FindFirstChildOfClass("ForceField") then
			game.ServerStorage.Requests.TagHumanoid:Fire(p1, v14, {
				manaknockup = true, 
				mana = true, 
				damage = 20,
				move = "Bomb Jump"
			})
		end
	end
	wait(5)
	u2 = true
end
return v2