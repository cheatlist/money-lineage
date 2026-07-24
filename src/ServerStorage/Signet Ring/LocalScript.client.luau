local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local db = false
script.Parent.Activated:Connect(function()
	if db then
		return
	end
	db = true
	script.Parent.RemoteEvent:FireServer(mouse.Target)
	wait(1)
	db = false
end)