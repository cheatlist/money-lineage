local v2 = {}
local l__Parent__1 = script.Parent.Parent
function ActionCheck()
	if not l__Parent__1:FindFirstChild("Humanoid") then
		return true
	end
	if l__Parent__1:FindFirstChild("Charge") then
		return true
	end
	if l__Parent__1:FindFirstChild("Stun") then
		return true
	end
	if l__Parent__1:FindFirstChild("ReturnStun") then
		return true
	end
	if l__Parent__1:FindFirstChild("Action") then
		return true
	end
	if l__Parent__1:FindFirstChild("Blocking") then
		return true
	end
	if l__Parent__1:FindFirstChild("SpellBlocking") then
		return true
	end
	if l__Parent__1:FindFirstChild("ActiveCast") then
		return true
	end
	if l__Parent__1:FindFirstChild("Unconscious")then
		return
	end
	if l__Parent__1:FindFirstChild("Knocked")then
		return
	end
	if l__Parent__1:FindFirstChild("Immortal") then
	else
		return
	end
	return true
end
local v3 = tick()
local u2 = true
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid
local l__TweenService__4 = game:GetService("TweenService")
local u5 = false
function v2.Active(p1, p2, p3, p4)
	if ActionCheck()then
		return
	end
	if p1:FindFirstChild("Knocked")then
		return
	end
	if p1.Cooldowns:FindFirstChild("Elegant Slash") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Elegant Slash"
	CD.Value = 11
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 11)
	local l__HumanoidRootPart__4 = p1.HumanoidRootPart
	local v5 = Instance.new("Accessory")
	v5.Name = "Action"
	Instance.new("Folder", v5).Name = "NoDelete"
	v5.Parent = p1
	game.Debris:AddItem(v5, 0.85)
	u2 = false
	local v6 = nil
	if not p4:FindFirstChild("LethalTrail") then
		v6 = script.Parent.LethalTrail:Clone()
		v6.Attachment0 = p4:WaitForChild("Attachment1")
		v6.Attachment1 = p4:WaitForChild("Attachment2")
		v6.Parent = p4
	elseif p4:FindFirstChild("LethalTrail") then
		v6 = p4:FindFirstChild("LethalTrail")
	end
	local v7 = p1.Humanoid:LoadAnimation(script.Parent:FindFirstChild("Animation"))
	spawn(function()
		if p4:FindFirstChild("TestTrail") then
			p4.TestTrail.Enabled = true
		end
		wait(1)
		if p4:FindFirstChild("TestTrail") then
			p4.TestTrail.Enabled = false
		end
	end)
	v7:Play()
	wait(0.55)
	v7:AdjustSpeed(0)
	spawn(function()
		wait(1)
		v7:AdjustSpeed(2)
	end)
	p1.HumanoidRootPart.OwlSlash:Play()
	spawn(function()
		wait(0.1)
		v6.Enabled = false
	end)
	if not p1:FindFirstChild("Stun")then
		local v8 = nil
		for _,v13 in pairs(workspace.Live:GetChildren())do
			local v14 = v13:IsA("Model") and v13 or nil
			if v14 and v14:FindFirstChild("Humanoid") and v14:FindFirstChild("HumanoidRootPart") and v14 ~= p1 and not v14:FindFirstChild("Hitboxes") and (l__HumanoidRootPart__4.Position - v14.HumanoidRootPart.Position).magnitude <= 15 and (l__HumanoidRootPart__4.CFrame:inverse() * v14.HumanoidRootPart.CFrame).Z < 0 then
				v8 = v14
				break
			end		
		end
		if v8 then
			for v15 = 1,8 do
				if v8.Humanoid.Health <= 0 then
					break
				end
				if (l__HumanoidRootPart__4.Position - v8.HumanoidRootPart.Position).magnitude <= 25 then
					wait(0.075)
					l__TagHumanoid__3:Fire(p1, v8, {
						physical = true,
						damage = 5,
						sword = true, 
						slash = true, 
						noenchant = true,
						manabreaker = true,
						move = "Elegant Slash"
					})
					local v16 = game.ReplicatedStorage.Assets.SlashRing:Clone()
					v16.Parent = game.Workspace.Thrown
					v16.CFrame = v8.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)))
					l__TweenService__4:Create(v16, TweenInfo.new(0.075, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						CFrame = v16.CFrame * CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90))), 
						Transparency = 1
					}):Play()
					game:GetService("Debris"):AddItem(v16, 0.5)
				end
			end
		end
	end
	u5 = false
	wait(10)
	u2 = true
end
return v2