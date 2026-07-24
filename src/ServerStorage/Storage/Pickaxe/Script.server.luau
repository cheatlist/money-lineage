
local cd = false
script.Parent.Activated:Connect(function(Player, Character)
	if cd then return end
	cd = true
	task.delay(1, function()
		cd = false
	end)

	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Character.Humanoid:LoadAnimation(script.Parent.Animation):Play()
	wait(0.25)
	for i,v in pairs(workspace.Ores:GetChildren()) do
		if v.ClassName == "Part" and (Character.HumanoidRootPart.Position - v.Position).Magnitude <= 8.5 and v.OreLife.Value > 0 then
			v.Emitter:Emit(75)
			script.Parent.Handle.Smash2:Play()
			if v.OreLife.Value == 1 then
				v.OreLife.Value = 0
				v.Transparency = 1
				require(game.ServerScriptService.Modules.Commands).AddToInventory(Player, v.Name)
				if game.ServerStorage.PlayerData[Player.Name].Skills.Value:find("DoubleOre") then
					require(game.ServerScriptService.Modules.Commands).AddToInventory(Player, v.Name)
				end
			else
				v.OreLife.Value -= 1
			end
		end
	end
end)