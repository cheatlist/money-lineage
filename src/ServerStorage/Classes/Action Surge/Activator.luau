local assets = game.ServerStorage.Assets
local module = {}
local cd = false
function ActionCheck(p1)
	if p1.Humanoid.Health <= 0 then
		return true
	end
	if p1:FindFirstChild("Stun") then
		return true
	end
	if p1:FindFirstChild("ReturnStun") then
		return true
	end
	if p1:FindFirstChild("ActiveCast") then
		return true
	end
	if p1:FindFirstChild("Action") then
		return true
	end
	if p1:FindFirstChild("Blocking") then
		return true
	end
	if p1:FindFirstChild("Climbing") then
	else
		return
	end
	return true
end
module.Active = function(v3,player)
	if ActionCheck(v3)then
		return
	end
	if v3.Cooldowns:FindFirstChild("Action Surge") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Value = 15
	CD.Name = "Action Surge"
	CD.Parent = v3.Cooldowns
	game.Debris:AddItem(CD, 15)
	cd = true
	local v1 = Instance.new("Accessory")
	v1.Name = "ActionSurgeEff"
	v1.Parent = v3
	game.Debris:AddItem(v1,1.7)
	local p = assets.SurgeParticle:Clone()
	local s = assets.SurgeSound:Clone()
	p.Parent = v3.HumanoidRootPart
	s.Parent = v3.HumanoidRootPart
	s:Play()
	game.Debris:AddItem(s,2)
	game.Debris:AddItem(p,3)
	wait(2)
	p.Enabled = false
end
return module