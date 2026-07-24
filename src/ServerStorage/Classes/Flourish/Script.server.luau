function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local u8 = game.ServerStorage.Requests.TagHumanoid
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
		healthBelow = 5,
	})
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	local l__HumanoidRootPart__4 = p1.HumanoidRootPart
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Flourish") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Flourish"
	CD.Value = 12
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 12)
	canuse = false
	local v5 = Instance.new("Accessory")
	v5.Name = "Action"
	Instance.new("Folder", v5).Name = "NoDelete"
	v5.Parent = p1
	game.Debris:AddItem(v5, 0.4)
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local v8 = nil
	local HumanoidRootPart = p1.HumanoidRootPart
	HumanoidRootPart:FindFirstChild("FULLCOUNTER"):Play()
	p1.HumanoidRootPart.FlourishEff.A:Emit(10)
	local v16 = game.ReplicatedStorage.Assets.AirSwirl1:Clone()
	v16.Parent = game.Workspace.Thrown
	v16.Position = (p1["Right Leg"].Position + Vector3.new(0.2, -1, 0))
	v16.Size = v16.Size * 1.25
	TweenService:Create(v16, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { 
		Transparency = 1
	}):Play()
	game:GetService("Debris"):AddItem(v16, 0.5)
	local b17 = game.ReplicatedStorage.Assets.AirSwirl2:Clone()
	b17.Parent = game.Workspace.Thrown
	b17.Position = (p1["Right Leg"].Position + Vector3.new(0.2, -1, 0))
	b17.Size = b17.Size * 1.25
	TweenService:Create(b17, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	game:GetService("Debris"):AddItem(b17, 0.5)
	task.spawn(function()
		local t = 0
		while t < 0.5 do
			v16.CFrame *= CFrame.Angles(0, math.rad(10), 0)
			b17.CFrame *= CFrame.Angles(0, math.rad(10), 0)
			t += wait()
		end
	end)
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	local v8 = nil
	for _,v13 in pairs(workspace.Live:GetChildren())do
		local v14 = v13:IsA("Model") and v13 or nil
		if v14 and v14:FindFirstChild("Humanoid") and v14:FindFirstChild("HumanoidRootPart") and v14 ~= p1 and not v14:FindFirstChild("Hitboxes") and (l__HumanoidRootPart__4.Position - v14.HumanoidRootPart.Position).magnitude <= 40 then
			v8 = v14
			break
		end		
	end
	local v10 = {}
	for v24, v25 in pairs(game.Workspace.Live:GetChildren()) do
		if not v10[v25] and v25:FindFirstChild("Torso") and (v25.Torso.Position - p1.Torso.Position).magnitude <= 10 and v25 ~= p1 then
			v10[v25] = true;
			for v26 = 1, 2 do
				if v26 == 2 then
					v5:Destroy()
				end
				u8:Fire(p1, v25, {
					physical = true,
					damage = 15,
					sword = true, 
					slash = true, 
					move = "Flourish"
				});
				wait(0.05)
			end;
		end;
	end;
	wait(12)
	canuse = true
end)