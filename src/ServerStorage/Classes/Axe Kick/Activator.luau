local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(p1)
	return ActionCheckModule(p1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Stun","ReturnStun","ActiveCast","Action","Immortal","Blocking","SpellBlocking","Climbing"},
		healthAtOrBelow = 0,
	})
end
function ray(p2, p3, p4, p5)
	local v3, v4, v5 = workspace:FindPartOnRay(Ray.new(p2, CFrame.new(p2, p3).LookVector * p4), p5)
	return v3, v4, v5
end
local v6 = {}
local u1 = true
local l__Parent__2 = script.Parent
local u3 = require(game.ServerScriptService.Modules.HitDetection)
function v6.Active(p6, p7, p8, p9)
	if p6:FindFirstChild("Knocked") then
		return
	end
	if ActionCheck(p6) then
		return
	end
	if p6.Cooldowns:FindFirstChild("Axe Kick") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Axe Kick"
	CD.Value = 9
	CD.Parent = p6.Cooldowns
	game.Debris:AddItem(CD, 9)
	u1 = false
	local v7 = Instance.new("Accessory")
	v7.Name = "Action"
	v7.Parent = p6
	local v123 = Instance.new("Accessory")
	v123.Name = "HyperArmor"
	v123.Parent = p6
	game.Debris:AddItem(v123, 0.175)
	local v1234 = Instance.new("Accessory")
	v1234.Name = "truehyper"
	v1234.Parent = p6
	game.Debris:AddItem(v1234, 0.175)
	game:GetService("Debris"):AddItem(v7, 0.7)
	local v9 = Instance.new("Accessory")
	v9.Name = "Planted"
	v9.Parent = p6
	game.Debris:AddItem(v9, 0.7)
	p6.Humanoid:LoadAnimation(l__Parent__2.Anim):Play()
	p6.HumanoidRootPart.EpicDemon:Play()
	task.wait(0.175)
	local v10 = Instance.new("Attachment")
	v10.Name = "AxeAttach"
	v10.Position = Vector3.new(0, -1, 0)
	v10.Parent = p6["Right Leg"]
	l__Parent__2.Particle:Clone().Parent = v10
	local v11 = tick()
	local v12 = false
	while true do
		if tick() - v11 >= 0.2 and not v12 then
			v12 = true
			p6.HumanoidRootPart.Swing:Play()
		end
		task.wait()
		if tick() - v11 >= 0.5 then
			break
		end	
	end
	local v13 = game.ServerStorage.Assets.SMASH2:Clone()
	v13.Parent = game.Workspace.Thrown
	v13.Position = (p6["Right Leg"].CFrame * CFrame.new(0, -1, 0)).p
	v13.Anchored = true
	v13.DUST:Emit(40)
	v13.Sound:Play()
	game.Debris:AddItem(v13, 1)
	v10:Destroy()
	task.wait(0.05)
	u3.magnitudeCheck(p6,p6.HumanoidRootPart.Position,15,{
		fist = true,
		damage = 10,
		physical = true,
		blockbreak = true, 
		knockback = true, 
		executes = true, 
		noparry = true,
		hyperarmor = true,
		axe = true,
		move = "Axe Kick"
	}, true)
	task.wait(8)
	u1 = true
end
return v6