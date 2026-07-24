function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"Stun","NoDam","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	spawn(function()
		if ActionCheck(p1)then
			return
		end
		if p1.Cooldowns:FindFirstChild("Agility") then
			return
		end
		local p2 = game.Players:GetPlayerFromCharacter(p1)
		local lasts = 10
		if p2.Backpack:FindFirstChild("UpgradedAgility") then
			lasts = 12.5
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "Agility"
		CD.Value = 30-lasts
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 30-lasts)
		local HumanoidRootPart = p1.HumanoidRootPart
		HumanoidRootPart.AgilityEmit:Emit(40)
		HumanoidRootPart.CrazySound:Play()
		local speed = 4
		if p2.Backpack:FindFirstChild("UpgradedAgility")then
			speed = 8
		end
		local v1 = Instance.new("NumberValue")
		v1.Name = "SpeedBoost"
		v1.Value = speed
		v1.Parent = p1.Boosts
		game.Debris:AddItem(v1,10)
		local v2 = Instance.new("NumberValue")
		v2.Name = "AttackSpeedBoost"
		v2.Value = 6
		v2.Parent = p1.Boosts
		game.Debris:AddItem(v2,10)
		wait(lasts)
		HumanoidRootPart.AgilityEmit:Emit(10)
		wait(30-lasts)
		canuse = true
	end)
end)