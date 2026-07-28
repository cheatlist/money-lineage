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
	tool.RemoteEvent:FireServer(mouse.Hit,mouse.Target,"Self")
	wait(1)
	en = true
end)

uis.InputBegan:connect(function(input, gp)
	if input.UserInputType == Enum.UserInputType.Keyboard and not gp then
		if input.KeyCode == Enum.KeyCode.P then
			if not equipped then return end
			if not en then return end
			en = false
			tool.RemoteEvent:FireServer(mouse.Hit,mouse.Target,"Pour")
			wait(1)
			en = true
		end
	end
end)

tool.Equipped:Connect(function()
	equipped = true
end)

tool.Unequipped:Connect(function()
	equipped = false
end)
