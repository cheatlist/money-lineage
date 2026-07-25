local v1 = {}
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
local l__Parent__1 = script.Parent.Parent
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck()
	return ActionCheckModule(l__Parent__1, {
		absentBlocks = {"Humanoid"},
		presentBlocks = {"Charge","Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local v3 = tick()
local l__TweenService__4 = game:GetService("TweenService")
local u3 = true
local u4 = require(game.ServerScriptService.Modules.HitDetection)
function v1.Active(p5, p6, p7, p8)
	if p5:FindFirstChild("Knocked") then
		return
	end
	if ActionCheck() then
		return
	end
	if p5.Cooldowns:FindFirstChild("Chain Pull") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Chain Pull"
	CD.Value = 18
	CD.Parent = p5.Cooldowns
	game.Debris:AddItem(CD, 18)
	local v8 = Instance.new("Folder")
	v8.Name = "Action"
	v8.Parent = p5
	p5.HumanoidRootPart.SpearEmit:Emit(30)
	game:GetService("Debris"):AddItem(v8, 1)
	p5.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	p5.HumanoidRootPart.SwordCharge:Play()
	task.wait(0.2)
	p5.HumanoidRootPart.Swing:Play()
	task.wait(0.05)
	local l__HumanoidRootPart__9 = p5.HumanoidRootPart
	if not p5:FindFirstChild("Stun") then
		u4.magnitudeCheck(p5,l__HumanoidRootPart__9.Position,20,{
			physical = true, 
			spear = true, 
			slash = true, 
			damage = 7.5,
			bypassfischdodge = true,
			move = "Chain Pull"
		}, true, false, true);
	end
	task.wait(0.2)
	p5.HumanoidRootPart.Swing:Play()
	if not p5:FindFirstChild("Stun") then
		u4.magnitudeCheck(p5,l__HumanoidRootPart__9.Position,18,{
			physical = true, 
			spear = true, 
			slash = true, 
			damage = 10, 
			churchpull = true,
			bypassfischdodge = true,
			move = "Chain Pull"
		}, true, false, true);
	end
	
	task.wait(17)
	u3 = true
end
return v1