function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
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
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	if not p2 then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if not data then
		return
	end
	if (data.Artifact.Value~="None" and data.Artifact.Value~="")then
		require(game.ServerScriptService.Modules.AlertModule).send(p2, "You already have an artifact - "..data.Artifact.Value..". Reset your current artifact by talking to Isaiah at desert 3.")
		return
	end
	if data.PrimaryWeapon.Value=="Fairfrozen"then
		return
	end
	if data.Armor.Value == "Spider Cloak"then
		return
	end
	data.Artifact.Value = "Fairfrozen"
	data.PrimaryWeapon.Value = "Fairfrozen"
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p2,script.Parent.Name)
end)