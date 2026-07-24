script.Parent.Activated:Connect(function(Player,Character)
	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	for i,v in pairs(workspace.Stations:GetChildren()) do
		if v.Name == "SmithingStation" and (v.Hammer.Position - Character.HumanoidRootPart.Position).Magnitude <= 8 then
			require(game.ServerScriptService.Modules.Commands).RemoveFromInventory(Player, script.Parent.Name)
			v.Contents.Value ..= ","..script.Parent.Name
			script.Parent:Destroy()
		end
	end
end)