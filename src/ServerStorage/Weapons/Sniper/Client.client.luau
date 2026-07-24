local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local character = player.Character or player.CharacterAdded:Wait()
--local idleAnim = character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(script:WaitForChild("Hold"))
script.Parent.Activated:Connect(function()
	if mouse.Target then
		if mouse.Target.Parent:FindFirstChild("Humanoid") then
			local char = mouse.Target.Parent
			if char then
				script.Parent.getMouse:FireServer(char)
			end
		end
	end
end)

--[[

script.Parent.Equipped:Connect(function()
	idleAnim:Play()
end)

script.Parent.Unequipped:Connect(function()
	idleAnim:Stop()
end)

]]

local Tool = nil
local animScript = nil
script.Parent.Equipped:Connect(function()
	Tool = script.Parent
	animScript = Tool.Parent:WaitForChild("Animate")
	animScript:WaitForChild("toolnone"):WaitForChild("ToolNoneAnim")
	animScript.toolnone.ToolNoneAnim.AnimationId = "https://roblox.com/asset/?id=11888182044"
end)

script.Parent.Equipped:Connect(function()
	Tool = script.Parent
	animScript:WaitForChild("toolnone"):WaitForChild("ToolNoneAnim")
	animScript.toolnone.ToolNoneAnim.AnimationId = "https://roblox.com/asset/?id=11888182044"
end)