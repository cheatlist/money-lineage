function sub(...)
	coroutine.wrap(...)()
end
function ActionCheck(Parent)
	if Parent:FindFirstChild("LightAttack") then
		return true
	end
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
	if Parent:FindFirstChild("SpellBlocking") then
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
	if Parent.Humanoid.FloorMaterial == Enum.Material.Air then
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
	local HumanoidRootPart = p1.HumanoidRootPart
	local NoJump = Instance.new("Accessory")
	NoJump.Name = "NoJump"
	NoJump.Parent = p1
	local TPSafe = Instance.new("Accessory")
	TPSafe.Name = 'FlightOk'
	TPSafe.Parent = p1
	local TPSafe2 = Instance.new("Accessory")
	TPSafe2.Name = 'TPSafe'
	TPSafe2.Parent = p1
	local Chair = game.ServerStorage.Assets["Pumpkin Chair Purple"]:Clone()
	Chair.Parent = p1
	Chair:SetPrimaryPartCFrame((HumanoidRootPart.CFrame*CFrame.new(0,-2.19,0))*CFrame.Angles(0,math.rad(180),math.rad(0)))
	Chair.Seat:FindFirstChild("Weld").Part1 = HumanoidRootPart
	local Animation = p1.Humanoid:LoadAnimation(script.Sit)
	Animation:Play()
	local Stun
	Stun = p1.ChildAdded:Connect(function()
		if ActionCheck(p1) then
			Chair.Seat:FindFirstChild("Weld"):Destroy()
			Animation:Stop()
			Chair:Destroy()
			NoJump:Destroy()
			TPSafe:Destroy()
			TPSafe2:Destroy()
			Stun:Disconnect()
			wait(0.3)
			canuse = true
		end
	end)
end)