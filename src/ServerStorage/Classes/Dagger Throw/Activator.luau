local v1 = {}
local l__TweenService__2 = game:GetService("TweenService")
local l__Parent__1 = script.Parent.Parent
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		presentBlocks = {"Charge","Stun","ReturnStun","Action","NoWeapon","Blocking","SpellBlocking","Unconscious","Knocked","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local v3 = tick()
local l__TweenService__4 = game:GetService("TweenService")
local u2 = true
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid
function v1.Active(p1, p2, p3, p4)
	if ActionCheck()then
		return
	end
	if p1:FindFirstChild("Knocked")then
		return
	end
	if p1.Cooldowns:FindFirstChild("Dagger Throw") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Dagger Throw"
	CD.Value = 10
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 10)
	local l__HumanoidRootPart__5 = p1.HumanoidRootPart
	if p1.Name ~= "Shadow Buddy" then
		local l__Humanoid__6 = p1.Humanoid
		p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	end
	u2 = false
	task.wait(0.3)
	p1.HumanoidRootPart.DaggerSlash1:Play()
	local v8 = Instance.new("Accessory")
	v8.Name = "NoJump"
	v8.Parent = p1
	game:GetService("Debris"):AddItem(v8, 1)
	local a = Instance.new("Accessory")
	a.Name = "NoWeapon"
	a.Parent = p1
	game:GetService("Debris"):AddItem(a, 1)
	local v9 = Instance.new("Accessory")
	v9.Name = "Disarm"
	v9.Parent = p1
	game:GetService("Debris"):AddItem(v9, 10)
	local u5 =_G.MouseData(p2)
	if not u5 then
		return
	end
	local v10 = game.ServerStorage.Weapons.ThrowDagger:Clone()
	v10.Transparency = 0.5
	v10.Color = Color3.new(0, 0, 0)
	Instance.new("BodyVelocity").Parent = v10
	v10.TestTrail.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
	v10.TestTrail.Enabled = true
	v10.CFrame = p1.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1)
	v10.CFrame = CFrame.new(v10.Position, u5.Hit.p)
	v10.Parent = workspace.Thrown
	v10.BodyVelocity.Velocity = v10.CFrame.lookVector * 200
	v10:SetNetworkOwner(p2)
	local u6 = {}
	local u7 = false
	v10.Touched:Connect(function(p5)
		if not p5.Parent then
			return
		end
		if p5.Parent.Name == "Shadow Buddy" then
			return
		end
		if p5.Anchored and p5.Transparency ~= 1 then
			v10.ShadowEmitter:Emit(100)
			v10.Transparency = 1
			v10.Anchored = true
			if p4 then
				p4.Transparency = 0
				local v11 = script.Parent.ShadowEmitter:Clone()
				v11.Parent = p4
				v11:Emit(20)
				v11.Enabled = false
				game:GetService("Debris"):AddItem(v11, 2)
			end
			if p1:FindFirstChild("Disarm") then
				p1.Disarm:Destroy()
			end
			game:GetService("Debris"):AddItem(v10, 1)
		end
		if p5 and p5:IsDescendantOf(p1) then
			return
		end
		if p5 and p5.Name == v10.Name then
			return
		end
		local v12 = p5.Parent:FindFirstChild("Humanoid") or p5.Parent.Parent:FindFirstChild("Humanoid")
		if v12 and not u6[v12.Parent.Name] then
			if v12.Parent.Name == p2.Name then
				return
			end
			v10.Anchored = true
			v10.ShadowEmitter:Emit(100)
			v10.Transparency = 1
			v10.Anchored = true
			if p4 then
				p4.Transparency = 0
			end
			if v12.Parent.HumanoidRootPart:FindFirstChild("BloodHit") and v12.Parent.HumanoidRootPart:FindFirstChild("DaggerHit") then
				v12.Parent.HumanoidRootPart.DaggerHit:Play()
				v12.Parent.HumanoidRootPart.BloodHit:Emit(30)
			end
			if p1:FindFirstChild("Disarm") then
				p1.Disarm:Destroy()
			end
			u7 = true
			u6[v12.Parent.Name] = true
			l__TagHumanoid__4:Fire(p2.Character, v12.Parent,{
				slash = true, 
				dagger = true, 
				damage = 10, 
				daggerthrow = true,
				move = "Dagger Throw"
			})
			game:GetService("Debris"):AddItem(v10, 0.4)
		end
	end)
		task.wait(10)
	if v10 then
		game:GetService("Debris"):AddItem(v10, 1)
		if p1:FindFirstChild("Disarm") then
			p1.Disarm:Destroy()
		end
	end
	u2 = true
end
return v1