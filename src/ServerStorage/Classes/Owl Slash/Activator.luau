local v2 = {}
local v3 = require(game.ServerScriptService.Modules.HitDetection)
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(l__Parent__1)
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","Unconscious","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local v4 = tick()
local u2 = true
local l__TweenService__3 = game:GetService("TweenService")
local l__TagHumanoid__4 = game.ServerStorage.Requests.TagHumanoid
function v2.Active(p1, p2, p3, p4)
	p1 = script.Parent.Parent
	p2 = game.Players:GetPlayerFromCharacter(p1)
	if ActionCheck(p1) then
		return
	end
	if p1:FindFirstChild("Knocked")then
		return
	end
	if p1.Cooldowns:FindFirstChild("Owl Slash") then
		return
	end
	if p1.Humanoid:GetState() == Enum.HumanoidStateType.Jumping or p1:FindFirstChild("NoJump") then
		return
	end
	if not p1:FindFirstChild("Grappled")then
		return
	end
	local damage: number = 20
	if tostring(p2) == "DevZse" then
		damage *= 2.5
	end
	local v5 = Instance.new("Accessory")
	v5.Name = "NoJump"
	v5.Parent = p1
	game:GetService("Debris"):AddItem(v5, 0.5)
	local l__HumanoidRootPart__6 = p1.HumanoidRootPart
	local l__Humanoid__7 = p1.Humanoid
	local v8
	for i,NPC in pairs(workspace.Live:GetChildren()) do
		local HRP = NPC:FindFirstChild('HumanoidRootPart')
		if HRP and(HRP.Position - l__HumanoidRootPart__6.Position).Magnitude <= 70 and NPC:FindFirstChild("AIRSLASH") and NPC~=p1 then
			v8 = NPC
		end
	end
	if v8 and u2 == true then
		u2 = false
		p1.Humanoid:LoadAnimation(script.Animation):Play()
		spawn(function()
			if p4 and p4:FindFirstChild("TestTrail") then
				p4.TestTrail.Enabled = true
				task.wait(0.5)
				if p4 and p4:FindFirstChild("TestTrail") then
					p4.TestTrail.Enabled = false
				end
			end
		end)
		p1.HumanoidRootPart.OwlSlash:Play()
		local v11 = script.Feathers:Clone()
		v11.Parent = p1.Torso
		game:GetService("Debris"):AddItem(v11, 1.5)
		task.wait(0.5)
		local v12 = script:FindFirstChild("GreatSlash"):Clone()
		v12.CFrame = v8.HumanoidRootPart.CFrame * CFrame.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)) * CFrame.Angles(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
		v12.Parent = game.Workspace
		game.Debris:AddItem(v12, 1)
		local v13 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		l__TweenService__3:Create(v12:WaitForChild("Mesh"), v13, {
			Scale = Vector3.new(1, 1, 1)
		}):Play()
		l__TweenService__3:Create(v12, v13, {
			Transparency = 1
		}):Play()
		l__TagHumanoid__4:Fire(p1, v8, {
			physical = true, 
			damage = damage, 
			slash = true, 
			blockbreak = true, 
			nomove = true, 
			executes = true, 
			nobackstab = true,
			move = "Owl Slash"
		})
		u2 = true
		if not p1:FindFirstChild("ShinobiAwakening") then
			local CD = Instance.new("NumberValue")
			CD.Name = "Owl Slash"
			CD.Value = 10
			CD.Parent = p1.Cooldowns
			game.Debris:AddItem(CD, 10)
			return
		end
	else
		return
	end
	task.wait(1)
	u2 = true
end
return v2