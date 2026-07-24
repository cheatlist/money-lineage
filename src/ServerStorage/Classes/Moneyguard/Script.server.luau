function sub(...)
	coroutine.wrap(...)()
end
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
	else
		return
	end
	return true
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
	canuse = false
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	if not p1:FindFirstChild("MoneyGuard")then
		local v1 = Instance.new("Accessory")
		v1.Name = "MoneyGuard"
		v1.Parent = p1
		p1.HumanoidRootPart.MoneyCharge:Play()
		p1.HumanoidRootPart.MoneyEmit:Emit(50)
	else
		p1.MoneyGuard:Destroy()
		p1.HumanoidRootPart.MoneyEmit:Emit(5)
		p1.HumanoidRootPart.MoneyDischarge:Play()
	end
	wait(1)
	canuse = true
end)