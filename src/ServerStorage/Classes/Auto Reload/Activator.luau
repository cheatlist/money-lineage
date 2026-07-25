local v2 = {}
local l__TagHumanoid__3 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__1 = script.Parent.Parent
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","HeavyAttack","Unconscious","Knocked","Immortal"},
	})
end
local v4 = tick()
local l__TweenService__5 = game:GetService("TweenService")
local u2 = true
function v2.Active(p1, p2, p3, p4)
	if ActionCheck() then
		return
	end
	if p1.Cooldowns:FindFirstChild("Auto Reload") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Auto Reload"
	CD.Value = 30
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 30)
	local l__HumanoidRootPart__6 = p1.HumanoidRootPart
	p4 = p1:FindFirstChild("ManaPistol", true)
	if p4 == nil then
		return
	end
	u2 = false
	local v7 = Instance.new("Accessory")
	v7.Name = "HeavyAttack"
	game:GetService("Debris"):AddItem(v7, 1)
	v7.Parent = p1
	p1.Humanoid:LoadAnimation(script.Animation):Play()
	task.wait(0.5)
	for v8, v9 in pairs(p2.Backpack:GetDescendants()) do
		if v9:FindFirstChild("Cooldown") then
			v9:Destroy()
		end
	end
	spawn(function()
		if not p4 then
			return
		end
		if p4:FindFirstChild("Exhauste") then
			p4.Exhauste:Play()
		end
		if p4:FindFirstChild("Attack") then
			p4.Attack.Exhaust:Emit(100)
		end
		task.wait(0.2)
		if not p4 then
			return
		end
		local l__WOOP__10 = p4:FindFirstChild("WOOP")
		l__WOOP__10:Play()
		task.wait(0.5)
		l__WOOP__10:Stop()
	end)
	task.wait(30)
	u2 = true
end
return v2
