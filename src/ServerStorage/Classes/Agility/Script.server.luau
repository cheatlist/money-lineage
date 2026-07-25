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
		local data = game.ServerStorage.PlayerData[p2.Name]
		if data.Skills.Value:find("TheMaster") then
			-- TheMaster path: Agility is permanently active (granted at spawn in
			-- CharacterHandler/init.server.luau) at a nerfed strength, so activating it
			-- manually is redundant
			return
		end
		local blade = data.Skills.Value:find("TheBlade")
		local lasts = 10
		if data.Skills.Value:find("UpgradedAgility") then
			lasts = 12.5
		end
		local CD = Instance.new("NumberValue")
		CD.Name = "Agility"
		CD.Value = 30-lasts
		CD.Parent = p1.Cooldowns
		game.Debris:AddItem(CD, 30-lasts)
		local HumanoidRootPart = p1.HumanoidRootPart
		HumanoidRootPart.AgilityEmit:Emit(40)
		if blade then
			-- TheBlade path: Agility SFX changed
			HumanoidRootPart.BladeAgility:Play()
		else
			HumanoidRootPart.CrazySound:Play()
		end
		local speed = 4
		if data.Skills.Value:find("UpgradedAgility")then
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
		if blade then
			-- TheBlade path: lets you run and M1 at the same time instead of clicking to
			-- attack cancelling your sprint (see Input.client.luau leftclick())
			local sprintAttack = Instance.new("Folder")
			sprintAttack.Name = "AgilitySprintAttack"
			sprintAttack.Parent = p1.Boosts
			game.Debris:AddItem(sprintAttack, 10)
		end
		task.wait(lasts)
		HumanoidRootPart.AgilityEmit:Emit(10)
		task.wait(30-lasts)
		canuse = true
	end)
end)