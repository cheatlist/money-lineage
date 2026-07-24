local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local Parent = script.Parent
local Overlay = Parent:WaitForChild("Overlay")
local Map = Overlay:WaitForChild("Map")
local Vingette = Overlay:WaitForChild("Vignette")
local Title = Overlay:WaitForChild("Title")
Map.ImageTransparency = 1
local RNG = Random.new()
game:GetService("ContentProvider"):PreloadAsync({ Map.Image })
game.TweenService:Create(Map, TweenInfo.new(1), {
	ImageTransparency = 0.8
}):Play()
local Time = 0
while true do
	Time = (Time + 0.2) % 1800
	Map.Position = UDim2.new(0, -1800 + Time, 0.5, 0)
	RunService.RenderStepped:wait()
	if Player:FindFirstChild("tpfail") then
		Player.tpfail:Destroy()
		break
	end
end
game.TweenService:Create(Map, TweenInfo.new(.5), {
	ImageTransparency = 1
}):Play()
game.TweenService:Create(Title, TweenInfo.new(.5), {
	TextTransparency = 1
}):Play()
task.wait(.5)
game.TweenService:Create(Vingette, TweenInfo.new(.5), {
	ImageTransparency = 1
}):Play()
game.TweenService:Create(Overlay, TweenInfo.new(.5), {
	ImageTransparency = 1
}):Play()
