script.Parent.Activated:Connect(function(Player, Character)
	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	local Data = game.ServerStorage.PlayerData[Player.Name]
	if Data.Artifact.Value ~= "" and Data.Artifact.Value ~= "None" then
		require(game.ServerScriptService.Modules.AlertModule).send(Player, "You already have an artifact - "..Data.Artifact.Value..". Reset your current artifact by talking to Isaiah at desert 3.")
		return
	end
	if Data.Race.Value == "Howler" then
		return
	end
	Data.Artifact.Value = "Howler Friend"
	local Boost = Instance.new("Folder")
	Boost.Name = "PuppiesLikeHim"
	Boost.Parent = Character.Boosts
	require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(Player, script.Parent.Name)
end)