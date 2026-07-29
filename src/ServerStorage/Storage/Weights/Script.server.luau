-- Found/bought consumable: unlocks Bent Over Row permanently. Sets a server-truth PlayerData
-- flag (not a Backpack-presence check) that Bent Over Row/Script.server.luau checks directly,
-- per this session's spoofable-check security fix - same consumable-pickup shape as Black Pill
-- (ServerStorage/Storage/Black Pill/Script.server.luau).
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	if not p2 then
		return
	end
	if not canuse then
		return
	end
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if not data then
		return
	end
	if data.WeightsOwned.Value == true then
		return
	end
	data.WeightsOwned.Value = true

	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p2, script.Parent.Name)
end)
