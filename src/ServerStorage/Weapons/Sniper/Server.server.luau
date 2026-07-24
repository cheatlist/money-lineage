local TagHumanoid = game.ServerStorage.Requests.TagHumanoid

local cooldown: boolean = false

script.Parent.getMouse.OnServerEvent:Connect(function(player, target)
	if player.Character ~= script.Parent.Parent then
		player:Kick("Issue had occured in firing a remote event. [DEV CODE #ST8]")
		return
	end
	if not cooldown then
		
		cooldown = true
		
		task.spawn(function()
			wait(3)
			cooldown = false
		end)
		
		if not player.Character.HumanoidRootPart:FindFirstChild("Valley Of Heroes") then
			local Theme = Instance.new("Sound")
			Theme.SoundId = "rbxassetid://7951130965"
			Theme.Name = "Valley Of Heroes"
			Theme.Volume = 3
			Theme.Parent = player.Character.HumanoidRootPart

			task.spawn(function()
				task.wait(1.7)
				Theme:Play()
				task.wait(14)
				Theme:Destroy()
			end)

		end
		game:GetService("Chat"):Chat(player.Character.Head, "I'm taking the shot, Lannis.")
		local TargetHumanoid = target:FindFirstChildOfClass("Humanoid")
		local TargetRoot = target:FindFirstChild("HumanoidRootPart")
		TargetRoot.Anchored = true
		task.wait(1.7)
		TargetRoot.Anchored = false
		script.Parent.Handle.shoot:Play()
		TagHumanoid:Fire(player.Character, target, {
			damage = 666,
			physical = true,
		})
		
	end
end)