
local function actioncheck(char)
	if char:FindFirstChild("Action") then
		return false
	end
	if char:FindFirstChild("Unconscious") then
		return false
	end
	if char:FindFirstChild("Stun") then
		return false
	end
	if char:FindFirstChild("Immortal") then
		return false
	end
	if char:FindFirstChild("Knocked") then
		return false
	end
	if game.CollectionService:HasTag(char, "BeingExecuted") then
		return false
	end
	return true
end


local CD = false
script.Parent.Activated:Connect(function(Player, Character, Data)
	Character = script.Parent.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Data = game.ServerStorage.PlayerData[Player.Name]
	if not actioncheck(Character) then
		return
	end
	if Data.BoundAmount.Value > 0 then
		if not CD then
			CD = true
			local MouseData = _G.MouseData(Player)
			if (MouseData.Hit.p - Character.HumanoidRootPart.Position).Magnitude > 100 then
				return
			end
			Data.BoundAmount.Value -= 1
			game.ServerStorage.Requests.SpawnMonster:Invoke("Shrieker", MouseData.Hit.p + Vector3.new(0, 2, 0), Character, false)
			local v12 = game.ServerStorage.Assets.Dark:Clone();
			v12.CFrame = MouseData.Hit * CFrame.new(0, 2, 0);
			v12.Parent = workspace.Thrown;
			game:GetService("Debris"):AddItem(v12, 2);
			v12.Sound:Play();
			v12.Attachment.OrbParticle:Emit(100);
			game:GetService("TweenService"):Create(v12, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false), {
				Size = Vector3.new(10.05, 10.05, 10.05)
			}):Play();
			wait(0.25)
			CD = false
		end
	end
end)