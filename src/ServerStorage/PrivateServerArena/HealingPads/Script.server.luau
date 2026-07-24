for i,v in pairs(script.Parent:GetChildren()) do
	if v.Name == "Part" then
		v.ClickDetector.MouseClick:Connect(function(player)
			local char = player.Character
			char.Humanoid.Health = char.Humanoid.MaxHealth
			char.Stomach.Value = char.Humanoid.MaxHealth
			char.Toxicity.Value = 0
			if game.ServerStorage.PlayerData:FindFirstChild(player.Name) then
				game.ServerStorage.PlayerData[player.Name].Injuries.Value = ""
			end
		end)
	end
end