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
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local HumanoidRootPart = p1.HumanoidRootPart
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if (data.Artifact.Value~="None" and data.Artifact.Value~="") then
		canuse = true
		return
	end
	if data.Armor.Value=="Spider Cloak"then
		canuse = true
		return
	end
	local v1 = Instance.new("Accessory")
	v1.Name = "NightStoneActive"
	v1.Parent = workspace
	data.Artifact.Value = "Nightstone"
	require(game.ServerScriptService.Modules.Commands).Learn(p2)
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p2,"Nightstone")
	script.Parent:Destroy()
end)