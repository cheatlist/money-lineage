function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
	end
	return
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if p1.Cooldowns:FindFirstChild("Spin Kick") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Spin Kick"
	CD.Value = 9
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 9)
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local p3 = false
	p1.Humanoid:UnequipTools()
	p1.Humanoid:LoadAnimation(script.Parent.Anim):Play()
	HumanoidRootPart.Shoryu1:Play()
	HumanoidRootPart.AkumaEmit:Emit(26)
	local v3 = Instance.new("Accessory")
	v3.Name = "Action"
	v3.Parent = p1
	game.Debris:AddItem(v3,1)
	wait(0.4)
	local v4 = false
	if not p1:FindFirstChild("NoDam")then
		local hit = u3.magnitudeCheck(p1,HumanoidRootPart.Position,8.5,{
			physical = true,
			fist = true,
			injury = "rib cage",
			damage = 6.5,
			move = "Spin Kick"
		})
		if hit then
			for i,v in pairs(p1:GetChildren()) do
				if v:IsA("Accessory") and v.Name == "Stun" or v.Name == "Action" then
					v:Destroy();
				end
			end
		end
	end
	wait(9)
	canuse = true
end)