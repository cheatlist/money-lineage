

local player = game.Workspace.Parent.Players.LocalPlayer
local tool = script.Parent
local mouse = player:GetMouse()

mouse.Button1Down:connect(function()
	local ch = player.Character
	if not ch or not tool:IsDescendantOf(ch) then return end
	
	tool.RemoteEvent:FireServer(mouse.Hit,mouse.Target)
end)