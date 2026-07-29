function sub(...)
	coroutine.wrap(...)()
end
local TweenService = game:GetService("TweenService")
local canuse = true
local equipped = false
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if not canuse then
		return
	end
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if (data.Artifact.Value~="None" and data.Artifact.Value~="") then
		require(game.ServerScriptService.Modules.AlertModule).send(p2, "You already have an artifact - "..data.Artifact.Value..". Reset your current artifact by talking to Isaiah at desert 3.")
		canuse = true
		return
	end
	if data.PrimaryWeapon.Value=="Fairfrozen"then
		canuse = true
		return
	end
	data.Artifact.Value = "Philo"
	require(game.ServerScriptService.Modules.Commands).Learn(p2)
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p2,"Philosophers Stone")
end)