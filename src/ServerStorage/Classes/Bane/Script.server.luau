function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
local ActionCheckModule = require(game.ServerScriptService.Modules.ActionCheck)
local function ActionCheck(Parent)
	return ActionCheckModule(Parent, {
		presentBlocks = {"Stun","ReturnStun","Action","Blocking","SpellBlocking","ActiveCast","Unconscious","Knocked","Immortal"},
	})
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	spawn(function()
		if ActionCheck(p1)then
			return
		end
		if p1.Cooldowns:FindFirstChild("Bane") then
			return
		end
		local p2 = game.Players:GetPlayerFromCharacter(p1)
		local lasts = 10
		if p2.Backpack:FindFirstChild("UpgradedBane")then
			lasts = 15
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "Bane"
		CD.Value = 35-lasts
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 35-lasts)
		canuse = false
		local HumanoidRootPart = p1.HumanoidRootPart
		HumanoidRootPart.BaneEmit:Emit(40)
		HumanoidRootPart.BaneCharge:Play()
		local v1 = Instance.new("Accessory")
		v1.Name = "BaneEff"
		v1.Parent = p1
		game.Debris:AddItem(v1,lasts)
		p1.Humanoid:UnequipTools()
		local m1 = require(game.ServerScriptService.Modules.m1)
		local combatanims = game.ReplicatedStorage:WaitForChild("CombatAnims"):Clone()
		m1(p1,p2,combatanims,game.ServerStorage.PlayerData[p1.Name])
		local dagger = p2.Backpack:FindFirstChild("Dagger")
		if dagger then
			p1.Humanoid:EquipTool(dagger)
		end
		task.wait(lasts)
		HumanoidRootPart.BaneDischarge:Play()
		task.wait(35 - lasts)
		canuse = true
	end)
end)