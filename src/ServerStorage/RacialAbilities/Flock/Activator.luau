local v1 = {}
local l__Parent__2 = script.Parent
function ActionCheck(p1)
	if not p1:FindFirstChild("Humanoid") then
		return true
	end
	if p1:FindFirstChild("Stun") then
		return true
	end
	if p1:FindFirstChild("ReturnStun") then
		return true
	end
	if p1:FindFirstChild("Action") then
		return true
	end
	if p1:FindFirstChild("Blocking") then
		return true
	end
	if p1:FindFirstChild("SpellBlocking") then
		return true
	end
	if p1.Humanoid.Health == 0 then
		return true
	end
	if not p1:FindFirstChild("Grabbed") then
		if p1:FindFirstChild("Grabbing") then
			return true
		end
	else
		return true
	end
	if p1:FindFirstChild("Climbing") then
		return true
	end
	if p1:FindFirstChild("ActiveCast") then
		return true
	end
	if p1:FindFirstChild("Unconscious") then
		return true
	end
	if p1:FindFirstChild("Knocked") then
	else
		return
	end
	return true
end
local v3 = Instance.new("NumberValue")
v3.Name = "Transparency"
v3.Value = 1
v3.Parent = l__Parent__2
local u1 = true
local l__PhysicsService__2 = game:GetService("PhysicsService")
local l__TweenService__3 = game:GetService("TweenService")
function v1.Active(p2, p3, p4, p5)
	if ActionCheck(p2) then
		return
	end
	if u1 == false then
		return
	end
	u1 = false
	local v4 = script.Sound1:Clone()
	v4.Parent = p2.HumanoidRootPart
	v4:Play()
	game:GetService("Debris"):AddItem(v4, 4)
	local v5 = script.Sound2:Clone()
	v5.Parent = p2.HumanoidRootPart
	v5:Play()
	game:GetService("Debris"):AddItem(v5, 4)
	for v9,v10 in pairs(game.ServerStorage.CrowParticles:GetChildren())do
		if v10.Name:match("Emit") then
			local v11 = v10:Clone()
			v11.Parent = p2.HumanoidRootPart
			v11.Enabled = true
			game:GetService("Debris"):AddItem(v11, 4)
			spawn(function()
				wait(0.5)
				v11.Enabled = false
			end)
		end
		if v10.Name:match("Return") then
			spawn(function()
				wait(2)
				local v12 = v10:Clone()
				v12.Parent = p2.HumanoidRootPart
				v12.Enabled = true
				game:GetService("Debris"):AddItem(v12, 4)
				wait(0.5)
				v12.Enabled = false
			end)
		end
	end
	for v13, v14 in pairs(p2:GetDescendants()) do
		if v14:IsA("BasePart") and v14.Transparency ~= 1 then
			if v14:IsA("Part") then
				for v15 = 1, math.ceil(v14.Size.x * v14.Size.y * v14.Size.z) do
					local v16 = v14:Clone()
					v16.Transparency = 0
					v16:ClearAllChildren()
					v16.Size = Vector3.new(1, 1, 1)
					v16.Color = Color3.fromRGB(0, 0, 0)
					v16.CFrame = v14.CFrame
					v16.CanCollide = false
					v16.Anchored = true
					v16.Parent = game.Workspace.Thrown
					l__TweenService__3:Create(v16, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Size = Vector3.new(0, 0, 0), 
						Transparency = 1, 
						CFrame = p2.HumanoidRootPart.CFrame * CFrame.new(math.random(-10, 10), 10, math.random(-10, 10))
					}):Play()
					game.Debris:AddItem(v16, 0.5)
				end
			end
		end
	end
	v3.Parent = p2.Boosts
	spawn(function()
		wait(2)
		v3.Parent = l__Parent__2
	end)
	local v173 = Instance.new("Accessory")
	v173.Name = "canmanashield"
	v173.Parent = p2
	game:GetService("Debris"):AddItem(v173, 2)
	local v17 = Instance.new("Accessory")
	v17.Name = "Immortal"
	v17.Parent = p2
	game:GetService("Debris"):AddItem(v17, 2)
	local v18 = Instance.new("Accessory")
	v18.Name = "NoAttack"
	v18.Parent = p2
	game:GetService("Debris"):AddItem(v18, 2)
	local v19 = Instance.new("IntValue")
	v19.Name = "SpeedBoost"
	v19.Value = 13
	v19.Parent = p2.Boosts
	game:GetService("Debris"):AddItem(v19, 2)
	wait(30)
	u1 = true
end
return v1