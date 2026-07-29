local u3 = require(game.ServerScriptService.Modules.Commands)
local FoodModule = require(game.ServerScriptService.Modules.FoodModule)
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
	-- Routed through FoodModule.eat (2026-07-29) - Pork Bun previously did its own inline
	-- Stomach.Value math with no AnythingEater check at all, so an AnythingEater player could
	-- still eat Pork Bun normally even though "you cannot eat food" is supposed to be absolute.
	if not FoodModule.eat(char, data, "Pork Bun", 50) then
		wait(0.175)
		script.Parent.Handle.Cough:Play()
		return
	end
	wait(0.175)
	script.Parent.Handle.Sound:Play()
	task.delay(1.218, function()
		script.Parent.Handle.Sound:Stop()
	end)

	u3.RemoveFromInventory(game.Players:GetPlayerFromCharacter(char),"Pork Bun",0.65)
end)