game.Players.LocalPlayer.ChildAdded:Connect(function(ch)
	if ch.Name == "Danger" or ch.Name == "MortalDanger" then
		local ui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("ServerBrowse")
		if ui then
			ui.Enabled = false
		end
	end
end)

script.Parent.MenuLabel.MouseButton1Click:Connect(function()
	if not game.Players.LocalPlayer:FindFirstChild("Danger") and not game.Players.LocalPlayer:FindFirstChild("MortalDanger") then
		local ui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("ServerBrowse")
		if ui then
			ui.Enabled = not ui.Enabled
		end
	end
	game.TweenService:Create(script.Parent.MenuLabel.StateOverlay,TweenInfo.new(.3,Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut,0,false),{ImageTransparency = 0.8}):Play()
	task.wait(.3)
	game.TweenService:Create(script.Parent.MenuLabel.StateOverlay,TweenInfo.new(.3,Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut,0,false),{ImageTransparency = 1}):Play()
end)