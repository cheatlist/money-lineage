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
	local u5 = nil
	if ActionCheck() then
		return
	end
	if p2.Backpack:FindFirstChild("ZedCool") then
		return
	end
	if p1:FindFirstChild("Knocked")then
		return true
	end
	if p1.Cooldowns:FindFirstChild("Bullseye") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Bullseye"
	CD.Value = 15
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 15)
	local l__HumanoidRootPart__5 = p1.HumanoidRootPart
	p4 = p1:FindFirstChild("ManaPistol", true)
	if p4 == nil then
		return
	end
	u2 = false
	local v6 = Instance.new("Accessory")
	v6.Name = "ZedCool"
	v6.Parent = p2.Backpack
	game:GetService("Debris"):AddItem(v6, 15)
	local v7 = Instance.new("Accessory")
	v7.Name = "Cooldown"
	v7.Parent = v6
	local v8 = Instance.new("Accessory")
	v8.Name = "HeavyAttack"
	v8.Parent = p1
	game:GetService("Debris"):AddItem(v8, 1.2)
	local v9 = Instance.new("Accessory")
	v9.Name = "NoJump"
	v9.Parent = p1
	game:GetService("Debris"):AddItem(v9, 1)
	local v10 = p1.Humanoid:LoadAnimation(script.Animation)
	v10:Play()
	v10:AdjustSpeed(1.5)
	task.wait(0.5)
	for v11 = 1, 1 do
		p1.Humanoid.AutoRotate = false
		u5 = p1
		spawn(function()
			task.wait(0.3)
			u5.Humanoid.AutoRotate = true
		end)
		local v12 = {}
		for v13, v14 in pairs(game.Workspace.Live:GetChildren()) do
			if v14:FindFirstChild("HumanoidRootPart") then
				local v15 = u5.HumanoidRootPart.CFrame:inverse() * v14.HumanoidRootPart.CFrame
				if not ((v14.HumanoidRootPart.Position - u5.HumanoidRootPart.Position).magnitude <= 30) then
					if (v14.HumanoidRootPart.Position - u5.HumanoidRootPart.Position).magnitude <= 60 and v14:FindFirstChild("BULLSEYE") and v14 ~= u5 then
						u5.Torso.CFrame = CFrame.new(u5.Torso.Position, v14.HumanoidRootPart.Position)
						v12[v14] = true
						local l__ManaPistol__16 = u5:FindFirstChild("ManaPistol", true)
						if l__ManaPistol__16 then
							local v17 = l__ManaPistol__16.Blast:Clone()
							v17.Parent = l__ManaPistol__16
							v17:Play()
							game:GetService("Debris"):AddItem(v17, 2)
						end
						local v18 = {
							physical = true, 
							mana = true, 
							damage = 20,
							move = "Bullseye"
						}
						if v14:FindFirstChild("BULLSEYE") then
							v18.damage = v18.damage * 2
						end
						local v19 = game.ServerStorage.Assets.LaserPart1:Clone()
						local l__Value__20 = p2.Backpack.ManaColor.Value
						v19.Color = Color3.new(l__Value__20.r, l__Value__20.g, l__Value__20.b)
						v19.PointLight.Color = Color3.new(l__Value__20.r, l__Value__20.g, l__Value__20.b)
						local v21 = game.ServerStorage.Assets.LaserPart2:Clone()
						game:GetService("Debris"):AddItem(v19, 0.25)
						game:GetService("Debris"):AddItem(v21, 0.25)
						local v22 = CFrame.new(math.random(-4, 4), 1, math.random(-22, -17))
						local v23 = game.ServerStorage.Ring:Clone()
						v23.CFrame = u5.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0))
						v19.CFrame = u5.HumanoidRootPart.CFrame * CFrame.new(0.25, 1, -18) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))
						v21.CFrame = u5.HumanoidRootPart.CFrame * CFrame.new(0.25, 1, -18) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))
						v19.Parent = game.Workspace.Thrown
						v23.Parent = game.Workspace.Thrown
						v21.Parent = game.Workspace.Thrown
						l__TweenService__3:Create(v19, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
							Transparency = 0, 
							Size = Vector3.new(25, 1.63, 1.69)
						}):Play()
						l__TweenService__3:Create(v21, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
							Transparency = 0, 
							Size = Vector3.new(23, 0.58, 0.52)
						}):Play()
						l__TweenService__3:Create(v23, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
							Transparency = 0, 
							Size = Vector3.new(2.496, 0.25, 2.496)
						}):Play()
						l__TagHumanoid__4:Fire(u5, v14, v18)
						if p4 ~= nil and p4:FindFirstChild("Hit") then
							local v24 = p4.Hit:Clone()
							v24.Parent = v14.HumanoidRootPart
							v24:Play()
							game:GetService("Debris"):AddItem(v24, 2)
						end
						task.wait(0.01)
					end
				elseif v14 ~= u5 then
					u5.Torso.CFrame = CFrame.new(u5.Torso.Position, v14.HumanoidRootPart.Position)
					v12[v14] = true
					local l__ManaPistol__16 = u5:FindFirstChild("ManaPistol", true)
					if l__ManaPistol__16 then
						local v17 = l__ManaPistol__16.Blast:Clone()
						v17.Parent = l__ManaPistol__16
						v17:Play()
						game:GetService("Debris"):AddItem(v17, 2)
					end
					local v18 = {
						physical = true, 
						mana = true, 
						damage = 20,
						move = "Bullseye"
					}
					if v14:FindFirstChild("BULLSEYE") then
						v18.damage = v18.damage * 2
					end
					local v19 = game.ServerStorage.Assets.LaserPart1:Clone()
					local l__Value__20 = p2.Backpack.ManaColor.Value
					v19.Color = Color3.new(l__Value__20.r, l__Value__20.g, l__Value__20.b)
					v19.PointLight.Color = Color3.new(l__Value__20.r, l__Value__20.g, l__Value__20.b)
					local v21 = game.ServerStorage.Assets.LaserPart2:Clone()
					game:GetService("Debris"):AddItem(v19, 0.25)
					game:GetService("Debris"):AddItem(v21, 0.25)
					local v22 = CFrame.new(math.random(-4, 4), 1, math.random(-22, -17))
					local v23 = game.ServerStorage.Ring:Clone()
					v23.CFrame = u5.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0))
					v19.CFrame = u5.HumanoidRootPart.CFrame * CFrame.new(0.25, 1, -18) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))
					v21.CFrame = u5.HumanoidRootPart.CFrame * CFrame.new(0.25, 1, -18) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))
					v19.Parent = game.Workspace.Thrown
					v23.Parent = game.Workspace.Thrown
					v21.Parent = game.Workspace.Thrown
					l__TweenService__3:Create(v19, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
						Transparency = 0, 
						Size = Vector3.new(25, 1.63, 1.69)
					}):Play()
					l__TweenService__3:Create(v21, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
						Transparency = 0, 
						Size = Vector3.new(23, 0.58, 0.52)
					}):Play()
					l__TweenService__3:Create(v23, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
						Transparency = 0, 
						Size = Vector3.new(2.496, 0.25, 2.496)
					}):Play()
					l__TagHumanoid__4:Fire(u5, v14, v18)
					if p4 ~= nil and p4:FindFirstChild("Hit") then
						local v24 = p4.Hit:Clone()
						v24.Parent = v14.HumanoidRootPart
						v24:Play()
						game:GetService("Debris"):AddItem(v24, 2)
					end
					task.wait(0.01)
				end
			end
		end
	end
	local l__ManaPistol__25 = u5:FindFirstChild("ManaPistol", true)
	if l__ManaPistol__25 then
		local u6 = p4
		spawn(function()
			u6 = l__ManaPistol__25
			if not u6 then
				return
			end
			if u6:FindFirstChild("Exhauste") then
				u6.Exhauste:Play()
			end
			if u6:FindFirstChild("Attack") then
				u6.Attack.Exhaust:Emit(100)
			end
			task.wait(0.2)
			if not u6 then
				return
			end
			local l__WOOP__26 = u6:FindFirstChild("WOOP")
			l__WOOP__26:Play()
			task.wait(0.5)
			l__WOOP__26:Stop()
		end)
	end
	task.wait(1/30)
	u2 = true
end
return v2
