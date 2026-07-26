local TweenService = game:GetService("TweenService")
function ActionCheck(Parent)
	if Parent:FindFirstChild("Stun") then
		return true
	end
	if Parent:FindFirstChild("NoDam") then
		return true
	end
	if Parent:FindFirstChild("ReturnStun") then
		return true
	end
	if Parent:FindFirstChild("Action") then
		return true
	end
	if Parent:FindFirstChild("Blocking") then
		return true
	end
	if Parent:FindFirstChild("ActiveCast") then
		return true
	end
	if Parent:FindFirstChild("Unconscious") then
		return true
	end
	if Parent:FindFirstChild("Knocked") then
		return true
	end
	if Parent:FindFirstChild("Immortal") then
		return true
	end
	return false
end
local canuse = true
script.Parent.Activated:Connect(function()
	local p1 = script.Parent.Parent
	if ActionCheck(p1)then
		return
	end
	if not canuse then
		return
	end
	if p1.Cooldowns:FindFirstChild("Awakened") then
		return
	end
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	local ascended = data and data.Ascended.Value == true and data.Race.Value == "Dzin"
	local cooldown = ascended and 60 or 85

	local CD = Instance.new("NumberValue")
	CD.Name = "Awakened"
	CD.Value = cooldown
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, cooldown)
	canuse = false
	p1.HumanoidRootPart.MoneyCharge2:Play()
	local v1 = Instance.new("NumberValue")
	v1.Name = "Awakening"

	local awakeningdodges = ascended and 15 or 5
	v1.Value = awakeningdodges
	v1.Parent = p1
	task.delay(25, function()
		if v1.Parent then
			v1.Parent = nil
			wait(1)
			v1:Destroy()
		end
	end)
	v1:GetPropertyChangedSignal("Parent"):Wait()
	if p1:IsDescendantOf(workspace)and p1:FindFirstChild'HumanoidRootPart'then
		p1.HumanoidRootPart.MoneyDischarge:Play()
	end
	task.wait(cooldown)
	canuse = true
end)