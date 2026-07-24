function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.HitDetection)
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"EquipWarmup","Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
		healthBelow = 5,
	})
end
local canuse = true
local enabled = false
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local Ugpraded = p2.Backpack:FindFirstChild("DragonBloodUpgrade")
	if not enabled and HumanoidRootPart.DragonBloodC.Enabled ~= true then
		enabled = true
		p1.Humanoid.Health-=1.25
		local v2 = Instance.new("NumberValue")
		v2.Name = "MeleeDamageMultiplier"
		v2.Value = 1.2
		v2.Parent = p1.Boosts
		pcall(function()
			HumanoidRootPart.RageParticle.Enabled = true
			HumanoidRootPart.SCREAM2:Play()
		end)
		sub(function()
			pcall(function()
				HumanoidRootPart.RageParticle.Changed:Wait()
			end)
			if v2 then
				v2:Destroy()
			end
		end)
	else
		enabled = false
		HumanoidRootPart.RageParticle.Enabled = false
	end
	wait(1.5)
	canuse = true
end)