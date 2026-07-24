local v1 = {}
local l__TagHumanoid__2 = game.ServerStorage.Requests.TagHumanoid
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
	if l__Parent__1:FindFirstChild("Unconscious") then
		return true
	end
	if l__Parent__1:FindFirstChild("Knocked") then
		return true
	end
	if l__Parent__1:FindFirstChild("Immortal") then
	else
		return
	end
	return true
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
	wait(0.2)
	p5.HumanoidRootPart.Swing:Play()
	wait(0.05)
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
	wait(0.2)
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
	
	wait(17)
	u3 = true
end
return v1