local v1 = {}
local function sub(...)
	coroutine.wrap(...)()
end
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
v1.upperbound = 100
v1.lowerbound = 60
v1.signs = 0
v1.cost = 100
local u1 = false
local l__TweenService__2 = game:GetService("TweenService")
function v1.Activate(p1, p2, p3, p4)
	if u1 == true then
		return
	end
	if p2:FindFirstChild("CounterSpell") then
		return
	end
	if p2.Cooldowns:FindFirstChild("Tempest Soul") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Tempest Soul"
	CD.Value = 15.75
	CD.Parent = p2.Cooldowns
	game.Debris:AddItem(CD, 15.75)
	u1 = true
	local l__Mana__5 = p2.Mana
	local l__Value__6 = game.ServerStorage.PlayerData[game.Players:GetPlayerFromCharacter(p2).Name].ManaColor.Value
	local v7 = 5.75
	local v8 = Instance.new("Accessory")
	v8.Name = "CounterSpell"
	v8.Parent = p2
	game:GetService("Debris"):AddItem(v8, v7)
	local v9 = Instance.new("IntValue")
	v9.Name = "SpeedBoost"
	v9.Value = 8
	v9.Parent = p2.Boosts
	game:GetService("Debris"):AddItem(v9, v7)
	local v10 = game.ServerStorage.Assets.CounterField:Clone()
	v10.CFrame = p2.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(90), math.rad(90))
	v10.Parent = game.Workspace.Thrown
	v10.Weld.Part0 = p2.HumanoidRootPart
	v10.Weld.Part1 = v10
	l__TweenService__2:Create(v10.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Scale = Vector3.new(3, 3, 3)
	}):Play()
	l__TweenService__2:Create(v10, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	p2.HumanoidRootPart.CounterSpell:Play()
	sub(function()
		wait(v7)
		for v11, v12 in pairs(v10:GetChildren()) do
			if v12:IsA("Beam") then
				v12.Enabled = false
			end
		end
		p2.HumanoidRootPart.CounterSpellOff:Play()
		wait(2)
		game:GetService("Debris"):AddItem(v10, v7)
	end)
	task.spawn(function()
		wait(v7 + 10)
		u1 = false
	end)
end
return v1