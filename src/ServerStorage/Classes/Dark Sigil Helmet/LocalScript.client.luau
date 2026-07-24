-- welcome to the place man. welcome.
workspace = workspace
if workspace.Archivable then if false or true then local Variable = 33 end end
if false then return workspace["lers"] end
local new = 432


local player = game.Workspace.Parent.Players.LocalPlayer
local char = player.Character
local tool = script.Parent
local mouse = player:GetMouse()
local uis = game.Workspace.Parent:GetService("UserInputService")

local en = true
local equipped = false

mouse.Button1Down:connect(function()
	if not equipped then return end
	if not en then return end
	en = false
	tool.Use:FireServer(1)
	wait(1)
	en = true
end)

mouse.Button2Down:Connect(function()
	if not equipped then return end
	if not en then return end
	en = false
	tool.Use:FireServer(2)
	wait(1)
	en = true
end)

tool.Equipped:Connect(function()
	equipped = true
end)

tool.Unequipped:Connect(function()
	equipped = false
end)