local u3 = require(game.ServerScriptService.Modules.Commands)
script.Parent.Activated:Connect(function(plr, char)
	char = script.Parent.Parent
	plr = game.Players:GetPlayerFromCharacter(char)
	local data = game.ServerStorage.PlayerData[char.Name]
	char.Humanoid:LoadAnimation(script.Parent.Animation):Play()
	if data.Vampire.Value == true or char:FindFirstChild("NoHunger") or char:FindFirstChild("NoEat") then
		wait(0.175)
		script.Parent.Handle.Cough:Play()
		return
	end
	wait(0.175)
	script.Parent.Handle.Sound:Play()
	game.Debris:AddItem(script.Parent,0.65)

	char.Stomach.Value += 50 
	u3.RemoveFromInventory(game.Players:GetPlayerFromCharacter(char),"Pork Bun")
end)