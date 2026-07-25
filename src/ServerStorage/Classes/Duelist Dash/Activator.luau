local v2 = {}
local l__Parent__1 = script.Parent.Parent
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","HeavyAttack","Unconscious","Knocked","Immortal"},
	})
end
local v3 = tick()
local u2 = true
local l__TweenService__3 = game:GetService("TweenService")
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid
function v2.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return
	end
	if p1:FindFirstChild("HeavyAttack") then
		return
	end
	if p2.Backpack:FindFirstChild("DuelCool") then
		return
	end
	if p1:FindFirstChild("Knocked")then
		return
	end
	p4 = p1:FindFirstChild("ManaPistol",true)
	if p4 == nil then
		return
	end
	local v4 = Instance.new("Accessory")
	v4.Name = "DuelCool"
	v4.Parent = p2.Backpack
	game:GetService("Debris"):AddItem(v4, 15)
	local v5 = Instance.new("Accessory")
	v5.Name = "Cooldown"
	v5.Parent = v4
	local v6 = Instance.new("Accessory")
	v6.Name = "HeavyAttack"
	game:GetService("Debris"):AddItem(v6, 1)
	v6.Parent = p1
	u2 = false
	p1.Humanoid:LoadAnimation(script.Animation):Play()
	task.wait(0.3)
	local v7 = Instance.new("BodyVelocity")
	game.CollectionService:AddTag(v7, "AllowedBM")
	v7.MaxForce = Vector3.new(100000000, 100000000, 100000000)
	v7.Velocity = p1.HumanoidRootPart.CFrame.LookVector * Vector3.new(1, 0, 1) * 100
	v7.Parent = p1.HumanoidRootPart
	game.Debris:AddItem(v7, 0.25)
	task.wait(0.25)
	for v8 = 1, 15 do
		task.wait(1/30)
		local l__ManaPistol__9 = p1:FindFirstChild("ManaPistol", true)
		if l__ManaPistol__9 then
			local v10 = l__ManaPistol__9.Blast:Clone()
			v10.Parent = l__ManaPistol__9
			v10:Play()
			game:GetService("Debris"):AddItem(v10, 2)
		end
		local v11 = game.ServerStorage.Assets.LaserPart1:Clone()
		local l__Value__12 = p2.Backpack.ManaColor.Value
		v11.Color = Color3.new(l__Value__12.r, l__Value__12.g, l__Value__12.b)
		v11.PointLight.Color = Color3.new(l__Value__12.r, l__Value__12.g, l__Value__12.b)
		local v13 = game.ServerStorage.Assets.LaserPart2:Clone()
		game:GetService("Debris"):AddItem(v11, 0.25)
		game:GetService("Debris"):AddItem(v13, 0.25)
		local v14 = CFrame.new(math.random(-4, 4), 1, math.random(-22, -17))
		local v15 = game.ServerStorage.Ring:Clone()
		v15.CFrame = p1.HumanoidRootPart.CFrame * v14 * CFrame.new(0, 0, 8) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0))
		v11.CFrame = p1.HumanoidRootPart.CFrame * v14 * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))
		v13.CFrame = p1.HumanoidRootPart.CFrame * v14 * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))
		v11.Parent = game.Workspace.Thrown
		v15.Parent = game.Workspace.Thrown
		v13.Parent = game.Workspace.Thrown
		game:GetService("Debris"):AddItem(v15, 0.25)
		l__TweenService__3:Create(v11, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
			Transparency = 0, 
			Size = Vector3.new(25, 1.63, 1.69)
		}):Play()
		l__TweenService__3:Create(v13, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
			Transparency = 0, 
			Size = Vector3.new(23, 0.58, 0.52)
		}):Play()
		l__TweenService__3:Create(v15, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
			Transparency = 0, 
			Size = Vector3.new(2.496, 0.25, 2.496)
		}):Play()
		local v16 = {}
		for v17, v18 in pairs(game.Workspace.Live:GetChildren()) do
			if v18:FindFirstChild("HumanoidRootPart") then
				local v19 = p1.HumanoidRootPart.CFrame:inverse() * v18.HumanoidRootPart.CFrame
				if v19.Z < 0 and v19.Z > -25 and math.abs(v19.X) < 10 and math.abs(v19.Y) < 10 then
					v16[v18] = true
					l__TagHumanoid__4:Fire(p1, v18, {
						physical = true, 
						mana = true, 
						damage = 2.8, 
						noenchant = true,
						move = "Duelist Dash"
					})
					if p4 ~= nil and p4:FindFirstChild("Hit") then
						local v20 = p4.Hit:Clone()
						v20.Parent = v18.HumanoidRootPart
						v20:Play()
						game:GetService("Debris"):AddItem(v20, 2)
					end
				end
			end
		end
	end
	local l__ManaPistol__21 = p1:FindFirstChild("ManaPistol", true)
	if l__ManaPistol__21 then
		local u5 = p4
		spawn(function()
			u5 = l__ManaPistol__21
			if not u5 then
				return
			end
			if u5:FindFirstChild("Exhauste") then
				u5.Exhauste:Play()
			end
			if u5:FindFirstChild("Attack") then
				u5.Attack.Exhaust:Emit(100)
			end
			task.wait(0.2)
			if not u5 then
				return
			end
			local l__WOOP__22 = u5:FindFirstChild("WOOP")
			l__WOOP__22:Play()
			task.wait(0.5)
			l__WOOP__22:Stop()
		end)
	end
end
return v2
