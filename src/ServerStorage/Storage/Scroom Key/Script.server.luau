function sub(...)
	coroutine.wrap(...)()
end
local u3 = require(game.ServerScriptService.Modules.Commands)
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	do -- return
		return
	end
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	if game.ServerStorage.PlayerData[p1.Name].Race.Value == "Scroom" then
		game.ServerStorage.PlayerData[p1.Name].Race.Value = "Metascroom"
		require(game.ServerScriptService.Modules.Commands)["RemoveFromInventory"](game.Players[p1.Name], script.Parent.Name)
		game.Players[p1.Name]:LoadCharacter()
		local v12 = Instance.new("NumberValue");
		v12.Name = "Transparency";
		v12.Value = 0;
		v12.Parent = game.Players[p1.Name].Character.Boosts;
	end
end)