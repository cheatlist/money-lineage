local sound = script:WaitForChild("Sound")
sound:Play()

for i,v in pairs(game.Workspace.Thrown:GetChildren()) do
	if v.Name == "Watched" then
		game.TweenService:Create(v.Tool,TweenInfo.new(0.25),{TextTransparency = 1}):Play()
		game.Debris:AddItem(v, 0.5)
	end
end

wait(5)

script:Destroy()