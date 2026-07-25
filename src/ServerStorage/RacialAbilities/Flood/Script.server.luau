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
	if p1.Cooldowns:FindFirstChild("Flood") then
		return
	end
	local CD = Instance.new("NumberValue")
	CD.Name = "Flood"
	CD.Value = 90
	CD.Parent = p1.Cooldowns
	game.Debris:AddItem(CD, 90)
	canuse = false
	for i = 1,3 do
		p1.HumanoidRootPart.MoneyCharge:Play()
		p1.HumanoidRootPart.AgilityEmit:Emit(30)
		wait(0.1)
	end
	local p2 = game.Players:GetPlayerFromCharacter(p1)
	local data = game.ServerStorage.PlayerData:FindFirstChild(p2.Name)
	local length = 30
	local v1 = Instance.new("Accessory")
	v1.Name = "FullMana"
	v1.Parent = p1
	game.Debris:AddItem(v1,length)
	wait(length)
	if data.Ascended.Value ~= true then
		local v2 = Instance.new("Accessory")
		v2.Name = "HalfSoul"
		v2.Parent = p1
		game.Debris:AddItem(v2,15)
	end
	local v3 = Instance.new("Accessory")
	v3.Name = "Charge"
	v3.Parent = p1
	game.Debris:AddItem(v3,0.001)
	wait(90)
	canuse = true
end)