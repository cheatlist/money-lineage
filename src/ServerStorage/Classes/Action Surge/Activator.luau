local assets = game.ServerStorage.Assets
local module = {}
local cd = false
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(p1)
	return ActionCheckModule(p1, {
		presentBlocks = {"Stun","ReturnStun","ActiveCast","Action","Blocking","Climbing"},
		healthAtOrBelow = 0,
	})
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
	task.wait(2)
	p.Enabled = false
end
return module