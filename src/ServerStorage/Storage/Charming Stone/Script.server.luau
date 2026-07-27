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
	if (data.Artifact.Value~="None" and data.Artifact.Value~="") and data.Artifact.Value ~= "Spider Cloak"then
		return
	end
	canuse = false
	data.Artifact.Value = "Charming Stone"
	local v1 = Instance.new("Accessory")
	v1.Name = "Charming Stone"
	v1.Parent = p1.Artifacts
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(p2,script.Parent.Name)
	script.Parent:Destroy()
end)
