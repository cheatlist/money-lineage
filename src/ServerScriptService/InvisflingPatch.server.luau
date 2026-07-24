while true do
	wait(.1)
	for i,v in pairs(game.Workspace.Live:GetChildren()) do
		if v:FindFirstChild("Humanoid") == nil then --Player check
		else
			if game.Players:FindFirstChild(v.Name) then
				if game.Players[v.Name].Character:FindFirstChild("Humanoid").RigType ~= Enum.HumanoidRigType.R6 then
				if v:FindFirstChild("HumanoidRootPart") == nil then --Detects if HumanoidRootPart still exist
					if v:FindFirstChild("Head") == nil then
						print(v.Name.." Is a dead player that has fallen into the void.")
					else
						game.Players[v.Name]:Kick("Banned from the game.")
					end
				else
					if v:FindFirstChild("UpperTorso") == nil then --Detects if Torso Still exist
						game.Players[v.Name]:Kick("Banned from the game.")
					else
					end
				end
			else
				if v:FindFirstChild("HumanoidRootPart") == nil then --Detects if HumanoidRootPart still exist
					if v:FindFirstChild("Head") == nil then
						print(v.Name.." Is a dead player that has fallen into the void.")
					else
						game.Players[v.Name]:Kick("Banned from the game.")
					end
				else
					if v:FindFirstChild("Torso") == nil then --Detects if Torso Still exist
						game.Players[v.Name]:Kick("Banned from the game.")
					else
					end
				end
			end
				
			end
			
		end
	end
end